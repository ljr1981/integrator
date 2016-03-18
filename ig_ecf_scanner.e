note
	description: "[
		Representation of an {IG_ECF_SCANNER} controller.
		]"
	design: "[
		For "Scotty", the {IG_ECF_SCANNER} controller has the purpose of:
		
		(1) Parse $GITHUB for ECF projects.
		(2) Parse each ECF for Supplier ECF's (recursively)
		(3) Build dependency list of ECF-to-ECF (use UUID to ID each ECF)
		(4) ID each ECF as is_local_github and is_remote_github
		(5) ID each ECF as is_testing_enabled
		
		Goal:
		=====
		Github_projects ::=
			{Github_project}*
			
		Github_project ::=
			UUID
			Is_computed_UUID
			System_name
			Target_list
			Test_target
			Libraries
			
		Informative Text
		----------------
		(1) UUID: Every ECF (of interest) has a UUID. These ought to be unique.
			They need to be tested for uniqueness because a human programmer can
			(and in ignorance will) duplicate them by copy-and-paste.
			("If you're copying-and-pasting you're already wrong" -- Bertrand Meyer)
		(2) Is_computed_UUID: If the ECF does not have a UUID, one is provided by
			computation. This is noted in this BOOLEAN flag and ought to be
			checked to ensure that every ECF of interest has a UUID in the <system>
			tag. Again--this is a "programmer discipline" matter, where the programmer
			can (and sometimes will) forget to include an appropriate UUID for <system>.
		]"
	EIS: "src=$GITHUB/integrator/docs/Flow.png"

class
	IG_ECF_SCANNER

inherit
	LE_LOGGING_AWARE

	IG_CONSTANTS

feature -- Access

	ecf_libraries: HASH_TABLE [attached like ecf_libraries_data_anchor, UUID]
			-- `ecf_libraries' list.
		attribute
			create Result.make (default_ecf_libraries_capacity)
		end

	ecf_libraries_data_anchor: detachable TUPLE [system_name: READABLE_STRING_32; target_list: ARRAYED_LIST [READABLE_STRING_32];
													test_target: detachable READABLE_STRING_32;
													library_dependencies: HASH_TABLE [attached like ecf_library_dependencies_data_anchor, UUID];
													is_computed_uuid: BOOLEAN;
													github_path,
													github_config_path: detachable PATH]

feature -- Basic Operations: Scanning

	scan_github
			-- `scan_github'.
		do
			scan_path (github_path, default_scanning_start_level)
		end

feature {NONE} -- Implementation: Access

	ecf_library_dependencies: HASH_TABLE [attached like ecf_library_dependencies_data_anchor, UUID]
			-- A list of `ecf_library_dependencies' for each `ecf_libraries' entry.
		attribute
			create Result.make (default_ecf_libraries_capacity)
		end

	ecf_library_dependencies_data_anchor: detachable TUPLE [name, location: READABLE_STRING_32; is_github, is_ise, is_local, is_computed_uuid: BOOLEAN]
			-- `ecf_library_dependencies_data_anchor' for `ecf_library_dependencies'.

feature {NONE} -- Implementation: Basic Operations: Scanning

	scan_path (a_path: PATH; a_level: INTEGER)
			-- Recursively `scan_path' based on `a_path' (root or sub-path).
		note
			design: "[
				The `scan_path' is recursive (e.g. this feature calls itself).

				]"
		local
			l_dir,
			l_subdir,
			l_parent,
			l_git_parent: DIRECTORY
			l_string_8: STRING_8
			l_info: FILE_INFO
			l_git_path,
			l_git_config_path: detachable PATH
			l_has_git,
			l_has_git_config: BOOLEAN
		do
			if attached a_path.extension as al_ext then
				if al_ext.same_string (ecf_extension_string) then
					create l_parent.make_with_path (a_path.parent)
					across
						l_parent.entries as ic_parent_entries
					until
						l_has_git
					loop
						if ic_parent_entries.item.name.has_substring (".git") and then not ic_parent_entries.item.name.has_substring (".gitignore") then
							create l_git_path.make_from_string (l_parent.name.out + "\" + ic_parent_entries.item.name.out)
							l_has_git := attached l_git_path
							if l_has_git and then attached l_git_path as al_git_path then
								create l_git_parent.make_with_path (al_git_path)
								across
									l_git_parent.entries as ic_git_parent_entries
								until
									l_has_git_config
								loop
									if ic_git_parent_entries.item.name.has_substring ("config") then
										create l_git_config_path.make_from_string (l_git_parent.name.out + "\" + ic_git_parent_entries.item.name.out)
										l_has_git_config := attached l_git_config_path
									end
								end
							end
							check has_config: l_has_git_config and attached l_git_config_path end
						end
					end
					parse_ecf (a_path, l_git_path, l_git_config_path)
				end
			elseif a_path.name.has_substring (dot_git_string) or a_path.name.has_substring (dot_gitignore_string) then
				do_nothing
			elseif a_path.name.has_substring (git_config_string) then
				do_nothing
			elseif a_path.name.has_substring (EIFGENs_string) then
				do_nothing -- EIFGENs are ignored.
			else
				create l_dir.make_with_path (a_path)
				across
					l_dir.entries as ic_entries
				loop
					if not (ic_entries.item.is_current_symbol or ic_entries.item.is_parent_symbol) then -- ignore "."/".." paths
						scan_path (create {PATH}.make_from_string (l_dir.name.out + "\" + ic_entries.item.name.out), a_level + 1)
					end
				end
			end
		end

feature {NONE} -- Implementation: Basic Operations: Parsing

	parse_ecf (a_last_ecf_path: PATH; a_last_git_path, a_last_git_config_path: detachable PATH)
			-- `parse_ecf' found in `a_path'
		note
			lessons_learned: "[
				(1) Not all ECFs have a <system name="?">. Sometimes, the ECF is a "<redirect ...>".
					What a <redirect> is (precisely) is somewhat of a mystery. Until that mystery
					is resolved, we will simply exclude these from the ECF list. Ultimately,
					we only care about our own ECF's ($GITHUB et al) anyhow, so this is of little
					consequence or value at this time.
				]"
		local
			l_parser: XML_PARSER
			l_callbacks: ECF_XML_CALLBACKS
		do
			l_parser := (create {XML_PARSER_FACTORY}).new_parser
			create l_callbacks.make
			l_parser.set_callbacks (l_callbacks)
			l_parser.parse_from_path (a_last_ecf_path)

			if attached l_callbacks.last_system_name then
				if not l_callbacks.libraries.is_empty then
					across
						l_callbacks.libraries as ic_libs
					loop
						ecf_library_dependencies.force ([ic_libs.item.name, ic_libs.item.location, ic_libs.item.is_github, ic_libs.item.is_ise, ic_libs.item.is_local, ic_libs.item.is_computed_uuid], l_callbacks.attached_uuid)
					end
				end
				ecf_libraries.force ([l_callbacks.attached_system_name,
										l_callbacks.target_list,
										l_callbacks.last_test_target,
										ecf_library_dependencies,
										l_callbacks.is_computed_uuid,
										a_last_git_path,
										a_last_git_config_path], l_callbacks.attached_uuid)
				ecf_library_dependencies.wipe_out -- This is for clean-up, so we don't get confused later.
			end
		end

feature {NONE} -- Implementation: Constants

	default_ecf_libraries_capacity: INTEGER = 500
			-- `default_ecf_libraries_capacity' is 500.

	default_scanning_start_level: INTEGER = 0
			-- `default_scanning_start_level' is zero because 0 = root folder.

end
