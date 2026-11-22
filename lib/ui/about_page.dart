import 'package:flutter/material.dart';
import '../services/api.dart';
import 'theme.dart';
import 'tip.dart';

class AboutPage extends StatefulWidget {
  AboutPage({super.key});
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _ver = '1.0.0';

  @override
  void initState() {
    super.initState();
    Api.json(Api.appRepo, 'version.json').then((v) {
      final s = v?['version']?.toString();
      if (s != null && mounted) setState(() => _ver = s);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      appBar: AppBar(
        backgroundColor: T.bg,
        elevation: 0,
        title: Text('关于', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: AssetImage('assets/avatar.webp'), fit: BoxFit.cover),
              ),
            ),
          ),
          SizedBox(height: 14),
          Center(
            child: Text('Tsinho 黄油站',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          ),
          SizedBox(height: 4),
          Center(
            child: Text('版本 $_ver',
                style: TextStyle(fontSize: 12.5, color: T.tx3)),
          ),
          SizedBox(height: 26),
          _block('这是什么', '基于站内资源整理的离线浏览客户端，数据来自站点自动生成的清单，内容与网页版保持一致。'),
          _block('数据说明', '封面与下载均指向站点原始地址，App 只做索引，不托管任何文件。'),
          _block('免责声明', '资源来自互联网公开渠道，仅供学习交流，请于下载后 24 小时内删除，支持正版。'),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () => Tip.show(context, 'Tsinhos@qq.com'),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: T.card,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: T.line, width: 0.5),
              ),
              child: Center(
                child: Text('联系站长：Tsinhos@qq.com',
                    style: TextStyle(fontSize: 13.5, color: T.tx2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _block(String t, String body) => Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            SizedBox(height: 7),
            Text(body, style: TextStyle(fontSize: 13.5, height: 1.75, color: T.tx2)),
          ],
        ),
      );
}
