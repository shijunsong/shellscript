#!/bin/bash

####
####  解析命令参数
####

# 解析命令参数函数
PARSE_PARAMS() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --active-env=*)
                ACTIVE_ENV="${1#*=}"
                ;;
            --commit-version=*)
                COMMIT_VERSION="${1#*=}"
                ;;
            --help)
                SHOW_HELP
                exit 0
                ;;
            *)
                echo "未知参数: $1"
                exit 1
                ;;
        esac
        shift
    done
}

# 命令Help函数
SHOW_HELP() {
    echo "使用方法: $0 [选项]"
    echo "选项:"
    echo "  --active-env=ENV            执行环境"
    echo "  --commit-version=VERSION    提交版本号"
    echo "  --help                      显示帮助信息"
}

# 解析命令函数执行
PARSE_PARAMS "$@"


####
####  判断传入参数是否合法
####

# 传入的参数值
ACTIVE_ENV=""
COMMIT_VERSION=""

# 判断传入参数是否合法(环境只支持qa2、uatstable环境)
if [ "$ACTIVE_ENV" = "qa2" ] || [ "$ACTIVE_ENV" = "uatstable" ]; then
    echo ">>>> 参数1: active-env=[$ACTIVE_ENV]"
else
    echo ">>>> 参数1：active-env=[$ACTIVE_ENV]不支持"
    exit 1
fi

# 判断提交版本号是否合法, 去除所有空白字符后判断
if [ -z "$(echo -e "$COMMIT_VERSION" | tr -d '[:space:]')" ]; then
    echo ">>>> 参数2：commit-version不允许为空白"
    exit 1
else
    echo ">>>> 参数2：commit-version=[$COMMIT_VERSION]"
fi

####
####  使用上传jar文件
####

# 1.使用rz命令上传jar文件
read -p ">>>>>> 是否上传jar文件[Y/N] " enter
if [ "$(echo $enter | tr '[:upper:]' '[:lower:]')" = "y" ]; then
    echo ">>>> 0.清理[jar_name*.jar]文件"
    rm -f ./<jar_name>*.jar
    echo ">>>> 1.开始上传jar文件……"
    rz -be
    # 检查上传结果
    if [ $? -eq 0 ]; then
        echo ">>>>>> jar文件上传成功。"
    else
        echo ">>>>>> jar文件上传失败，操作退出。"
        exit 1
    fi
fi

####
####  使用上传jar文件
####

# 2.登录harbor
HARBOR_DOMAIN=<harbor domain>
HARBOR_USER=<harbor user>
HARBOR_PWD=<harbor pwd>

sudo docker login -u $HARBOR_USER -p $HARBOR_PWD $HARBOR_DOMAIN
echo ">>>> 2.harbor登录成功!"

####
####  镜像构建 & 推送
####

# 3.构建镜像 & 推送
CURRENT_DATE=$(date +"%Y%m%d")

GIT_COMMIT_VERSION=$COMMIT_VERSION
IMAGE_PATH=$HARBOR_DOMAIN/qa2
IMAGE_NAME=<demo_image>
IMAGE_VERSION=$CURRENT_DATE-$GIT_COMMIT_VERSION
FULL_IMAGE_PATH=$IMAGE_PATH/$IMAGE_NAME:$IMAGE_VERSION

sudo docker build -t $FULL_IMAGE_PATH .
echo ">>>> 3.镜像[$FULL_IMAGE_PATH]构建成功。"
sudo docker push $FULL_IMAGE_PATH
echo ">>>> 4.镜像[$FULL_IMAGE_PATH]推送成功。"

####
#### 验证多次数的选择项
####
# echo -e ">>>>\n 5.请选择要发布的环境："
# echo "[1] QA2"
# echo "[2] UAT"
# echo "[0] 退出"
# 
# read -p ">>>>>> 请首次输入选项编号[0-2]: " choice
# read -p ">>>>>> 请再次输入选项编号[0-2]: " choice1
# if [ $choice -eq $choice1 ]; then
# else
#     echo ">>>>>> 两次输入不一致，操作退出。"
#     exit 1
# fi

####
#### 带超时选择项
####
# local timeout=10
# while true; do
# 	echo "请在 $timeout 秒内选择："
# 	echo "1) 选项1"
# 	echo "2) 选项2"
# 	echo "0) 退出"
# 	
# 	read -t $timeout -p "请选择 [0-2]: " choice
# 	
# 	if [ $? -eq 142 ]; then
# 		echo -e "\n超时，使用默认选项"
# 		choice=1
# 	fi
# 	
# 	case "$choice" in
# 		1|2)
# 			echo "选择了选项 $choice"
# 			;;
# 		0)
# 			echo "退出"
# 			exit 0
# 			;;
# 		*)
# 			echo "无效选项，请重新选择"
# 			continue
# 			;;
# 	esac
# 	break
# done


#### 5. 确认执行
read -p ">>>>>> 5.是否确认发布[$ACTIVE_ENV]环境?[Y/N] " comfirm
if [ "$(echo $comfirm | tr '[:upper:]' '[:lower:]')" = "n" ]; then
    echo ">>>>>> 操作终止退出。"
    exit 1
fi

####
####  开始执行发布过程
####

JAR_NAME=$IMAGE_NAME.jar
JAR_DIR=/opt/flink/usrlib
FLINK_DIR=/home/ubuntu/flink-1.14.2
DEPLOY_SCRIPT=""
case $ACTIVE_ENV in
	qa2)
        DEPLOY_SCRIPT=""
        ;;
	uatstable)
        DEPLOY_SCRIPT=""
        ;;
	0)
        echo ">>>> 6.程序退出"
        exit 0
        ;;
	*)
        echo ">>>> 6.无效的选项，程序退出！"
        exit 0
        ;;
esac

# 切换root 用户
echo ">>>> 7. 进入ROOT用户环境"
sudo su << EOF
$DEPLOY_SCRIPT
EOF
# 退出root用户
echo ">>>> 退出ROOT用户环境"
echo ">>>> 8. 部署结束"
exit
