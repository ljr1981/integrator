note
	description: "Tests of {IG_ECF}."
	testing: "type/manual"

class
	IG_ECF_TEST_SET

inherit
	EQA_TEST_SET
		rename
			assert as assert_old
		end

	EQA_COMMONLY_USED_ASSERTIONS
		undefine
			default_create
		end

	TEST_SET_BRIDGE
		undefine
			default_create
		end

	IG_ANY
		undefine
			default_create
		end

	IG_CONSTANTS
		undefine
			default_create
		end

feature -- Test routines

	ig_ecf_client_supplier_tests
			-- New test routine
		do
			mock_leaf.do_nothing
			mock_branch.do_nothing
			mock_branch.set_possible_client (mock_leaf)
			mock_trunk.do_nothing
			mock_trunk.set_possible_client (mock_branch)
			assert_strings_equal ("mock_leaf", mock_leaf_out, mock_leaf.out)
			assert_strings_equal ("mock_branch", mock_branch_out, mock_branch.out)
			assert_strings_equal ("mock_trunk", mock_trunk_out, mock_trunk.out)
		end

	ig_ecf_compile_test
			-- `ig_ecf_compile_test'.
		note
			testing: "execution/serial"
		do
			mock_for_compile.compile
		end

	ig_ecf_freeze_test
			-- `ig_ecf_freeze_test'.
		note
			testing: "execution/serial"
		do
			mock_for_compile.freeze ("test")
		end

feature {NONE} -- Implementation: Mocks

	mock_for_compile: IG_ECF
			-- `mock_for_compile' tests.
		do
			Result := (create {IG_ECF_FACTORY}).new_ecf_from_file (mock_path)
		end

	mock_eifgens_directory: DIRECTORY
		do
			create Result.make_with_path (mock_eifgens_path)
		end

	mock_path: PATH
		do
			create Result.make_from_string (github_path.name + "\ig_test_project\ig_test_project.ecf")
		end

	mock_eifgens_path: PATH
		do
			create Result.make_from_string (mock_path.parent.name + "\EIFGENs")
		end

	mock_leaf_out: STRING = "[
Name: ecf_leaf
Path: $GITHUB\ecf_leaf
UUID: 1899B6CC-17B2-B137-9900-00003F4D0001

Clients:


Suppliers:

	Name: ecf_branch
	Path: $GITHUB\ecf_branch
	UUID: 1899B6CC-17B2-B137-9900-00003F4D0002

]"

	mock_branch_out: STRING = "[
Name: ecf_branch
Path: $GITHUB\ecf_branch
UUID: 1899B6CC-17B2-B137-9900-00003F4D0002

Clients:

	Name: ecf_leaf
	Path: $GITHUB\ecf_leaf
	UUID: 1899B6CC-17B2-B137-9900-00003F4D0001

Suppliers:

	Name: ecf_trunk
	Path: $GITHUB\ecf_trunk
	UUID: 1899B6CC-17B2-B137-9900-00003F4D0003

]"

	mock_trunk_out: STRING = "[
Name: ecf_trunk
Path: $GITHUB\ecf_trunk
UUID: 1899B6CC-17B2-B137-9900-00003F4D0003

Clients:

	Name: ecf_branch
	Path: $GITHUB\ecf_branch
	UUID: 1899B6CC-17B2-B137-9900-00003F4D0002

Suppliers:


]"

	mock_leaf: IG_ECF
		once
			create Result
			Result.set_name ("ecf_leaf")
			Result.set_path (create {PATH}.make_from_string ("$GITHUB\ecf_leaf"))
			Result.set_uuid (create {UUID}.make_from_string ("1899B6CC-17B2-B137-9900-00003F4D0001"))
			across supplier_list_1 as ic_list loop Result.suppliers.force (ic_list.item, ic_list.item.uuid.out) end
		end

	mock_branch: IG_ECF
		once
			create Result
			Result.set_name ("ecf_branch")
			Result.set_path (create {PATH}.make_from_string ("$GITHUB\ecf_branch"))
			Result.set_uuid (create {UUID}.make_from_string ("1899B6CC-17B2-B137-9900-00003F4D0002"))
			across supplier_list_2 as ic_list loop Result.suppliers.force (ic_list.item, ic_list.item.uuid.out) end
		end

	mock_trunk: IG_ECF
		once
			create Result
			Result.set_name ("ecf_trunk")
			Result.set_path (create {PATH}.make_from_string ("$GITHUB\ecf_trunk"))
			Result.set_uuid (create {UUID}.make_from_string ("1899B6CC-17B2-B137-9900-00003F4D0003"))
		end

	supplier_list_1: attached like {IG_ECF}.list_anchor
		once
			create Result.make (1)
			Result.force (mock_branch, mock_branch.uuid.out)
		end

	supplier_list_2: attached like {IG_ECF}.list_anchor
		once
			create Result.make (1)
			Result.force (mock_trunk, mock_trunk.uuid.out)
		end

end


