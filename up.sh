# deploy_hexo.sh
cd \H:\Obsidian_Blog
pwd
# 白底黑字效果
echo -e "\033[47;30m>>>>>>>>>>>>>>>>>>>>hexo g<<<<<<<<<<<<<<<<<<<<\033[0m"
hexo g
echo -e "\033[47;30m>>>>>>>>>>>>>>>>>>>>hexo d<<<<<<<<<<<<<<<<<<<<\033[0m"
hexo d
sleep 5
# 执行完毕不退出
# exec /bin/bash
