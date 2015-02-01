#SingleInstance Force

#Persistent

;;; ����ͼ��
IfExist, time.ICO
{
	Menu TRAY, Icon, time.ICO
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; V1:     finish at 2008-12-25
;;; V1.1:   finish at 2008-12-27
;;; V1.2:   finish at 2009-06-12
;;; V1.3:   finish at 2009-07-06
;;; V1.4:   finish at 2009-08-06
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;��ݼ���
;#Space::Var:=show_win_title()

;;; �½��ļ�
log_file:="time_mamager_v2.csv"
IfNotExist, %log_file%
{
  log_title:="win_title,win_class,task_type,remain_interval,idle_interval,day,time"
  FileAppend, %log_title%`n, %log_file%
}


;;; ================================ȫ�ֱ���================================  ;;;
;ʹ��ʱ��
remain_time:=0

;����ʱ��
idle_time:=0

;��һ�δ���class
last_win_class:=

;��ǰ����class
cur_win_class:=

;�ۼƵ�ǰ�����µ�idleʱ��(ÿ10���¼һ��)
idle_record_count:=100

;shut dowm time handle flag.
is_check_shutdowmn_time:=0

;english time cancle time
englishi_time_cancle_time:=0


;;; ================================���������================================  ;;;;;;;
main:
  last_win_class:=get_win_class()
  
  ;;; ���嶨ʱ��,0.1��ѭ��
  ;;; Step1: record windows use time,ÿ0.1�봦��һ��
  SetTimer,time_record_begin,500
  
	;;; Step2: check shutdown time;ÿ10�봦��һ��
	SetTimer,shutdown_time_begin,10000
	
	;;; Step3: check news time,ÿ3�봦��һ��
  SetTimer,news_time_begin,3000
  
  ;;; Step4: check english time,ÿ3���Ӵ���һ��
  SetTimer,check_english_time,1800000
  
  return

;;; timetree ������
time_record_begin:  
	show_win_title()
	return

;;; shutdown_time ������
shutdown_time_begin:
  check_shutdown_time()
  return

;;; news_time ������
news_time_begin:
  check_news_time()
  return
  
;;; news_time ������
check_english_time:
  check_english_time()
  return
  
;;; ================================Step1.record windows use time================================  ;;;;;;;
;;; ����ִ�к���
show_win_title()
{
  global remain_time
  global idle_time
  
  global last_win_class
  global cur_win_class
  global cur_win_title
;  global idle_record_count
  
  ;;; ��ȡwindows ����
  cur_win_class:=get_win_class()
  cur_win_title:=get_win_title()
  
  if(last_win_class=cur_win_class)
  {
    remain_time:=remain_time+100
    
    idle_record_count:=idle_record_count-1
    
    if(idle_record_count=0)
    {
      idle_record_count:=100
      
      ;;; ���idleֵ����10�룬����ζ���е�ǰ��10�붼����idle.
      if(%A_TimeIdlePhysical%>100*300)
      {
        idle_time:=idle_time+100*100
      }
      else
      {
        ;;; idleֵС��10�룬�򲻼���idle.
        ; idle_time:=idle_time+%A_TimeIdlePhysical%
      }
    }
    
    ;;; �����ǰ����ͣ����ʱ�䳬��10���ӣ����¼֮.
    if(remain_time>600*1000)
    {
      save_log_to_file()
      reinit_data()
    }
  }
  
  ;;; �����������л�ʱ����¼֮.
  else
  {
    save_log_to_file()
    reinit_data()
  }
  
  ; cancel the timer.
  ; SetTimer,main,off
  
  return 0
}


;;; ��ʼ������.���浱ǰ���ݺ�����ʼ��.
reinit_data()
{
  global remain_time
  global idle_time
  
  global last_win_class
  global cur_win_class
  global last_win_title
  global cur_win_title
  
  last_win_class:=cur_win_class
  last_win_title:=cur_win_title
  
  remain_time:=0
  idle_time:=0
}


;;; ��ȡwindows����
get_win_title()
{
	WinGetActiveTitle, title
	return title
}


;;; ��ȡwindows����
get_win_class()
{
  WinGetClass, win_class, A
	return win_class
}


;;; ��������
save_log_to_file()
{
  global remain_time
  global idle_time
  global last_win_class
  global last_win_title
	global log_file
	
	remain_time_s:=remain_time/1000
  idle_time_s:=idle_time/1000
  cur_task_type:=get_task_type(last_win_title,last_win_class)
  
  FormatTime, DayString, ,yyyy-MM-dd
  FormatTime, TimeString, ,HH:mm:ss
  
	if (last_win_class<>"")
	{
	  log_record="%last_win_title%","%last_win_class%","%cur_task_type%",%remain_time_s%,%idle_time_s%,%DayString%,%TimeString%
	  
	  FileAppend, %log_record%`n, %log_file%
  }
}

;; ��ȡ��ǰ��������
get_task_type(p_win_title,p_win_class)
{
;;; ��Ƶ��. ������ǰ��

  ;;; Notes
  arm_string:="NOTES"
  if (p_win_class=arm_string)
  {
    return "Notes"
  }
  
  ;;; source insight
  arm_string:="si_Frame"
  if (p_win_class=arm_string)
  {
    return "Source Insight"
  }
  
  ;;; Total Commander
  arm_string:="TTOTAL_CMD"
  if (p_win_class=arm_string)
  {
    return "Total Commander"
  }
  
  ;;; EverNote
  arm_string:="EverNote"
  StringLeft win_title_sub,p_win_title,StrLen(arm_string)
  if (win_title_sub=arm_string)
  {
    return "EverNote"
  }
  
  ;;; EverNote
  arm_string:="EverNote"
  Stringright win_title_sub,p_win_title,StrLen(arm_string)
  if (win_title_sub=arm_string)
  {
    return "EverNote"
  }
  
  ;;; trace
  arm_string:="T32"
  if (p_win_class=arm_string)
  {
    return "Trace"
  }
  
  ;;; Beyond compare
  arm_string:="Beyond Compare"
  StringRight win_title_sub,p_win_title,StrLen(arm_string)
  if (win_title_sub=arm_string)
  {
    return "Beyond Compare"
  }

  ;;; Firefox GTD
  arm_string:="MozillaUIWindowClass"
  if (p_win_class=arm_string)
  {
    return "Beyond Compare"
  }
  
  ;;; �Ի���
  arm_string:="#32770"
  if (p_win_class=arm_string)
  {
    return "�Ի���"
  }
  
  ;;; pdf
  arm_string:="classFoxitReader"
  if (p_win_class=arm_string)
  {
    return "pdf"
  }
  
  ;;; Maxivista
  arm_string:="Maxivista_KeyboardA"
  if (p_win_class=arm_string)
  {
    return "Maxivista"
  }
  
  ;;; Notepad2
  arm_string:="Notepad2"
  if (p_win_class=arm_string)
  {
    return "Notepad2"
  }
  
;;; ��Ƶ��

  ;;; Beyond compare
  arm_string:="TDirectoryViewerForm"
  if (p_win_class=arm_string)
  {
    return "Beyond Compare"
  }
  
  ;;; Beyond compare
  arm_string:="TFileViewerForm"
  if (p_win_class=arm_string)
  {
    return "Beyond Compare"
  }
  
  ;;; ������
  arm_string:="ConsoleWindowClass"
  if (p_win_class=arm_string)
  {
    return "CMD"
  }

  ;;; UltraEdit
  arm_string:="UltraEdit"
  StringLeft win_title_sub,p_win_title,StrLen(arm_string)
  if (win_title_sub=arm_string)
  {
    return "UltraEdit"
  }

  ;;; word
  arm_string:="Microsoft Word"
  StringRight win_title_sub,p_win_title,StrLen(arm_string)
  if (win_title_sub=arm_string)
  {
    return "Word"
  }
  
  ;;; excel
  arm_string:="Microsoft Excel"
  StringLeft win_title_sub,p_win_title,StrLen(arm_string)
  if (win_title_sub=arm_string)
  {
    return "Excel"
  }
  
  ;;; ppt
  arm_string:="Microsoft PowerPoint"
  StringLeft win_title_sub,p_win_title,StrLen(arm_string)
  if (win_title_sub=arm_string)
  {
    return "ppt"
  }
  
  ;;; pdf
  arm_string:="Adobe Reader"
  StringRight win_title_sub,p_win_title,StrLen(arm_string)
  if (win_title_sub=arm_string)
  {
    return "pdf"
  }

  ;;; ��Դ������
  arm_string:="ExploreWClass"
  if(p_win_class=arm_string)
  {
    return "��Դ������"
  }
  ;;; ��Դ������
  arm_string:="CabinetWClass"
  if(p_win_class=arm_string)
  {
    return "��Դ������"
  }
  
    ;;; IE
  arm_string:="Microsoft Internet Explorer"
  StringRight win_title_sub,p_win_title,StrLen(arm_string)
  if (win_title_sub=arm_string)
  {
    return "IE"
  }
  
  ;;; QPST
  arm_string:="QPST"
  if (InStr(p_win_title, arm_string , true)>0)
  {
    return "QPST"
  }
  
  ;;; QXDM
  arm_string:="QXDM"
  if (InStr(p_win_title, arm_string , true)>0)
  {
    return "QXDM"
  }
  
;; ���ֱȽ��ٵķ��ں��棬�ӿ��ѯ�ٶ�.
  
  arm_string:="Windows ���������"
  if (p_win_title=arm_string)
  {
    return "system"
  }
  
  arm_string:="MMCMainFrame"
  if (p_win_class=arm_string)
  {
    return "system"
  }
  
  arm_string:="T32DIALOG"
  if (p_win_class=arm_string)
  {
    return "Trace"
  }
  
  arm_string:="Browse Project Symbols"
  if (p_win_title=arm_string)
  {
    return "Source Insight"
  }
 
  arm_string:="Lookup References"
  if (p_win_title=arm_string)
  {
    return "Source Insight"
  }
  
  arm_string:="Source Insight"
  if (p_win_title=arm_string)
  {
    return "Source Insight"
  }
  
  ;;; ����
  return "Ohters"
}


;;; ================================Step2.record windows use time================================  ;;;;;;;
check_shutdown_time()
{
  global is_check_shutdowmn_time

  ;;; �ػ�ʱ��
  shutdowm_hour:=23
  shutdowm_minute:=30
  
  if(is_check_shutdowmn_time=1)
  {
    if(A_Hour>=shutdowm_hour) and (A_Min=shutdowm_minute)
    {
      RunWait ,shutdown.exe /s /f /t 300 /c "���������5���Ӻ�رգ��������޷��������б�����ɵ����������Ͽ�ʼ��"
      is_check_shutdowmn_time:=1
    }
  }
}


;;; ================================Step3: check news time================================  ;;;;;;;
;;; ����Ƿ�Ϊ�����
check_is_brower()
{
  is_browser:=0
  browser_title:=get_win_title()
  
  arm_string:="Mozilla Firefox"
  StringRight win_title_sub,browser_title,StrLen(arm_string)
  if (win_title_sub=arm_string)
  {
		is_browser:=1
  }
    
  arm_string:="Microsoft Internet Explorer"
  StringRight win_title_sub,browser_title,StrLen(arm_string)
  if (win_title_sub=arm_string)
  {
		is_browser:=1
  }
  
  return  is_browser
}

;;; ����Ƿ�Ϊ����
check_is_news()
{
  is_news:=0
  is_browser:=check_is_brower()
  browser_title:=get_win_title()
  
  if(is_browser=1)
  {
    arm_string:="��������"
    IfInString, browser_title, %arm_string%
    {
      is_news:=1
    }
		
    arm_string:="������"
    IfInString, browser_title, %arm_string%
    {
      is_news:=1
    }
    
		arm_string:="�����"
    IfInString, browser_title, %arm_string%
    {
      is_news:=1
    }
    
		arm_string:="����"
    IfInString, browser_title, %arm_string%
    {
      is_news:=1
    }
  }
  
  return is_news
}


;;; ����ǿ����ţ������ֲ�������ʱ�Σ���ر�.
check_news_time()
{
  ;;; ����ʱ��
  news_start:=21
  news_end:=22
  
  is_news:=check_is_news()

  if((is_news=1) and (A_Hour>=news_end))
  {
    Send ^w
		Msgbox,,����ʱ��(����9��-10��), ������ʱ�β�������������վ!
  }
}

;;; ================================Step3: check news time================================  ;;;;;;;
;;; ����Ƿ�ΪӢ��ʱ��
check_english_time()
{
  global englishi_time_cancle_time
  
  english_start:=22
  is_brower:=check_is_brower()
  
  if((is_brower=1) and (A_Hour>=english_start))
  {
		MsgBox, 4,���Ѿ�ȡ�� %englishi_time_cancle_time% ����!, ��Ҫ�������ˣ���ʼѧӢ����! �Ƿ�ر��������
    IfMsgBox Yes
    {
      Send !{F4}
      Run D:\Good\MindMamager\�ҵı�����
    }
    else
    {
      englishi_time_cancle_time:=englishi_time_cancle_time+1
    }
  }
}

;;; ================================ startp run ================================  ;;;;;;;
;;; �����������(from "24.�����Զ����г�����ӳ����� Runlater")
#F12::
startup_run()
return

#F11::
MaxiVista_run()
return


startup_run()
{
	IfNotExist, startup.ini
	{
	 ini=%ini%[Settings]
	 ini=%ini%`nFolder=.`n `; ���ÿ�ݷ�ʽ����λ�ã�һ����.����ʾ��ݷ�ʽ�� ahk �ļ���һ��
	 ini=%ini%`nIsWait=0`n`; �������Ϊ 0 �Ļ���ʹ�� run ��������������ͣһ�£�����Ļ����� runwait ������������
	 ini=%ini%`nSleepTime=1`n`; �� IsWait=0 ʱ�������ã�����һ���������ͣ��ã���λ���롣
	 FileAppend, %ini%, startup.ini
	 ini=
	}

	IniRead, Folder, startup.ini, Settings, Folder_first
	IniRead, IsWait, startup.ini, Settings, IsWait
	IniRead, SleepTime, startup.ini, Settings, SleepTime

	SleepTime:=SleepTime*1000

	Loop, %Folder%\*.lnk
	{
	  if (InStr(A_LoopFileName, "MaxiVista" , true)=0)
	  {
	    run %Folder%\%A_LoopFileName%
		  tooltip %Folder%\%A_LoopFileName%
		  sleep %SleepTime%
    }
	}
	
	IniRead, Folder, startup.ini, Settings, Folder_second
	Loop, %Folder%\*.lnk
	{
	  run %Folder%\%A_LoopFileName%
		tooltip %Folder%\%A_LoopFileName%
		sleep %SleepTime%
	}
}

MaxiVista_run()
{
	IniRead, Folder, startup.ini, Settings, Folder_first

	Loop, %Folder%\*.lnk
	{
	  if (InStr(A_LoopFileName, "MaxiVista" , true)>0)
	  {
      this_year=%A_YYYY%
      this_time=2007%A_MM%%A_DD%%A_Hour%%A_Min%%A_Sec%
	    SetSystemTime(this_time)
	    
	    run %Folder%\%A_LoopFileName%
		  tooltip %Folder%\%A_LoopFileName%
		  sleep %SleepTime%
		  
			sleep 3000
			this_time=%this_year%%A_MM%%A_DD%%A_Hour%%A_Min%%A_Sec%
			SetSystemTime(this_time)
    }
	}
}

; ����ϵͳʱ��Ϊָ������ʱ�䣬���ñ���ȷ������Ĳ�����һ����Ч��ʱ���ʽ���ݣ�����ʱ�����ȫ��ʱ��)
; ����ֵΪ�����ʾ���óɹ�������Ϊʧ��
SetSystemTime(YYYYMMDDHHMISS)
{
	; ��ʱ������� local ת��Ϊ UTC �Ա� SetSystemTime() �����ܹ����� 
	UTC_Delta -= %A_NowUTC%, Seconds ; ��������ʹ����Ӿ�ȷ
	UTC_Delta := Round(-UTC_Delta/60) ; ��������ʹ�ָ��Ӿ�ȷ
	YYYYMMDDHHMISS += %UTC_Delta%, Minutes ; ��ʱ��ת��ΪUTC��ʽ
	VarSetCapacity(SystemTime, 16, 0) ; ����ṹ������ 8 �� UShorts ��ɣ���������Ϊ 8��2=16
	StringLeft, Int, YYYYMMDDHHMISS, 4 ; YYYY (��)
	NumPut(Int, SystemTime, 0, 2)
	StringMid, Int, YYYYMMDDHHMISS, 5, 2 ; MM (�·�, 1-12)
	NumPut(Int, SystemTime, 2, 2)
	StringMid, Int, YYYYMMDDHHMISS, 7, 2 ; DD (��)
	NumPut(Int, SystemTime, 6, 2)
	StringMid, Int, YYYYMMDDHHMISS, 9, 2 ; HH (Сʱ 0-23)
	NumPut(Int, SystemTime, 8, 2)
	StringMid, Int, YYYYMMDDHHMISS, 11, 2 ; MI (��)
	NumPut(Int, SystemTime, 10, 2)
	StringMid, Int, YYYYMMDDHHMISS, 13, 2 ; SS (��)
	NumPut(Int, SystemTime, 12, 2)
	return DllCall("SetSystemTime", UInt, &SystemTime)
}