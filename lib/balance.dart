import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tasks/model.dart';

class BalancePage extends StatefulWidget {
  final User user;
  final List<Bank> banks;
  final Function() onrefresh;
  const BalancePage({
    super.key,
    required this.user,
    required this.banks,
    required this.onrefresh,
  });

  @override
  BalancePageState createState() => BalancePageState();
}

class BalancePageState extends State<BalancePage> {
  String? selectedBank;
  final double minimumWithdraw = 100.00;
  String isErrorMessage = '';
  String accountName = '';
  bool isLoading = false;
  bool isError = false;
  bool isAccountError = false;
  TextEditingController accountNumber = TextEditingController(text: '');
  TextEditingController withdrawAmount = TextEditingController(text: '0.00');
  List<Map<String, String>> historyData = [
    {'title': 'Withdrawal 1', 'description': 'Withdrawn \$100 to Bank A'},
    {'title': 'Withdrawal 2', 'description': 'Withdrawn \$200 to Bank B'},
    // Add more transactions if needed or leave empty for testing empty state.
  ];

  late User user;
  late List<Bank> banks = [];

  @override
  void initState() {
    super.initState();
    user = widget.user;
    banks = widget.banks;
  }

  void _withdrawMoney() {
    if (accountNumber.value.text.isEmpty ||
        accountNumber.value.text.length < 10) {
      setState(() {
        isError = true;
        isErrorMessage = 'Please enter a valid acount number';
      });
    } else if (accountName == 'Loading...') {
      setState(() {
        isError = true;
        isErrorMessage = 'Please hold while we verify account';
      });
    } else if (minimumWithdraw > double.parse(withdrawAmount.value.text)) {
      setState(() {
        isError = true;
        isErrorMessage = 'Minimum withdrawal is \$$minimumWithdraw';
      });
    } else if (double.parse(withdrawAmount.value.text) > user.balance) {
      setState(() {
        isError = true;
        isErrorMessage = 'Insufficient balance';
      });
    } else {
      setState(() {
        isError = false;
      });
      processBalance();
    }
  }

  Future<void> fetchUserName() async {
    setState(() {
      isError = false;
      accountName = 'Loading...';
    });
    if (accountNumber.value.text.length == 10) {
      String userName = await fetchBankUser(
          selectedBank ?? banks.last.code, accountNumber.value.text);
      setState(() {
        if (userName.isEmpty) {
          isError = true;
          isErrorMessage = '404 account not found';
        } else {
          isError = false;
        }
        accountName = userName;
      });
    }
  }

  Future<void> _refreshBalance() async {
    await widget.onrefresh();
  }

  Future<void> processBalance() async {
    setState(() {
      isLoading = true;
    });
    Color withdrawColor = Colors.red;
    String title = 'Failed';
    String body = 'Unable to process please try again later.';
    bool withdraw = await withdrawMoney(withdrawAmount.value.text);
    if (withdraw == true) {
      title = 'Withdrawal Request Submitted';
      withdrawColor = Colors.teal.shade600;
      body =
          'Your withdrawal request has been successfully submitted. You will receive your funds within 24hrs';
    }
    setState(() {
      isLoading = false;
    });
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title,
              style:
                  TextStyle(color: withdrawColor, fontWeight: FontWeight.bold)),
          content: Text(body, style: TextStyle(color: withdrawColor)),
          actions: [
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.teal),
              ),
              onPressed: () {
                _refreshBalance();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Balance and History
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Balance: \$${user.balance}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.teal,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Balance'),
              Tab(text: 'History'),
            ],
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            unselectedLabelColor: Colors.grey.shade200,
            indicatorColor: Colors.grey.shade300,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        body: TabBarView(
          children: [
            buildBalanceTab(),
            buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget buildBalanceTab() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter User Details",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (banks.isNotEmpty) const SizedBox(height: 20),
              if (banks.isNotEmpty)
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal.shade300),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal.shade300),
                    ),
                  ),
                  value: selectedBank ?? banks.last.code,
                  items: banks.map((Bank bank) {
                    return DropdownMenuItem<String>(
                      value: bank.code,
                      child: Text(
                        bank.name,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBank = value ?? '';
                      isError = false;
                    });
                    fetchUserName();
                  },
                ),
              const SizedBox(height: 20),
              TextField(
                controller: accountNumber,
                style: TextStyle(color: Colors.grey.shade600),
                cursorErrorColor: Colors.red,
                cursorColor: Colors.grey.shade600,
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal.shade300),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  fetchUserName();
                },
              ),
              const SizedBox(height: 10),
              if (accountName.isNotEmpty)
                Text(
                  'Account Name: $accountName',
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 20),
              TextField(
                controller: withdrawAmount,
                style: TextStyle(color: Colors.grey.shade600),
                cursorErrorColor: Colors.red,
                cursorColor: Colors.grey.shade600,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal.shade300),
                  ),
                  helperText:
                      "Max: \$${user.balance.toStringAsFixed(2)}, Min: \$$minimumWithdraw",
                ),
                onChanged: (value) {
                  setState(() {
                    isError = false;
                  });
                },
              ),
              const SizedBox(height: 10),
              if (isError)
                Text(
                  isErrorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: isError ? null : _withdrawMoney,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  "Withdraw Money",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false,
            ),
          ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(
              color: Colors.teal,
            ),
          ),
      ],
    );
  }

  Widget buildHistoryTab() {
    return historyData.isNotEmpty
        ? ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyData.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Align(
                  alignment:
                      Alignment.centerRight, // Align the title to the right
                  child: Text(
                    historyData[index]['title']!,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600),
                  ),
                ),
                subtitle: Align(
                  alignment: Alignment
                      .centerRight, // Align the description to the right
                  child: Text(
                    historyData[index]['description']!,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              );
            },
          )
        : const Center(
            child: Text(
              'No history available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
  }
}
