🌿 Overseas Plant Identification App Development Plan (Laravel Backend)

作者：独立开发者（iOS/Swift 出身）
目标：复刻并超越《形色》类植物识别 App，面向海外用户市场，使用百度识别 API，后端采用 Laravel 构建

⸻

一、项目概况

项目名称	海外植物识别 App
目标市场	海外用户（英文 UI）
技术栈	Flutter 或 Swift（前端）、Laravel（后端）、百度识别 API、MySQL/PostgreSQL
功能模块	识别、诊断、为你推荐、我的植物、设置（更多）


⸻

二、核心功能模块

1. 📷 相机识别
	•	使用相机或图库选图
	•	接入百度识别 API 获取植物信息（名称、置信度、图文）
	•	识别结果展示卡片
	•	可收藏、添加到“我的花园”或拍照历史

2. 📚 为你推荐（需后端支持）
	•	城市切换（如 Tokyo、Los Angeles）
	•	热门植物推荐
	•	植物索引（A-Z 分类）
	•	搜索植物（中英文关键词）
	•	识别与保护（科普图文）
	•	植物知识文章聚合

3. 🩺 诊断模块
	•	自动诊断（模拟病害识别）
	•	诊断历史
	•	按植物/部位查看问题
	•	植物工具集：
	•	浇水量计算器
	•	光度计（环境光检测）
	•	换盆检测（预设规则）
	•	植物顾问推荐

4. 🌼 我的植物
	•	我的花园：收藏管理、文件夹分类、提醒设置
	•	拍照历史：可搜索、排序、查看详情

5. ⚙️ 更多设置
	•	多语言切换
	•	养护通知开关
	•	会员订阅页面（仅前期 UI）
	•	清除缓存、账户信息展示
	•	法律协议、关于页面等

⸻

三、后端设计（Laravel）

✅ 技术选型

项目	技术
后端语言	PHP (Laravel 10+)
数据库	MySQL / PostgreSQL
鉴权方式	UUID + token（可使用 Sanctum）
文件存储	本地 or OSS 服务

✅ 主要数据表

表名	用途
users	匿名用户（记录设备 ID）
plant_records	识别记录历史
plants	植物基础信息（推荐 + 百科）
favorites	用户收藏夹（我的花园）
articles	文章与知识库
folders	花园文件夹（可选）

✅ 核心接口

用户系统
	•	POST /api/user/init 初始化设备用户
	•	GET /api/user/info 获取设备信息

识别记录
	•	POST /api/record 上传识别记录
	•	GET /api/record 获取识别历史
	•	DELETE /api/record/{id} 删除记录

我的花园
	•	POST /api/favorites 添加收藏
	•	GET /api/favorites 获取收藏
	•	DELETE /api/favorites/{id} 取消收藏
	•	POST /api/folders 创建文件夹（可选）

推荐模块
	•	GET /api/recommend/home?city=Tokyo
	•	GET /api/recommend/search?keyword=rose
	•	GET /api/recommend/index
	•	GET /api/articles
	•	GET /api/plant/{id}

⸻

四、开发阶段与时间评估（单人 / Laravel 初学）

阶段	模块	时间预估
阶段一	相机识别 + 百度 API 对接 + UI	10～12 天
阶段二	我的植物（收藏、提醒、历史）	7～9 天
阶段三	Laravel 环境搭建 + 接口设计 + 推荐模块	10～12 天
阶段四	用户系统 + 收藏与记录接口开发	8～10 天
阶段五	诊断与工具模块开发（UI + 本地数据）	10～12 天
阶段六	多语言、App 打包测试、政策支持	5～7 天
阶段七	Bug 修复 + 后端调试	6～8 天

✅ 总周期预估：56～70 个工作日（11～14 周）

⸻

五、国际合规

项目	要求
GDPR / CCPA	提供隐私弹窗、删除数据、不可追踪选项
百度识别 API	明示使用百度 API，上传仅用于识别
App 发布	支持多语言、本地化、隐私链接、服务条款链接


⸻
