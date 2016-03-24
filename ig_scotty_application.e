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
			if has_file_in_path ("git.exe") and has_file_in_path ("ec.exe") then
				scan
			else
				logger.write_error ("git.exe or ec.exe not in path.")
			end
		end

feature {NONE} -- Implementation

	scan
		local
			l_scanner: IG_ECF_SCANNER
			l_ecf: IG_ECF
			l_spinner: FW_DOS_SPINNER
			l_dos: FW_DOS_QUESTION_AND_ANSWER
			l_msg: STRING
		do
			create l_spinner; logger.write_information ("create FW_DOS_SPINNER")
			create l_dos; logger.write_information ("create FW_DOS_QUESTION_AND_ANSWER")
			create l_scanner; logger.write_information ("create IG_ECF_SCANNER")

			l_msg := "scanning ...%N"; print (l_msg); logger.write_information (l_msg)
			l_scanner.scan_github

			l_msg := "Projects with remote changes:%N"; print (l_msg); logger.write_information (l_msg)
			l_msg := "-----------------------------%N"; print (l_msg); logger.write_information (l_msg)
			across
				l_scanner.ecf_libraries as ic_ecfs
			loop
				ic_ecfs.item.git_fetch_dry_run; logger.write_information ("git_fetch_dry_run")
				if (ic_ecfs.item.is_trunk or ic_ecfs.item.is_branch or ic_ecfs.item.is_leaf) and then
						ic_ecfs.item.has_remote_github_changes
				then
					print ("%B")
					l_msg := ic_ecfs.item.name + "%T%T" + ic_ecfs.item.path.name; print ("%N" + l_msg + "%N"); logger.write_information (l_msg)
					l_msg := "%N" + ic_ecfs.item.attached_command_results + "%N"; print (l_msg)
					logger.write_information ("Git pull?")
					if l_dos.is_yes ("git pull") then
						l_msg := "Pulling ..."; print (l_msg + "%N"); logger.write_information (l_msg)
						ic_ecfs.item.git_pull
						l_msg := ic_ecfs.item.attached_command_results; print (l_msg + "%N"); logger.write_information (l_msg)
					else
						l_msg := "Selected `no-pull'."; print (l_msg + "%N"); logger.write_information (l_msg)
					end
				else
					print (l_spinner.next_prompt_with_text (ic_ecfs.item.name))
				end
			end
		end

end
