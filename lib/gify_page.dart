// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, avoid_print
import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';

class GifyPage extends StatefulWidget {
  @override
  _GifyPageState createState() => _GifyPageState();
}

class _GifyPageState extends State<GifyPage> {
  bool showLoading = false;
  List<String> gifList = [];
  int globalIndex = 0;
  int ind = 0;
  String searchText = "";
  var data;
  final int loadingSize = 20;
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final url =
      "https://api.giphy.com/v1/gifs/search?api_key=t1WuUC4xdgcHAo8ptG3y7zuwEPalxhDB&limit=offset&offset=0&rating=G&lang=en&q=";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        _getMoreData(controller.text);
      }
    });
  }

  Timer? _debounce;
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      getData(controller.text);
    });
  }

  getData(String searchText) async {
    gifList.clear();
    if (searchText == "") {
      searchText = "random";
    }
    showLoading = true;
    setState(() {});
    int gifListLength = gifList.length;
    final res = await http.get(Uri.parse(
        "https://api.giphy.com/v1/gifs/search?api_key=t1WuUC4xdgcHAo8ptG3y7zuwEPalxhDB&limit=offset&offset=" +
            gifListLength.toString() +
            "&rating=G&lang=en&q=" +
            searchText));

    if (res.statusCode == 200) {
      data = jsonDecode(res.body)["data"];
      for (int i = 0; i < loadingSize; i++) {
        final imgUrl = data[i]["images"]["fixed_height"]["url"].toString();
        setState(() {
          gifList.add(imgUrl);
          showLoading = false;
        });
      }
    }
  }

  _getMoreData(String searchText) async {
    if (searchText == "") {
      searchText = "random";
    }
    setState(() {});
    int gifListLength = gifList.length;
    final res = await http.get(Uri.parse(
        "https://api.giphy.com/v1/gifs/search?api_key=t1WuUC4xdgcHAo8ptG3y7zuwEPalxhDB&limit=offset&offset=" +
            gifListLength.toString() +
            "&rating=G&lang=en&q=" +
            searchText));

    if (res.statusCode == 200) {
      data = jsonDecode(res.body)["data"];
      for (int i = 0; i < loadingSize; i++) {
        final imgUrl = data[i]["images"]["fixed_height"]["url"].toString();
        setState(() {
          gifList.add(imgUrl);
          showLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Vx.gray800,
        body: Theme(
          data: ThemeData.dark(),
          child: VStack([
            "Gify App".text.white.xl4.make().objectCenter(),
            [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: "Search here"),
                  onChanged: _onSearchChanged,
                ),
              ),
              30.widthBox,
              RaisedButton(
                onPressed: () {
                  getData(controller.text);
                },
                child: "Go".text.make(),
                shape: Vx.roundedSm,
              ).h8(context)
            ]
                .hStack(
                    axisSize: MainAxisSize.max,
                    crossAlignment: CrossAxisAlignment.center)
                .p24(),
            if (showLoading)
              CircularProgressIndicator().centered()
            else
              VxConditional(
                condition: data != null,
                builder: (context) => GridView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.isMobile ? 2 : 3),
                  itemBuilder: (context, int index) {
                    return ZStack(
                      [
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Image.network(
                            gifList[index],
                            fit: BoxFit.cover,
                            color: Colors.black.withOpacity(0.8),
                            colorBlendMode: BlendMode.darken,
                          ),
                        ),
                        Image.network(
                          gifList[index],
                          fit: BoxFit.contain,
                        )
                      ],
                      fit: StackFit.expand,
                    ).card.roundedSM.make().p4();
                  },
                  itemCount: gifList.length,
                ),
                fallback: (context) => "Let's find some gifs, press go!:)"
                    .text
                    .gray500
                    .xl3
                    .makeCentered(),
              ).h(context.percentHeight * 70)
          ]).p16().scrollVertical(physics: NeverScrollableScrollPhysics()),
        ));
  }
}
