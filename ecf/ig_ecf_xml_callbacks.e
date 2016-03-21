note
	description: "[
		Representation of an {IG_ECF_XML_CALLBACKS}.
		]"

class
	IG_ECF_XML_CALLBACKS

inherit
	XML_CALLBACKS_NULL
		redefine
			on_start_tag,
			on_attribute,
			on_content
		end

	IG_CONSTANTS

	IG_ANY

create
	make

feature {NONE} -- Implementation: Events

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
				if a_local_part.same_string (name_attribute_string) then
					last_system_name := a_value
				elseif a_local_part.same_string (uuid_attribute_name_string) then
					last_uuid := a_value
				end
			elseif is_last_tag_library then
				if a_local_part.same_string (name_attribute_string) then
					last_library_name := a_value
					last_library_location := Void
				elseif a_local_part.same_string (location_attribute_name_string) then
					last_library_location := a_value
				end
				if attached last_library_name as al_name and then attached last_library_location as al_location then
					last_is_github := al_location.has_substring (github_tag_string)
					last_is_ise := al_location.has_substring (ise_library_tag_string) or al_location.has_substring (ise_eiffel_tag_string)
					suppliers.force ([al_name, al_location, location_ecf_xml_uuid (al_location), last_is_github, last_is_ise, not (last_is_github or last_is_ise), not attached last_uuid])
					if al_name.same_string (testing_library_name_string) then
						last_test_target := last_target_name
					end
				end
			elseif is_last_tag_target then
				if a_local_part.same_string (name_attribute_string) then
					last_target_name := a_value
					targets.force (a_value)
				end
			end
		end

	location_ecf_xml_uuid (a_location: STRING): detachable READABLE_STRING_32
		local
			l_callbacks: IG_ECF_XML_CALLBACKS
			l_parser: XML_LITE_PARSER
			l_file: PLAIN_TEXT_FILE
			l_file_name,
			l_file_content: STRING
		do
			if last_is_github then
				create l_callbacks.make
				l_parser := (create {XML_LITE_PARSER_FACTORY}).new_parser
				l_parser.set_callbacks (l_callbacks)
				l_file_name := a_location.twin
				l_file_name.replace_substring_all (Github_tag_string, Github_path_string)
				create l_file.make_open_read (l_file_name)
				l_file.read_stream (l_file.count)
				l_file_content := l_file.last_string.twin
				l_file.close
				l_parser.parse_from_string (l_file_content)
				check has_uuid: attached l_callbacks.last_uuid as al_uuid then Result := al_uuid end
			else
				Result := Void
			end
		end

	on_content (a_content: READABLE_STRING_32)
			-- <Precursor>
		do
			if is_last_tag_description then
				last_description := a_content
				descriptions.force (a_content)
			end
		end

feature -- Access

	ecf_client_supplier: detachable IG_ECF_CLIENT_SUPPLIER
		local
			l_supplier: IG_ECF_CLIENT_SUPPLIER
		do
			-- Pull in data (post-parse) from all the "data" below
			if attached last_uuid as al_uuid and then (create {UUID}).is_valid_uuid (al_uuid) then
				create Result
				Result.set_uuid (create {UUID}.make_from_string (al_uuid))
				check attached last_system_name as al_item then
					Result.set_name (al_item)
				end
				if descriptions.count > 0 and then attached descriptions [1] as al_item then
					Result.set_description (al_item)
				end
				if attached last_path as al_item then
					Result.set_path (al_item)
					if attached (create {PATH}.make_from_string (al_item.name + "\.git")) as al_git_path and then (create {DIRECTORY}.make_with_path (al_git_path)).exists then
						Result.set_github_path (al_git_path)
					end
					if attached (create {PATH}.make_from_string (al_item.name + "\.git\config")) as al_git_config_path and then (create {DIRECTORY}.make_with_path (al_git_config_path)).exists then
						Result.set_github_path (al_git_config_path)
					end
				end
				-- Suppliers
				across
					suppliers as ic_suppliers
				loop
					if ic_suppliers.item.is_github then
						create l_supplier
						l_supplier.set_name (ic_suppliers.item.name)
						if attached ic_suppliers.item.uuid as al_uuid_string then
							l_supplier.set_uuid (create {UUID}.make_from_string (al_uuid_string))
						end
						l_supplier.set_description ("From_ECF_libraries_list")
						l_supplier.set_path (create {PATH}.make_from_string (ic_suppliers.item.location))
						Result.suppliers.force (l_supplier, l_supplier.uuid.out)
						l_supplier.clients.force (Result, Result.uuid.out)
						l_supplier.set_possible_client (Result)
					end
				end
			end
		end

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
	last_description: detachable READABLE_STRING_32 	-- Fully optional in ECF XML
	descriptions: ARRAYED_LIST [READABLE_STRING_32] attribute create Result.make (10) end
	targets: ARRAYED_LIST [READABLE_STRING_32] attribute create Result.make (10) end
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

	suppliers: ARRAYED_LIST [TUPLE [name, location: READABLE_STRING_32; uuid: detachable READABLE_STRING_32; is_github, is_ise, is_local, is_computed_uuid: BOOLEAN]]
			-- `suppliers' from Current XML.
		attribute
			create Result.make (100)
		end

feature -- Status Report

	is_last_tag_system: BOOLEAN
			-- `is_last_tag_system'?
		do
			Result := is_last_tag (system_tag_string)
		end

	is_last_tag_description: BOOLEAN
			-- `is_last_tag_description'?
		do
			Result := is_last_tag (description_tag_string)
		end

	is_last_tag_target: BOOLEAN
			-- `is_last_tag_target'?
		do
			Result := is_last_tag (target_tag_string)
		end

	is_last_tag_library: BOOLEAN
			-- `is_last_tag_library'?
		do
			Result := is_last_tag (library_tag_string)
		end

	is_last_tag (a_name: STRING): BOOLEAN
			-- `is_last_tag' `a_name'?
		do
			Result := attached last_start_tag_local_part as al_local and then al_local.same_string (a_name)
		end

feature {NONE} -- Implementation: Constants

	system_tag_string: STRING = "system"
	description_tag_string: STRING = "description"
	target_tag_string: STRING = "target"
	library_tag_string: STRING = "library"

	name_attribute_string: STRING = "name"
	uuid_attribute_name_string: STRING = "uuid"
	location_attribute_name_string: STRING = "location"
	testing_library_name_string: STRING = "testing"

end
