#SingleInstance Force

#Persistent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; V1:     finish at 2008-12-25
;;; V1.1:   finish at 2008-12-27
;;; V1.2:   finish at 2009-06-12
;;; V1.3:   finish at 2009-07-06
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; remark flag is ";"
;#Space::Var:=show_win_title()

;;; 更新图标
IfExist, time.ICO
{
	Menu TRAY, Icon, time.ICO
}

;;; 新建文件
log_file:="time_mamager_v2.csv"
IfNotExist, %log_file%
{
  log_title:="win_title,win_class,task_type,remain_interval,idle_interval,day,time"
  FileAppend, %log_title%`n, %log_file%
}

;;; Win+Space
;#Space::gosub, main

;;; ================================全局变量================================  ;;;
;使用时间
remain_time:=0

;闲置时间
idle_time:=0

;上一次窗口class
last_win_class:=

;当前窗口class
cur_win_class:=

;累计当前窗口下的idle时间(每10秒记录一次)
idle_record_count:=100

;shut dowm time handle flag.
is_check_shutdowmn_time:=0

;english time cancle time
englishi_time_cancle_time:=0


;;; ================================函数总入口================================  ;;;;;;;
main:
  last_win_class:=get_win_class()
  
  ;;; 定义定时器,0.1秒循环
  ;;; Step1: record windows use time,每0.1秒处理一下
  SetTimer,time_record_begin,500
  
	;;; Step2: check shutdown time;每10秒处理一下
	SetTimer,shutdown_time_begin,10000
	
	;;; Step3: check news time,每3秒处理一下
  SetTimer,news_time_begin,3000
  
  ;;; Step4: check english time,每3分钟处理一下
  SetTimer,check_english_time,1800000
  
  return

;;; timetree 处理函数
time_record_begin:  
	show_win_title()
	return

;;; shutdown_time 处理函数
shutdown_time_begin:
  check_shutdown_time()
  return

;;; news_time 处理函数
news_time_begin:
  check_news_time()
  return
  
;;; news_time 处理函数
check_english_time:
  check_english_time()
  return
  
;;; ================================Step1.record windows use time================================  ;;;;;;;
;;; 主体执行函数
show_win_title()
{
  global remain_time
  global idle_time
  
  global last_win_class
  global cur_win_class
  global cur_win_title
;  global idle_record_count
  
  ;;; 获取windows 标题
  cur_win_class:=get_win_class()
  cur_win_title:=get_win_title()
  
  if(last_win_class=cur_win_class)
  {
    remain_time:=remain_time+100
    
    idle_record_count:=idle_record_count-1
    
    if(idle_record_count=0)
    {
      idle_record_count:=100
      
      ;;; 如果idle值大于10秒，则意味着中当前的10秒都处在idle.
      if(%A_TimeIdlePhysical%>100*300)
      {
        idle_time:=idle_time+100*100
      }
      else
      {
        ;;; idle值小于10秒，则不计入idle.
        ; idle_time:=idle_time+%A_TimeIdlePhysical%
      }
    }
    
    ;;; 如果当前窗口停留的时间超过10分钟，则记录之.
    if(remain_time>600*1000)
    {
      save_log_to_file()
      reinit_data()
    }
  }
  
  ;;; 当发生窗口切换时，记录之.
  else
  {
    save_log_to_file()
    reinit_data()
  }
  
  ; cancel the timer.
  ; SetTimer,main,off
  
  return 0
}


;;; 初始化数据.保存当前数据后必须初始化.
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


;;; 获取windows标题
get_win_title()
{
	WinGetActiveTitle, title
	return title
}


;;; 获取windows类型
get_win_class()
{
  WinGetClass, win_class, A
	return win_class
}


;;; 保存数据
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

;; 获取当前任务类型
get_task_type(p_win_title,p_win_class)
{
;;; 最频繁. 放在最前面

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
  
  ;;; 对话框
  arm_string:="#32770"
  if (p_win_class=arm_string)
  {
    return "对话框"
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
  
;;; 较频繁

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
  
  ;;; 命令行
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

  ;;; 资源管理器
  arm_string:="ExploreWClass"
  if(p_win_class=arm_string)
  {
    return "资源管理器"
  }
  ;;; 资源管理器
  arm_string:="CabinetWClass"
  if(p_win_class=arm_string)
  {
    return "资源管理器"
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
  
;; 出现比较少的放在后面，加快查询速度.
  
  arm_string:="Windows 任务管理器"
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
  
  ;;; 其它
  return "Ohters"
}


;;; ================================Step2.record windows use time================================  ;;;;;;;
check_shutdown_time()
{
  global is_check_shutdowmn_time

  ;;; 关机时间
  shutdowm_hour:=23
  shutdowm_minute:=30
  
  if(is_check_shutdowmn_time=1)
  {
    if(A_Hour>=shutdowm_hour) and (A_Min=shutdowm_minute)
    {
      RunWait ,shutdown.exe /s /f /t 300 /c "计算机将于5分钟后关闭！本命令无法撤销！有必须完成的任务请马上开始。"
      is_check_shutdowmn_time:=1
    }
  }
}


;;; ================================Step3: check news time================================  ;;;;;;;
;;; 检测是否为浏览器
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

;;; 检测是否为新闻
check_is_news()
{
  is_news:=0
  is_browser:=check_is_brower()
  browser_title:=get_win_title()
  
  if(is_browser=1)
  {
    arm_string:="网易新闻"
    IfInString, browser_title, %arm_string%
    {
      is_news:=1
    }
		
    arm_string:="新浪网"
    IfInString, browser_title, %arm_string%
    {
      is_news:=1
    }
    
		arm_string:="凤凰网"
    IfInString, browser_title, %arm_string%
    {
      is_news:=1
    }
    
		arm_string:="八阕"
    IfInString, browser_title, %arm_string%
    {
      is_news:=1
    }
  }
  
  return is_news
}


;;; 如果是看新闻，而且又不在新闻时段，则关闭.
check_news_time()
{
  ;;; 新闻时间
  news_start:=21
  news_end:=22
  
  is_news:=check_is_news()

  if((is_news=1) and (A_Hour>=news_end))
  {
    Send ^w
		Msgbox,,新闻时段(晚上9点-10点), 非新闻时段不允许上新闻网站!
  }
}

;;; ================================Step3: check news time================================  ;;;;;;;
;;; 检测是否为英语时间
check_english_time()
{
  global englishi_time_cancle_time
  
  english_start:=22
  is_brower:=check_is_brower()
  
  if((is_brower=1) and (A_Hour>=english_start))
  {
		MsgBox, 4,你已经取消 %englishi_time_cancle_time% 次了!, 不要再上网了！开始学英语了! 是否关闭浏览器？
    IfMsgBox Yes
    {
      Send !{F4}
      Run D:\Good\MindMamager\我的背单词
    }
    else
    {
      englishi_time_cancle_time:=englishi_time_cancle_time+1
    }
  }
}
