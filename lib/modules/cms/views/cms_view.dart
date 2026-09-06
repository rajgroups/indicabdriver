import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import '../controllers/cms_controller.dart';

class CmsView extends GetView<CmsController> {
  const CmsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final title = controller.title.value.isEmpty 
          ? (Get.arguments?['title'] ?? 'Page') 
          : controller.title.value;

      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          elevation: theme.appBarTheme.elevation,
        ),
        body: controller.isLoading.value
            ? Center(child: CircularProgressIndicator(
                color: theme.progressIndicatorTheme.color ?? theme.colorScheme.primary,
              ))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Html(
                    data: controller.content.value,
                    style: {
                      "body": Style(
                        fontSize: FontSize(16.0),
                        color: theme.colorScheme.onSurface,
                        lineHeight: LineHeight.number(1.5),
                      ),
                      "h1": Style(
                        fontSize: FontSize(24.0),
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    },
                  ),
                ),
              ),
      );
    });
  }
}
