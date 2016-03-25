note
	description: "[
		Representation of an ECF with Clients and Suppliers ECFs.
		]"

class
	IG_ECF

inherit
	IG_ANY
		redefine
			out
		end

	GH_COMMANDS
		rename
			command_path as path
		undefine
			out
		redefine
			path
		end

create
	make

feature {NONE} -- Initialization

	make
			-- `make' Current.
		do
			set_git_exe_path
		end

feature -- Access

	name: STRING
			-- `ecf_name' of Current {IG_ECF}.
		attribute
			create Result.make_empty
		end

	description: STRING
			-- `description' of Current {IG_ECF}.
		attribute
			create Result.make_empty
		end

	path: PATH
			-- `ecf_path' to `ecf_name' of Current {IG_ECF}.
		attribute
			create Result.make_empty
		end

	github_path:  PATH
			-- `github_path' of Current {IG_ECF}.
		attribute
			create Result.make_empty
		end

	github_config_path:  PATH
			-- `github_config_path' of Current {IG_ECF}.
		attribute
			create Result.make_empty
		end

	uuid: UUID
			-- `uuid' of Current {IG_ECF}.
		attribute
			create Result
		end

	clients: attached like list_anchor
			-- `clients' of Current {IG_ECF}.
		note
			design: "[
				These are loaded by the `set_possible_client' feature
				below. Please see its "notes" part for more information.
				]"
		attribute
			create Result.make (10)
		end

	suppliers: attached like list_anchor
			-- `suppliers' of Current {IG_ECF}.
		note
			design: "[
				These are loaded from the ECF XML specification.
				]"
		attribute
			create Result.make (10)
		end

	targets: ARRAYED_LIST [STRING]
			-- `targets' found in Current {IG_ECF}.
		attribute
			create Result.make (10)
		end

feature -- Settings

	set_name (a_item: like name)
			-- `set_name' with `a_item'.
		do
			name := a_item
		end

	set_description (a_item: like description)
			-- `set_description' with `a_item'.
		do
			description := a_item
		end

	set_path (a_item: like path)
			-- `set_path' with `a_item'.
		do
			path := a_item
		end

	set_github_path (a_item: like github_path)
			-- `set_github_path' with `a_item'.
		do
			github_path := a_item
		end

	set_github_config_path (a_item: like github_config_path)
			-- `set_github_config_path' with `a_item'.
		do
			github_config_path := a_item
		end

	set_uuid (a_item: like uuid)
			-- `set_uuid' with `a_item'.
		do
			uuid := a_item
		end

	set_possible_client (a_possible_client: IG_ECF)
			-- `set_possible_client' from `a_possible_client'.
		note
			design: "[
				Suppliers are already defined in the ECF file. Our list of
				`suppliers' is built from the data in the ECF.
				
				From there, `a_possible_client' is passed in. We look on
				`a_possible_client's `suppliers' list to see if we are on it.
				If so, we put `a_possible_client' on our list of `clients'.
				]"
		do
			if attached uuid as al_supplier_uuid and then attached al_supplier_uuid.out as al_supplier_uuid_string and then
				attached a_possible_client.suppliers as al_possible_client_suppliers
			then
				across
					al_possible_client_suppliers as ic_possible_client_suppliers
				loop
					if attached ic_possible_client_suppliers.item.uuid as al_possible_client_suppliers_uuid and then
						al_possible_client_suppliers_uuid.out.same_string (al_supplier_uuid_string)
					then
						clients.force (a_possible_client, a_possible_client.uuid.out)
					end
				end
			end
		end

feature -- Status Report

	is_github_based: BOOLEAN
			-- `is_github_based'?
		do
			Result := (create {DIRECTORY}.make_with_path (github_path)).exists
		end

	has_github_suppliers: BOOLEAN
			-- `has_github_suppliers'?
		do
			Result := is_github_based and then not across suppliers as ic_suppliers some ic_suppliers.item.is_github_based end
		end

	has_github_clients: BOOLEAN
			-- `has_github_clients'?
		do
			Result := is_github_based and then across clients as ic_clients some ic_clients.item.is_github_based end
		end

	is_trunk: BOOLEAN
		do
			Result := is_github_based and then (not has_github_suppliers and then has_github_clients)
		end

	is_branch: BOOLEAN
		do
			Result := is_github_based and then (has_github_suppliers and has_github_clients)
		end

	is_leaf: BOOLEAN
			-- `is_branch'?
		do
			Result := is_github_based and then (has_github_suppliers and not has_github_clients)
		end

feature -- Basic Operations

	compile
			-- `compile' F7.
		do
--			create l_cmd_line.make_empty
--			l_cmd_line.append_string ("cd " + path.name + "%N")
--			l_cmd_line.append_string ("del eifgens /F /Q%N")
--			l_cmd_line.append_string ("rmdir eifgens /S /Q%N")
--			l_cmd_line.append_string ("git pull%N")
--			across
--				targets as ic_targets
--			loop
--				l_cmd_line.append_string ("ec -config " + name + ".ecf -target " + ic_targets.item + "%N")
--				l_cmd_line.append_string ("cd " + path.name + "\EIFGENs\" + ic_targets.item + "\W_code%N")
--				l_cmd_line.append_string ("finish_freezing%N")
--				l_cmd_line.append_string ("cd " + path.name + "%N")
--			end
--			l_cmd_line.append_string ("dir%N")

--			create l_cmd.make_create_read_write (path.name + "\compile_" + name + ".cmd")
--			l_cmd.put_string (l_cmd_line.out)
--			l_cmd.flush
--			l_cmd.close
		end

	find_added_classes_and_recompile
			-- `find_added_classes_and_recompile' Alt + F8.
		do
			do_nothing -- yet ...
		end

	recompile_overrides
			-- `recompile_overrides' Shift + F8.
		do
			do_nothing -- yet ...
		end

	freeze (a_target: STRING)
			-- `freeze' Ctrl + F7.
		do
			do_nothing -- yet ...
		end

	finalize
			-- `finalize' Ctrl + Shift + F7.
		do
			do_nothing -- yet ...
		end

feature -- Outputs

	out: STRING_8
			-- <Precursor>
		do
			create Result.make_empty
			Result.append_string ("Name: ")
			Result.append_string (name)
			Result.append_character ('%N')

			Result.append_string ("Path: ")
			Result.append_string (path.name.out)
			Result.append_character ('%N')

			Result.append_string ("UUID: ")
			Result.append_string (uuid.out)
			Result.append_character ('%N')
			Result.append_character ('%N')

			Result.append_string ("Clients:")
			Result.append_character ('%N')
			Result.append_character ('%N')
			if attached clients as al_item and then al_item.count > 0  then
				across
					clients as ic_clients
				loop
					Result.append_character ('%T')
					Result.append_string ("Name: ")
					Result.append_string (ic_clients.item.name.out)
					Result.append_character ('%N')

					Result.append_character ('%T')
					Result.append_string ("Path: ")
					Result.append_string (ic_clients.item.path.name.out)
					Result.append_character ('%N')

					Result.append_character ('%T')
					Result.append_string ("UUID: ")
					Result.append_string (ic_clients.item.uuid.out)
					Result.append_character ('%N')
				end
			end

			Result.append_character ('%N')
			Result.append_string ("Suppliers:")
			Result.append_character ('%N')
			Result.append_character ('%N')
			if attached suppliers as al_item and then al_item.count > 0  then
				across
					suppliers as ic_suppliers
				loop
					Result.append_character ('%T')
					Result.append_string ("Name: ")
					Result.append_string (ic_suppliers.item.name.out)
					Result.append_character ('%N')

					Result.append_character ('%T')
					Result.append_string ("Path: ")
					Result.append_string (ic_suppliers.item.path.name.out)
					Result.append_character ('%N')

					Result.append_character ('%T')
					Result.append_string ("UUID: ")
					Result.append_string (ic_suppliers.item.uuid.out)
					Result.append_character ('%N')
				end
			end
		end

feature {NONE} -- Implementation: Anchors

	list_anchor: detachable HASH_TABLE [IG_ECF, STRING]
			-- `list_anchor' for `clients' and `suppliers'.

end
