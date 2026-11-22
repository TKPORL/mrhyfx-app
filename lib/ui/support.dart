import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'theme.dart';

const _weixin = 'https://tkporl.github.io/mrhyfx/assets/sponsor/weixin.webp';
const _alipay = 'https://tkporl.github.io/mrhyfx/assets/sponsor/alipay.webp';

/// 支持站长：与网页/demo 同一个弹窗，两张收款码
Future<void> showSupportSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: T.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (c) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: T.tx3.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text('支持站长',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: T.tx)),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(c),
                  child: Text('关闭', style: TextStyle(fontSize: 13, color: T.tx2)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('永久免费、无广告。如果这里帮你省了时间，可以请我喝杯咖啡。',
                style: TextStyle(fontSize: 13, height: 1.6, color: T.tx2)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _qr(c, _weixin, '微信')),
                const SizedBox(width: 12),
                Expanded(child: _qr(c, _alipay, '支付宝')),
              ],
            ),
            const SizedBox(height: 14),
            Text('长按二维码可保存图片，或用微信 / 支付宝扫码',
                style: TextStyle(fontSize: 11.5, color: T.tx3)),
          ],
        ),
      ),
    ),
  );
}

Widget _qr(BuildContext c, String url, String label) {
  return GestureDetector(
    onTap: () => showDialog(
      context: c,
      builder: (_) => Dialog(
        backgroundColor: T.card,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
        ),
      ),
    ),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: T.line, width: 0.5),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1,
              child: ColoredBox(
                color: Colors.white,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  errorWidget: (a, b, d) => ColoredBox(color: T.card2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12.5, color: T.tx2)),
        ],
      ),
    ),
  );
}
