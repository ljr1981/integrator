note
	description: "[
		Representation of a root application as {IG_SCOTTY_APPLICATION}
		]"

class
	IG_SCOTTY_APPLICATION

inherit
	ARGUMENTS

	IG_ANY

	FW_PROCESS_HELPER

create
	make

feature {NONE} -- Initialization

	make
			-- `make' initialization.
		do
			scan
		end

feature {NONE} -- Implementation

	scan
		local
			l_scanner: IG_ECF_SCANNER
			l_ecf: IG_ECF
			l_msg: STRING
		do
			create l_scanner

			l_msg := "scanning ...%N"; print (l_msg)
			l_scanner.scan_github

			l_msg := "%NProjects with remote changes:%N"; print (l_msg)
			l_msg := "-----------------------------%N"; print (l_msg)
			across
				l_scanner.ecf_libraries as ic_ecfs
			loop
				if (ic_ecfs.item.is_trunk or ic_ecfs.item.is_branch or ic_ecfs.item.is_leaf) then
					ic_ecfs.item.git_fetch_dry_run
					if ic_ecfs.item.has_remote_github_changes then
						print ("%B")
						l_msg := ic_ecfs.item.name + "%T%T" + ic_ecfs.item.path.name; print ("%N" + l_msg + "%N")
					end
				else
					print ('.')
				end
				print ('.')
			end
			l_msg := "%NProjects with local changes:%N"; print (l_msg)
			l_msg := "-----------------------------%N"; print (l_msg)
			across
				l_scanner.ecf_libraries as ic_ecfs
			loop
				ic_ecfs.item.github_status
				if (ic_ecfs.item.is_trunk or ic_ecfs.item.is_branch or ic_ecfs.item.is_leaf) and then
					ic_ecfs.item.has_local_git_changes
				then
					print ("%B")
					if ic_ecfs.item.has_remote_github_changes then
						l_msg := ic_ecfs.item.name + "%T%T" + ic_ecfs.item.path.name; print ("%N" + l_msg + "%N")
					end
				else
					print ('.')
				end
				print ('.')
			end
			print ("%B")
		end

end
