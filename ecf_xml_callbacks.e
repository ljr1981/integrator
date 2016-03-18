note
	description: "[
		Representation of an {ECF_XML_CALLBACKS}.
		]"

class
	ECF_XML_CALLBACKS

inherit
	XML_CALLBACKS_NULL
		redefine
			on_start_tag,
			on_attribute,
			on_content
		end

create
	make

feature -- Events

	on_start_tag (a_namespace, a_prefix: detachable READABLE_STRING_32; a_local_part: READABLE_STRING_32)
			-- <Precursor>
		do
			last_start_tag_namespace := a_namespace
			last_start_tag_prefix := a_prefix
			last_start_tag_local_part := a_local_part
		end

	on_attribute (a_namespace, a_prefix: detachable READABLE_STRING_32; a_local_part, a_value: READABLE_STRING_32)
			-- <Precursor>
		do
			if is_last_tag_system then
				if a_local_part.same_string ("name") then
					last_system_name := a_value
				elseif a_local_part.same_string ("uuid") then
					last_uuid := a_value
				end
			elseif is_last_tag_library then
				if a_local_part.same_string ("name") then
					last_library_name := a_value
				elseif a_local_part.same_string ("location") then
					last_library_location := a_value
				end
				if attached last_library_name as al_name and then attached last_library_location as al_location then
					last_is_github := al_location.has_substring ("$GITHUB")
					last_is_ise := al_location.has_substring ("$ISE_LIBRARY")
					libraries.force ([al_name, al_location, last_is_github, last_is_ise, is_local_library, is_computed_uuid])
					if al_name.same_string ("testing") then
						last_test_target := last_target_name
					end
				end
			elseif is_last_tag_target then
				if a_local_part.same_string ("name") then
					last_target_name := a_value
					target_list.force (a_value)
				end
			end
		end

	on_content (a_content: READABLE_STRING_32)
			-- <Precursor>
		do
			if is_last_tag_description then
				last_description := a_content
			end
		end

feature -- Data

		-- Each <start_tag> encountered fills these ...
	last_start_tag_namespace: detachable READABLE_STRING_32
	last_start_tag_prefix: detachable READABLE_STRING_32
	last_start_tag_local_part: detachable READABLE_STRING_32

		-- In-order, top-to-bottom/left-to-right of ECF XML
	last_system_name: detachable READABLE_STRING_32
	attached_system_name: READABLE_STRING_32			-- Non-optional in ECF XML
		do
			check attached last_system_name as al_item then
				Result := al_item
			end
		end

	last_uuid: detachable READABLE_STRING_32
	attached_uuid: UUID								-- Non-optional in ECF XML
		note
			lessons_learned: "[
				(1) Not all ECFs (from ISE and others) have valid UUIDs! Sometimes,
					what we have (encounter) is a "{UUID\}". We may need to study
					that one out and discover how to handle it properly. Until then,
					the code below does a test for `is_valid_uuid' and computes one
					of its own if not.
				]"
		local
			l_uuid: UUID
		do
			create l_uuid
			if attached last_uuid as al_uuid and then l_uuid.is_valid_uuid (al_uuid) then
				Result := (create {UUID}.make_from_string (al_uuid))
				is_computed_uuid := False
			else
				Result := (create {RANDOMIZER}).uuid
				is_computed_uuid := True
			end
		end
	is_computed_uuid: BOOLEAN

	last_description: detachable READABLE_STRING_32 	-- Fully optional in ECF XML
	target_list: ARRAYED_LIST [READABLE_STRING_32] attribute create Result.make (10) end
	last_target_name: detachable READABLE_STRING_32
	attached_target_name: READABLE_STRING_32			-- Non-optional in ECF XML
		do
			check attached last_target_name as al_item then
				Result := al_item
			end
		end

	last_test_target: detachable READABLE_STRING_32 	-- Fully optional in ECF XML
	last_library_name: detachable READABLE_STRING_32 	-- "Optional" but at least one (usually "base") ...
	last_library_location: detachable READABLE_STRING_32

	last_path: detachable PATH							-- Will we know the path?

	last_is_github: BOOLEAN								-- Is the library a $GITHUB library?
	last_is_ise: BOOLEAN								-- Is the library an $ISE_LIBRARY?
	is_local_library: BOOLEAN 							-- Local: A library not $GITHUB or $ISE_LIBRARY?
		do
			Result := not (last_is_github and not last_is_ise)
		end

	libraries: ARRAYED_LIST [TUPLE [name, location: READABLE_STRING_32; is_github, is_ise, is_local, is_computed_uuid: BOOLEAN]]
			-- `libraries' from Current XML.
		attribute
			create Result.make (100)
		end

feature -- Status Report

	is_last_tag_system: BOOLEAN
			-- `is_last_tag_system'?
		do
			Result := is_last_tag ("system")
		end

	is_last_tag_description: BOOLEAN
			-- `is_last_tag_description'?
		do
			Result := is_last_tag ("description")
		end

	is_last_tag_target: BOOLEAN
			-- `is_last_tag_target'?
		do
			Result := is_last_tag ("target")
		end

	is_last_tag_library: BOOLEAN
			-- `is_last_tag_library'?
		do
			Result := is_last_tag ("library")
		end

	is_last_tag (a_name: STRING): BOOLEAN
			-- `is_last_tag' `a_name'?
		do
			Result := attached last_start_tag_local_part as al_local and then al_local.same_string (a_name)
		end

end
