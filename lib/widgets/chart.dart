import 'package:flutter/material.dart';
import 'package:managment/data/model/add_date.dart';
import 'package:managment/data/utlity.dart'; // Ensure this import is correct!
import 'package:syncfusion_flutter_charts/charts.dart';


// Define the 'time' method if it's missing
List<int> time(List<Add_data> dataList, bool isToday) {
  // Example implementation (replace with actual logic)
  return dataList.map((data) => isToday ? data.datetime.hour : data.datetime.day).toList();
}

class Chart extends StatefulWidget {
  final int indexx; // Changed to final since it's passed in the constructor

  const Chart({Key? key, required this.indexx}) : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  List<Add_data>? a;
  bool b = true;
  bool j = true;

  @override
  Widget build(BuildContext context) {
    // Local variables to avoid repeated calls and improve readability
    List<Add_data>? dataList;
    bool isToday = true;
    bool isDaily = true;

    switch (widget.indexx) {
      case 0:
        dataList = today();
        isToday = true;
        isDaily = true;
        break;
      case 1:
        dataList = week();
        isToday = false;
        isDaily = true;
        break;
      case 2:
        dataList = month();
        isToday = false;
        isDaily = true;
        break;
      case 3:
        dataList = year();
        isDaily = false;
        break;
      default:
        dataList = today(); // Provide a default case
        isToday = true;
        isDaily = true;
        break;
    }

    return Container(
      width: double.infinity,
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <SplineSeries<SalesData, String>>[
          SplineSeries<SalesData, String>(
            color: const Color.fromARGB(255, 47, 125, 121),
            width: 3,
            dataSource: generateSalesData(dataList, isToday, isDaily),
            xValueMapper: (SalesData sales, _) => sales.year,
            yValueMapper: (SalesData sales, _) => sales.sales,
          )
        ],
      ),
    );
  }

  // Helper function to generate SalesData list
  List<SalesData> generateSalesData(
      List<Add_data> dataList, bool isToday, bool isDaily) {
    List<SalesData> salesDataList = [];

    // CHECK IF DATALIST IS EMPTY BEFORE PROCEEDING
    if (dataList.isEmpty) {
      return salesDataList; // Return an empty list if dataList is empty
    }

    for (int index = 0; index < dataList.length; index++) {
      String yearValue;
      if (isDaily) {
        yearValue = isToday
            ? dataList[index].datetime.hour.toString()
            : dataList[index].datetime.day.toString();
      } else {
        yearValue = dataList[index].datetime.month.toString();
      }
      int salesValue = calculateTimeValue(dataList, isToday, index);
      salesDataList.add(SalesData(yearValue, salesValue));
    }

    return salesDataList;
  }

  // Helper Function to calculate Time Value
  int calculateTimeValue(
      List<Add_data> dataList, bool isToday, int index) {
    int timeValue = time(List<Add_data>.from([dataList[index]]), isToday)[0];

    if (index > 0) {
      // timeValue += time(List<Add_data>.from([dataList[index - 1]]), isToday)[0];

      int previousTimeValue = calculateTimeValue(dataList, isToday, index-1);
      timeValue += previousTimeValue;
    }
    return timeValue;
  }
}

class SalesData {
  SalesData(this.year, this.sales);

  final String year;
  final int sales;
}