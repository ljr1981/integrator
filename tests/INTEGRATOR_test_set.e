note
	description: "Tests of {INTEGRATOR}."
	testing: "type/manual"

class
	INTEGRATOR_TEST_SET

inherit
	EQA_TEST_SET
		rename
			assert as assert_old
		end

	EQA_COMMONLY_USED_ASSERTIONS
		undefine
			default_create
		end

feature -- Test routines

	integrator_tests
			-- `integrator_tests'
		local
			l_projects: IG_ECF_SCANNER
			l_github_count: INTEGER
		do
			create l_projects
			l_projects.scan_github
			assert_integers_equal ("has_130_you_may_have_more_or_less", 130, l_projects.ecf_libraries.count)
			across
				l_projects.ecf_libraries as ic_ecf
			loop
				if attached ic_ecf.item.github_path then
					l_github_count := l_github_count + 1
				end
			end
			assert_integers_equal ("has_x_githubs", 0, l_github_count)
		end

end
