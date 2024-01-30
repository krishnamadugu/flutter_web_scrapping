import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> plansData = ['Select A plan'];
  List<String> ageData = ['select your age '];
  List<String> policyData = List.generate(10, (index) => index.toString());
  String selectedPlan = 'Select A plan';
  String selectedAge = 'Selected age';
  String selectedPolicyTerm = 'Select Policy Term';
  List<String>? termData;
  final formKey = GlobalKey<FormState>();

  TextEditingController basicSumAssuredTxtVal = TextEditingController();

  @override
  void initState() {
    getWebsiteData();
    super.initState();
  }

  Future getWebsiteData() async {
    final url = Uri.parse("https://www.licpremiumcalculator.in/");
    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);

    for (int i = 1; i <= 8; i++) {
      final titles = html
          .querySelectorAll('#table > option:nth-child(${i + 1})')
          .map((element) => element.innerHtml.trim())
          .toList();

      plansData.addAll(titles);
    }

    final titles = html
        .querySelectorAll('#result > div > div:nth-child(1)')
        .map((element) => element.innerHtml.trim())
        .toList();

    debugPrint(titles.toString());
    for (final i in titles) {
      debugPrint(i.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lic Calculator Web Scraping",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            SharedDropDownWidget(
              textTheme: Theme.of(context).textTheme,
              items: plansData,
              selectedValue: selectedPlan,
              screenHeight: MediaQuery.of(context).size.height,
              screenWidth: MediaQuery.of(context).size.width,
              hintText: plansData[0],
              onChangedFun: (value) {
                setState(() {
                  selectedPlan = value!;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: SharedTextFieldWidget(
                obsTxtVal: false,
                textEditingController: basicSumAssuredTxtVal,
                textTheme: Theme.of(context).textTheme,
                hintTxt: "Basic Sum Assured",
                validatorFunction: validateField,
                keyBoardTypeVal: TextInputType.number,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueGrey,
                minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 50),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {}
              },
              child: Text("Calculate"),
            ),
          ],
        ),
      ),
    );
  }
}

String? validateField(String? value) {
  if ((value == null || value.trim() == '')) {
    return "Please Enter sum assured amount";
  }
  return null;
}

class SharedTextFieldWidget extends StatelessWidget {
  const SharedTextFieldWidget({
    super.key,
    this.suffixIconWidget = const SizedBox(
      width: 0,
    ),
    required this.textEditingController,
    required this.validatorFunction,
    required this.textTheme,
    required this.hintTxt,
    this.keyBoardTypeVal,
    this.obsTxtVal = false,
    this.maxLines,
  });

  final TextEditingController textEditingController;
  final String? Function(String?)? validatorFunction;
  final TextTheme textTheme;
  final String hintTxt;
  final TextInputType? keyBoardTypeVal;
  final Widget suffixIconWidget;
  final bool obsTxtVal;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            hintTxt,
            style: textTheme.titleMedium,
          ),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: textEditingController,
          validator: validatorFunction,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 20,
          ),
          maxLines: maxLines ?? 1,
          keyboardType: keyBoardTypeVal,
          obscureText: obsTxtVal,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            errorStyle: textTheme.labelSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                12,
              ),
              borderSide: const BorderSide(
                color: Colors.black,
              ),
            ),
            enabledBorder: inputTextFieldBorder(),
            errorBorder: inputTextFieldBorder(),
            focusedBorder: inputTextFieldBorder(),
            suffixIcon: suffixIconWidget,
          ),
        ),
      ],
    );
  }
}

OutlineInputBorder inputTextFieldBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(
      20,
    ),
    borderSide: const BorderSide(
      color: Colors.black,
    ),
  );
}

class SharedDropDownWidget extends StatelessWidget {
  const SharedDropDownWidget({
    super.key,
    required this.textTheme,
    required this.items,
    required this.selectedValue,
    required this.screenHeight,
    required this.screenWidth,
    required this.hintText,
    required this.onChangedFun,
  });

  final TextTheme textTheme;
  final List<String> items;
  final String? selectedValue;
  final String hintText;
  final double screenHeight;
  final double screenWidth;
  final void Function(String?)? onChangedFun;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text(
                hintText,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                ),
              ),
              items: items
                  .map(
                    (String item) => item.startsWith('-')
                        ? DropdownMenuItem<String>(
                            value: item,
                            enabled: false,
                            child: Text(
                              item,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.4),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  )
                  .toList(),
              value: selectedValue,
              onChanged: onChangedFun,
              buttonStyleData: ButtonStyleData(
                height: screenHeight * 0.055,
                width: screenWidth,
                padding: const EdgeInsets.all(
                  14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  // color: Colors.redAccent,
                ),
                //elevation: 2,
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                ),
                iconSize: 28,
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: screenHeight * 0.2,
                width: screenWidth * 0.9,
                useRootNavigator: true,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
                //  offset: const Offset(-20, 0),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(
                    40,
                  ),
                  thickness: MaterialStateProperty.all(
                    6,
                  ),
                  thumbVisibility: MaterialStateProperty.all(true),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 40,
                padding: EdgeInsets.only(
                  left: 14,
                  right: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
