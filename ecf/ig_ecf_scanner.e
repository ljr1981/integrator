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
	IG_ANY

	IG_CONSTANTS

feature -- Access

	ecf_libraries: HASH_TABLE [attached like ecf_libraries_data_anchor, STRING]
			-- `ecf_libraries' list.
		attribute
			create Result.make (default_ecf_libraries_capacity)
		end

	ecf_libraries_data_anchor: detachable TUPLE [system_name: READABLE_STRING_32; target_list: ARRAYED_LIST [READABLE_STRING_32];
													test_target: detachable READABLE_STRING_32;
													supplier_libraries: HASH_TABLE [attached like ecf_library_dependencies_data_anchor, STRING];
													is_computed_uuid: BOOLEAN;
													github_path,
													github_config_path: detachable PATH;
													is_trunk,
													is_branch,
													is_leaf: BOOLEAN;
													suppliers,
													clients: HASH_TABLE [READABLE_STRING_32, READABLE_STRING_32]]

feature -- Status Report

	trunk_count: INTEGER
			-- `trunk_count'.
		do
			across
				ecf_libraries as ic_ecf
			loop
				if ic_ecf.item.is_trunk then
					Result := Result + 1
				end
			end
		end

	branch_count: INTEGER
			-- `branch_count'.
		do
			across
				ecf_libraries as ic_ecf
			loop
				if ic_ecf.item.is_branch then
					Result := Result + 1
				end
			end
		end

	leaf_count: INTEGER
			-- `leaf_count'.
		do
			across
				ecf_libraries as ic_ecf
			loop
				if ic_ecf.item.is_leaf then
					Result := Result + 1
				end
			end
		end

feature -- Basic Operations

	scan_github
			-- `scan_github'.
		do
			scan_path (github_path, default_scanning_start_level)
			identify_ecf_dependencies
		end

feature {NONE} -- Implementation: Basic Operations: Scanning

	scan_path (a_path: PATH; a_level: INTEGER)
			-- Recursively `scan_path' based on `a_path' (root or sub-path).
		note
			design: "[
				The `scan_path' is recursive (e.g. this feature calls itself).
				]"
		local
			l_dir: DIRECTORY
		do
			if attached a_path.extension as al_ext then
				if al_ext.same_string (ecf_extension_string) then
					process_ecf (a_path)
				end
			elseif a_path.name.has_substring (dot_git_string) or a_path.name.has_substring (dot_gitignore_string) then
				do_nothing -- .git is ignored.
			elseif a_path.name.has_substring (git_config_string) then
				do_nothing -- git config's are ignored.
			elseif a_path.name.has_substring (EIFGENs_string) then
				do_nothing -- EIFGENs are ignored.
			else
				create l_dir.make_with_path (a_path)
				across
					l_dir.entries as ic_entries
				loop
					if not (ic_entries.item.is_current_symbol or ic_entries.item.is_parent_symbol) then -- ignore "."/".." paths
						scan_path (create {PATH}.make_from_string (l_dir.name.out + a_path.directory_separator.out + ic_entries.item.name.out), a_level + 1)
					end
				end
			end
		end

feature {NONE} -- Implementation: Basic Operations: Parsing

	process_ecf (a_path: PATH)
			-- `process_ecf' found in `a_path'.
		local
			l_parent: DIRECTORY
			l_git_parent: DIRECTORY
			l_git_path: detachable PATH
			l_git_config_path: detachable PATH
			l_has_git: BOOLEAN
			l_has_git_config: BOOLEAN
		do
			create l_parent.make_with_path (a_path.parent)
			across
				l_parent.entries as ic_parent_entries
			until
				l_has_git
			loop
				if ic_parent_entries.item.name.has_substring (dot_git_string) and then not ic_parent_entries.item.name.has_substring (Dot_gitignore_string) then
					create l_git_path.make_from_string (l_parent.name.out + a_path.directory_separator.out + ic_parent_entries.item.name.out)
					l_has_git := attached l_git_path
					if l_has_git and then attached l_git_path then
						create l_git_parent.make_with_path (l_git_path)
						across
							l_git_parent.entries as ic_git_parent_entries
						until
							l_has_git_config
						loop
							if ic_git_parent_entries.item.name.has_substring (Git_config_string) then
								create l_git_config_path.make_from_string (l_git_parent.name.out + a_path.directory_separator.out + ic_git_parent_entries.item.name.out)
								l_has_git_config := attached l_git_config_path
							end
						end
					end
					check has_config: l_has_git_config and attached l_git_config_path end
				end
			end
			parse_ecf (a_path, l_git_path, l_git_config_path)
		end

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
			l_callbacks: IG_ECF_XML_CALLBACKS
			l_uuid: UUID
			l_is_computed_uuid: BOOLEAN
			l_ecf_library_dependencies: HASH_TABLE [attached like ecf_library_dependencies_data_anchor, STRING]
			seeding_integer: INTEGER
		do
			l_parser := (create {XML_PARSER_FACTORY}).new_parser
			create l_callbacks.make
			l_parser.set_callbacks (l_callbacks)
			l_parser.parse_from_path (a_last_ecf_path)

			if attached l_callbacks.last_system_name then
				if attached l_callbacks.last_uuid as al_uuid_string and then (create {UUID}).is_valid_uuid (al_uuid_string) then
					l_uuid := create {UUID}.make_from_string (al_uuid_string)
					l_is_computed_uuid := False
				else
					l_uuid := (create {RANDOMIZER}).uuid
					l_is_computed_uuid := True
				end
				across
					l_callbacks.libraries as ic_libs
				from
					seeding_integer := l_callbacks.libraries.count
					create l_ecf_library_dependencies.make (l_callbacks.libraries.count)
				invariant
					l_ecf_library_dependencies.count = l_callbacks.libraries.count - seeding_integer
				loop
					l_ecf_library_dependencies.put ([ic_libs.item.name,
														ic_libs.item.location,
														ic_libs.item.uuid,
														ic_libs.item.is_github,
														ic_libs.item.is_ise,
														ic_libs.item.is_local,
														ic_libs.item.is_computed_uuid], seeding_integer.out)
					seeding_integer := seeding_integer - 1
				variant
					seeding_integer
				end

				check same_count: l_callbacks.libraries.count = l_ecf_library_dependencies.count end

				ecf_libraries.force ([l_callbacks.attached_system_name,
										l_callbacks.targets,
										l_callbacks.last_test_target,
										l_ecf_library_dependencies.twin,
										l_is_computed_uuid,
										a_last_git_path,
										a_last_git_config_path,
										False,
										False,
										False,
										create {HASH_TABLE [READABLE_STRING_32, READABLE_STRING_32]}.make (Default_client_supplier_list_capacity),
										create {HASH_TABLE [READABLE_STRING_32, READABLE_STRING_32]}.make (Default_client_supplier_list_capacity)], l_uuid.out)
			end
		end

	identify_ecf_dependencies
			-- `identify_ecf_dependencies'.
		note
			design: "[
				Once the `scan_github' is complete (use a state machine), then
				we can begin the final step: Identifying ECF dependencies. This
				is the step where we ID if an ECF is a Trunk, Branch, or Leaf.
				
				The `ecf_libraries' data has a `library_dependencies' table. This
				table represents those that the ECF is dependent on. Scanning this
				table reveals:
				
				(1) A "$GITHUB" ECF dependency = NOT Trunk (e.g. Branch or Leaf)
					So--mark each `ecf_libraries' item with `is_trunk' as False,
					otherwise--True.
				(2) For each ECF in `ecf_libraries', scan for those that are: not `is_trunk'.
					Each of the not-trunk libraries can then have its UUID scanned for in the
					`library_dependencies' of the other ECF not-trunk libraries.
					ECFs that DO HAVE "my" UUID in their `library_dependencies' list
					means that "I" am an `is_branch' and not `is_leaf'.
				(3) At the end of the two cycles above, our `ecf_libraries' list will
					have data of: `is_trunk', `is_branch', and `is_leaf' that represents
					the relative position of the ECF in the heirarchy.
				(4) Moreover, each `ecf_libraries' item ought to have a list of:
					
						(4a) $GITHUB Supplier ECF libraries
						(4b) $GITHUB Client ECF libraries
					
					These lists can be validated (contracted/tested) against the
					flags: `is_trunk', `is_branch', and `is_leaf'.
				]"
			term: "Trunk ECF", "An ECF with only Supplier, but no Client $GITHUB-based ECFs."
			term: "Branch ECF", "An ECF with both Supplier and Client $GITHUB-based ECFs."
			term: "Leaf ECF", "An ECF with only Client, but no Supplier $GITHUB-based ECFs."
		do
			build_clients_list
			scan_and_mark
		end

	build_clients_list
			-- `build_clients_list' as `clients' on `ecf_libraries' and `add_supplier_to_client' for each client.
		do
			across
				ecf_libraries as ic_client
			loop
				across
					ic_client.item.supplier_libraries as ic_supplier
				loop
					if attached ic_supplier.item.uuid as al_supplier_uuid then
						add_supplier_to_client (ic_client.item.system_name, ic_client.key, al_supplier_uuid)
						add_supplier_to_client (ic_supplier.item.name, al_supplier_uuid, ic_client.key)
					else
						do_nothing -- non-attached = not GITHUB
					end
				end
			end
		end

	add_supplier_to_client (a_supplier_name, a_supplier_uuid, a_client_uuid: READABLE_STRING_32)
			-- `add_supplier_to_client' with `a_client' and `a_supplier' in `ecf_libraries' `suppliers' list.
		do
			check has_client: attached ecf_libraries.item (a_client_uuid) as al_client then
				al_client.suppliers.force (a_supplier_name, a_supplier_uuid)
			end
		end

	scan_and_mark
			-- `scan_and_mark'.
		note
			design: "[
				Each `ecf_libraries' item ought to now have a `clients' and `suppliers' list
				developed for them. So, finding those items with both some `clients' and
				some `suppliers' indicates a "branch".
				]"
		do
			across
				ecf_libraries as ic_ecf_libs
			loop
				ic_ecf_libs.item.is_branch := (ic_ecf_libs.item.clients.count > 0 and ic_ecf_libs.item.suppliers.count > 0)
				ic_ecf_libs.item.is_leaf := (ic_ecf_libs.item.clients.count = 0 and ic_ecf_libs.item.suppliers.count > 0)
				ic_ecf_libs.item.is_trunk := (ic_ecf_libs.item.clients.count = 0 and ic_ecf_libs.item.suppliers.count = 0)
					-- Logging ...
				logger.write_information ("--------------------------------")
				logger.write_information ("%T%T%T" + ic_ecf_libs.item.system_name)
				logger.write_information ("Clients:")
				across
					ic_ecf_libs.item.clients as ic_clients
				loop
					logger.write_information ("%T%T%T" + ic_clients.item)
				end
				logger.write_information ("Suppliers")
				across
					ic_ecf_libs.item.suppliers as ic_suppliers
				loop
					logger.write_information ("%T%T%T" + ic_suppliers.item)
				end
				logger.write_information ("--------------------------------")
			end
		end

feature {NONE} -- Implementation: Constants

	ecf_library_dependencies_data_anchor: detachable TUPLE [name, location: READABLE_STRING_32; uuid: detachable READABLE_STRING_32; is_github, is_ise, is_local, is_computed_uuid: BOOLEAN]
			-- `ecf_library_dependencies_data_anchor' for `ecf_library_dependencies'.

	default_ecf_libraries_capacity: INTEGER = 1000
			-- `default_ecf_libraries_capacity' is 1000.

	default_scanning_start_level: INTEGER = 0
			-- `default_scanning_start_level' is zero because 0 = root folder.

	Default_client_supplier_list_capacity: INTEGER = 500
			-- `Default_client_supplier_list_capacity' is 500.

end
