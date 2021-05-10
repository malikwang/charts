// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Example of timeseries chart with custom measure and domain formatters.
import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart' as TextElement;
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomAxisTickFormatters extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  CustomAxisTickFormatters(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory CustomAxisTickFormatters.withSampleData() {
    return new CustomAxisTickFormatters(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory CustomAxisTickFormatters.withRandomData() {
    return new CustomAxisTickFormatters(_createRandomData());
  }

  static List<charts.Series<MyRow, DateTime>> _createSampleData() {
    final data = [
      new MyRow(new DateTime(2017, 9, 25), 6),
      new MyRow(new DateTime(2017, 9, 26), 8),
      new MyRow(new DateTime(2017, 9, 27), 6),
      new MyRow(new DateTime(2017, 9, 28), 9),
      new MyRow(new DateTime(2017, 9, 29), 11),
      new MyRow(new DateTime(2017, 9, 30), 15),
      new MyRow(new DateTime(2017, 10, 01), 25),
      new MyRow(new DateTime(2017, 10, 02), 33),
      new MyRow(new DateTime(2017, 10, 03), 27),
      new MyRow(new DateTime(2017, 10, 04), 31),
      new MyRow(new DateTime(2017, 10, 05), 23),
    ];

    return [
      new charts.Series<MyRow, DateTime>(
        id: 'Cost',
        domainFn: (MyRow row, _) => row.timeStamp,
        measureFn: (MyRow row, _) => row.cost,
        data: data,
      )
    ];
  }

  /// Create random data.
  static List<charts.Series<MyRow, DateTime>> _createRandomData() {
    final random = new Random();

    final myData = [
      new MyRow(new DateTime(2017, 9, 25), random.nextInt(100)),
      new MyRow(new DateTime(2017, 9, 27), random.nextInt(100)),
      new MyRow(new DateTime(2017, 9, 29), random.nextInt(100)),
      new MyRow(new DateTime(2017, 10, 01), random.nextInt(100)),
      new MyRow(new DateTime(2017, 10, 03), random.nextInt(100)),
      new MyRow(new DateTime(2017, 10, 05), random.nextInt(100)),
    ];

    final classData = [
      new MyRow(new DateTime(2017, 9, 25), random.nextInt(100)),
      new MyRow(new DateTime(2017, 9, 27), random.nextInt(100)),
      new MyRow(new DateTime(2017, 9, 29), random.nextInt(100)),
      new MyRow(new DateTime(2017, 10, 01), random.nextInt(100)),
      new MyRow(new DateTime(2017, 10, 03), random.nextInt(100)),
      new MyRow(new DateTime(2017, 10, 05), random.nextInt(100)),
    ];

    return [
      new charts.Series<MyRow, DateTime>(
        id: '我的作业',
        domainFn: (MyRow row, _) => row.timeStamp,
        measureFn: (MyRow row, _) => row.cost,
        data: myData,
        colorFn: (_, __) => charts.Color.fromHex(code: '#0088FB'),
        radiusPxFn: (_, __) => 6,
      )..setAttribute(charts.rendererIdKey, 'customLine'),
      new charts.Series<MyRow, DateTime>(
        id: '班级平均',
        domainFn: (MyRow row, _) => row.timeStamp,
        measureFn: (MyRow row, _) => row.cost,
        data: classData,
        colorFn: (_, __) => charts.Color.fromHex(code: '#B4B8C7'),
        radiusPxFn: (_, __) => 6,
      )..setAttribute(charts.rendererIdKey, 'customLine')
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return new charts.TimeSeriesChart(
          seriesList,
          animate: false,
          primaryMeasureAxis: new charts.NumericAxisSpec(
            renderSpec: charts.GridlineRendererSpec(
              lineStyle: charts.LineStyleSpec(
                dashPattern: [],
              ),
              labelOffsetFromAxisPx: 8,
            ),
            tickProviderSpec: charts.StaticNumericTickProviderSpec(
              [
                new charts.TickSpec(0, label: '0%'),
                new charts.TickSpec(20, label: '20%'),
                new charts.TickSpec(40, label: '40%'),
                new charts.TickSpec(60, label: '60%'),
                new charts.TickSpec(80, label: '80%'),
                new charts.TickSpec(100, label: '100%'),
              ],
            ),
          ),
          customSeriesRenderers: [
            new charts.LineRendererConfig(
              customRendererId: 'customLine',
              strokeWidthPx: 3,
              includePoints: true,
            ),
          ],
          domainAxis: new charts.DateTimeAxisSpec(
            renderSpec: charts.SmallTickRendererSpec<DateTime>(
              lineStyle: charts.LineStyleSpec(
                color: charts.Color.transparent,
              ),
              labelOffsetFromAxisPx: 16,
            ),
            tickProviderSpec: new charts.StaticDateTimeTickProviderSpec(seriesList.first.data.map(
              (e) {
                DateTime time = (e as MyRow).timeStamp;
                var dataFormat = DateFormat('MM-dd');
                String formatResult = dataFormat.format(time);
                return charts.TickSpec(time, label: '$formatResult');
              },
            ).toList()),
            showAxisLine: false,
          ),
          selectionModels: [
            charts.SelectionModelConfig(
              changedListener: (charts.SelectionModel model) {
                if (model.hasDatumSelection) {
                  initData();
                  model.selectedDatum.forEach((charts.SeriesDatum object) {
                    selectedObjects.add(SelectedObject(
                      id: object.series.id,
                      value: object.datum.cost,
                      fillColor: object.series.colorFn(0),
                    ));
                  });
                }
              },
            )
          ],
          behaviors: [
            charts.LinePointHighlighter(
              dashPattern: [],
              symbolRenderer: new PopupRenderer(maxWidth: constraints.maxWidth),
            ),
          ],
        );
      },
    );
  }
}

/// Sample time series data type.
class MyRow {
  final DateTime timeStamp;
  final int cost;
  MyRow(this.timeStamp, this.cost);
}

List<num> positionsY = [];
List<SelectedObject> selectedObjects = [];

void initData() {
  positionsY = [];
  selectedObjects = [];
}

class SelectedObject {
  SelectedObject({this.id, this.value, this.fillColor});

  charts.Color fillColor;
  String id;
  num value;
}

class PopupRenderer extends charts.CustomSymbolRenderer {
  PopupRenderer({this.maxWidth});

  final double maxWidth;

  void _drawObject(
    charts.ChartCanvas canvas,
    Point position,
  ) {
    for (int i = 0; i < selectedObjects.length; i++) {
      SelectedObject object = selectedObjects[i];
      Point offset = Point(position.x, position.y + 30.0 * i);
      canvas.drawPoint(
        point: Point(offset.x + 8.0, offset.y + 8.0),
        radius: 5.0,
        fill: object.fillColor,
      );
      var textStyle = style.TextStyle();
      textStyle.color = charts.Color.black;
      textStyle.fontSize = 15;
      canvas.drawText(
        TextElement.TextElement(object.id, style: textStyle),
        offset.x.toInt() + 18,
        offset.y.toInt(),
      );
      canvas.drawText(
        TextElement.TextElement('${object.value}%', style: textStyle),
        offset.x.toInt() + 79,
        offset.y.toInt(),
      );
    }
  }

  @override
  void paint(
    charts.ChartCanvas canvas,
    Rectangle<num> bounds, {
    List<int> dashPattern,
    charts.Color fillColor,
    charts.FillPatternType fillPattern,
    charts.Color strokeColor,
    double strokeWidthPx,
  }) {
    positionsY.add(bounds.top);
    final center = Point(
      bounds.left + (bounds.width / 2),
      bounds.top + (bounds.height / 2),
    );
    final radius = min(bounds.width, bounds.height) / 2;
    canvas.drawPoint(
      point: center,
      radius: radius * 2,
      fill: charts.Color(r: fillColor.r, g: fillColor.g, b: fillColor.b, a: (255 * 0.2).toInt()),
      stroke: strokeColor,
      strokeWidthPx: strokeWidthPx,
    );
    canvas.drawPoint(
      point: center,
      radius: radius * 1.3,
      fill: charts.Color.white,
      stroke: strokeColor,
      strokeWidthPx: strokeWidthPx,
    );
    canvas.drawPoint(
      point: center,
      radius: radius,
      fill: fillColor,
      stroke: strokeColor,
      strokeWidthPx: strokeWidthPx,
    );
    if (positionsY.length == selectedObjects.length) {
      Point offset = Point(bounds.left + 30, positionsY.reduce((a, b) => a + b) / positionsY.length);
      if (bounds.left + 30 + 138 > maxWidth) {
        offset = Point(bounds.left - 30 - 138, positionsY.reduce((a, b) => a + b) / positionsY.length);
      }
      canvas.drawRRect(
        Rectangle(offset.x, offset.y, 138.0, 71.0),
        fill: charts.Color.white,
        radius: 6.0,
        roundTopLeft: true,
        roundTopRight: true,
        roundBottomRight: true,
        roundBottomLeft: true,
      );
      _drawObject(canvas, Point(offset.x + 16.0, offset.y + 16.0));
    }
  }

  @override
  Widget build(BuildContext context, {Color color, Size size, bool enabled}) {
    return Container();
  }
}
