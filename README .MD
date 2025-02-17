# 1. 脚本适用场景
> 1. 执行主机：部署的linux主机
> 2. 手动部署
> 3. 使用者为开发机为Windows操作系统，  
>    并通过上传jar到linux服务器主机进行镜像构建和k8s部署。  
> 4. 使用者开发机为linux操作系统，  
>    需要改造jar上传部分的逻辑

# 2. 部署脚本使用说明

- 1.部署脚本路径
`/home/ubuntu/flink-1.14.2/deploy_script`

- 2.上传Dockerfile构建脚本

  ```linux
  rz <DockerFile name>
  ```
- 3.上传Jar包

  ```
  rz <JAR name>
  ```
- 4.运行自动构建命令

  **说明：**  
  `./deploy_script.sh --active-env=<环境> --commit-version=<代码最后提交版本号>`

  > 当前支持环境：qa2、uatstable

  **示例：**

  ```
  ./deploy_script.sh --active-env=qa2 --commit-version=049cg68p
  ```

# 3. deploy_script.sh 执行阶段介绍
- 1.解析执行命令参数， 并校验合法性
  > active-env 
  > commit-version

- 2.选择是否上传jar文件（window & linux交互）

- 3.登录harbor

- 4.构建镜像并推送

- 5.确认是否发布环境脚本

- 6.切换Root用户（手动输入Root密码）

- 7.根据传入的active-env参数获取脚本并执行

- 8.退出Root用户
