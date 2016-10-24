#!/bin/bash
#iOS crash log 分析文件

#设置全局环境变量
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
#crash的app的名字
app_name=$1
#引入crash文件名字
import_crash_file_name=${app_name}.crash
#引入dSYM文件名字
import_dSYM_file_name=${app_name}.app.dSYM
#输出crash文件名字
export_crash_file_name=${app_name}_symboled.crash

#查找并复制symbolicatecrash文件
test -f ./symbolicatecrash  || (echo '查找复制symbolicatecrash文件';find /Applications/Xcode.app -name symbolicatecrash -type f -exec cp {} . \;)

#判断是否copy成功
test -f ./symbolicatecrash  || (echo 'symbolicatecrash文件不存在';exit 1)

echo "复制成功,开始分析"
#对crash文件进行符号化处理

echo 'import_crash_file_name='$import_crash_file_name
echo 'import_dSYM_file_name='$import_dSYM_file_name
echo 'export_crash_file_name='$export_crash_file_name

./symbolicatecrash $import_crash_file_name $import_dSYM_file_name > $export_crash_file_name

######################################################################################################
#用atos命令来符号化某个特定模块加载地址
#命令是：
#atos [-o AppName.app/AppName] [-l loadAddress] [-arch architecture]
#
#亲测，下面3种都可以：
#xcrun atos -o appName.app.dSYM/Contents/Resources/DWARF/appName -l 0x4000 -arch armv7
#xcrun atos -o appName.app.dSYM/Contents/Resources/DWARF/appName -arch armv7
#xcrun atos -o appName.app/appName -arch armv7
#（注：这3行选任意一行执行都可以达到目的，其中0x4000是模块的加载地址，从上面的章节可以找到如何得到这个地址。）
#
#文章开头提到crash文件中有如下两行，
#* 3 appName 0x000f462a 0x4000 + 984618
#* 4 appName **0x00352aee** 0x4000 + 3468014
#
#在执行了上面的：
#xcrun atos -o appName.app.dSYM/Contents/Resources/DWARF/appName -l 0x4000 -arch armv7
#
#之后，输入如下地址：
#0x00352aee
#
#（crash文件中的第4行：4 appName **0x00352aee** 0x4000 + 3468014）
#
#可以得到结果：
#-[UIScrollView(UITouch) touchesEnded:withEvent:] (in appName) (UIScrollView+UITouch.h:26)
######################################################################################################
