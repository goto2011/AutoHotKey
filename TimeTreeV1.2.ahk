#SingleInstance Force

#Persistent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; V1:     finish at 2008-12-25
;;; V1.1:   finish at 2008-12-27
;;; V1.2:   finish at 2009-06-12
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; remark flag is ";"
;#Space::Var:=show_win_title()

;;; ����ͼ��
IfExist, time.ICO
{
	Menu TRAY, Icon, time.ICO
}

;;; �½��ļ�
log_file:="time_mamager_v2.csv"
IfNotExist, %log_file%
{
  log_title:="win_title,win_class,task_type,remain_interval,idle_interval,day,time"
  FileAppend, %log_title%`n, %log_file%
}

;;; Win+Space
;#Space::gosub, main

;;; ȫ�ֱ���
remain_time:=0
idle_time:=0
last_win_class:=
cur_win_class:=
;;; �ۼƵ�ǰ�����µ�idleʱ��(ÿ10���¼һ��)
idle_record_count:=100

;;; �����
main:
  last_win_class:=get_win_class()
  
  ;;; ���嶨ʱ��,0.1��ѭ��
  SetTimer,time_record_begin,100
  return


time_record_begin:
	result:=show_win_title()
	return


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
    
    if(idle_record_count:=0)
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
  arm_sting:="NOTES"
  if (p_win_class=arm_sting)
  {
    return "Notes"
  }
  
  ;;; source insight
  arm_sting:="si_Frame"
  if (p_win_class=arm_sting)
  {
    return "Source Insight"
  }
  
  ;;; Total Commander
  arm_sting:="TTOTAL_CMD"
  if (p_win_class=arm_sting)
  {
    return "Total Commander"
  }
  
  ;;; EverNote
  arm_sting:="EverNote"
  StringLeft win_title_sub,p_win_title,StrLen(arm_sting)
  if (win_title_sub=arm_sting)
  {
    return "EverNote"
  }
  
  ;;; EverNote
  arm_sting:="EverNote"
  Stringright win_title_sub,p_win_title,StrLen(arm_sting)
  if (win_title_sub=arm_sting)
  {
    return "EverNote"
  }
  
  ;;; trace
  arm_sting:="T32"
  if (p_win_class=arm_sting)
  {
    return "Trace"
  }
  
  ;;; Beyond compare
  arm_sting:="Beyond Compare"
  StringRight win_title_sub,p_win_title,StrLen(arm_sting)
  if (win_title_sub=arm_sting)
  {
    return "Beyond Compare"
  }

  ;;; Firefox GTD
  arm_sting:="MozillaUIWindowClass"
  if (p_win_class=arm_sting)
  {
    return "Beyond Compare"
  }
  
  ;;; �Ի���
  arm_sting:="#32770"
  if (p_win_class=arm_sting)
  {
    return "�Ի���"
  }
  
  ;;; pdf
  arm_sting:="classFoxitReader"
  if (p_win_class=arm_sting)
  {
    return "pdf"
  }
  
  ;;; Maxivista
  arm_sting:="Maxivista_KeyboardA"
  if (p_win_class=arm_sting)
  {
    return "Maxivista"
  }
  
  ;;; Notepad2
  arm_sting:="Notepad2"
  if (p_win_class=arm_sting)
  {
    return "Notepad2"
  }
  
;;; ��Ƶ��

  ;;; Beyond compare
  arm_sting:="TDirectoryViewerForm"
  if (p_win_class=arm_sting)
  {
    return "Beyond Compare"
  }
  
  ;;; Beyond compare
  arm_sting:="TFileViewerForm"
  if (p_win_class=arm_sting)
  {
    return "Beyond Compare"
  }
  
  ;;; ������
  arm_sting:="ConsoleWindowClass"
  if (p_win_class=arm_sting)
  {
    return "CMD"
  }

  ;;; UltraEdit
  arm_sting:="UltraEdit"
  StringLeft win_title_sub,p_win_title,StrLen(arm_sting)
  if (win_title_sub=arm_sting)
  {
    return "UltraEdit"
  }

  ;;; word
  arm_sting:="Microsoft Word"
  StringRight win_title_sub,p_win_title,StrLen(arm_sting)
  if (win_title_sub=arm_sting)
  {
    return "Word"
  }
  
  ;;; excel
  arm_sting:="Microsoft Excel"
  StringLeft win_title_sub,p_win_title,StrLen(arm_sting)
  if (win_title_sub=arm_sting)
  {
    return "Excel"
  }
  
  ;;; ppt
  arm_sting:="Microsoft PowerPoint"
  StringLeft win_title_sub,p_win_title,StrLen(arm_sting)
  if (win_title_sub=arm_sting)
  {
    return "ppt"
  }
  
  ;;; pdf
  arm_sting:="Adobe Reader"
  StringRight win_title_sub,p_win_title,StrLen(arm_sting)
  if (win_title_sub=arm_sting)
  {
    return "pdf"
  }

  ;;; ��Դ������
  arm_sting:="ExploreWClass"
  if(p_win_class=arm_sting)
  {
    return "��Դ������"
  }
  ;;; ��Դ������
  arm_sting:="CabinetWClass"
  if(p_win_class=arm_sting)
  {
    return "��Դ������"
  }
  
    ;;; IE
  arm_sting:="Microsoft Internet Explorer"
  StringRight win_title_sub,p_win_title,StrLen(arm_sting)
  if (win_title_sub=arm_sting)
  {
    return "IE"
  }
  
  ;;; QPST
  arm_sting:="QPST"
  if (InStr(p_win_title, arm_sting , true)>0)
  {
    return "QPST"
  }
  
  ;;; QXDM
  arm_sting:="QXDM"
  if (InStr(p_win_title, arm_sting , true)>0)
  {
    return "QXDM"
  }
  
;; ���ֱȽ��ٵķ��ں��棬�ӿ��ѯ�ٶ�.
  
  arm_sting:="Windows ���������"
  if (p_win_title=arm_sting)
  {
    return "system"
  }
  
  arm_sting:="MMCMainFrame"
  if (p_win_class=arm_sting)
  {
    return "system"
  }
  
  arm_sting:="T32DIALOG"
  if (p_win_class=arm_sting)
  {
    return "Trace"
  }
  
  arm_sting:="Browse Project Symbols"
  if (p_win_title=arm_sting)
  {
    return "Source Insight"
  }
 
  arm_sting:="Lookup References"
  if (p_win_title=arm_sting)
  {
    return "Source Insight"
  }
  
  arm_sting:="Source Insight"
  if (p_win_title=arm_sting)
  {
    return "Source Insight"
  }
  
  ;;; ����
  return "Ohters"
}
