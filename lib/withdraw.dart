import 'package:flutter/material.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  WithdrawPageState createState() => WithdrawPageState();
}

class WithdrawPageState extends State<WithdrawPage> {
  String _selectedBank = 'Select Bank';
  String _accountName = '';
  String _accountNumber = '';
  String _amount = '';
  final double userAmount = 500.00; // Example amount
  bool isError = false;

  List<Map<String, String>> historyData = [
    {'title': 'Withdrawal 1', 'description': 'Withdrawn \$100 to Bank A'},
    {'title': 'Withdrawal 2', 'description': 'Withdrawn \$200 to Bank B'},
    // Add more transactions if needed or leave empty for testing empty state.
  ];

  void _submitTask() {
    // Submit task logic
    if (_selectedBank == 'Select Bank' ||
        _accountNumber.isEmpty ||
        _amount.isEmpty) {
      setState(() {
        isError = true;
      });
    } else {
      setState(() {
        isError = false;
      });
      processWithdraw();
    }
  }

  void fetchAccountName() {
    // Placeholder to mock fetching the account name
    setState(() {
      if (_accountNumber.length == 10) {
        _accountName = 'John Doe'; // Mock account name
      } else {
        _accountName = '';
      }
    });
  }

  void processWithdraw() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Withdraw Successful"),
        content: const Text("Your withdrawal has been processed."),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Withdraw and History
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Balance: \$300",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.teal,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Withdraw'),
              Tab(text: 'History'),
            ],
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            //unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.grey.shade600,
          ),
        ),
        body: TabBarView(
          children: [
            // First Tab: Withdraw Funds
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter Account Details",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal.shade300),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal.shade300),
                      ),
                    ),
                    value: _selectedBank,
                    items: <String>['Select Bank', 'Bank A', 'Bank B', 'Bank C']
                        .map((String bank) {
                      return DropdownMenuItem<String>(
                        value: bank,
                        child: Text(
                          bank,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBank = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
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
                      _accountNumber = value;
                      fetchAccountName();
                    },
                  ),
                  const SizedBox(height: 10),
                  if (_accountName.isNotEmpty)
                    Text(
                      'Account Name: $_accountName',
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal.shade300),
                      ),
                      helperText:
                          "Max: \$${userAmount.toStringAsFixed(2)}, Min: \$100",
                    ),
                    onChanged: (value) {
                      _amount = value;
                      double? enteredAmount = double.tryParse(_amount);
                      if (enteredAmount != null) {
                        if (enteredAmount > userAmount || enteredAmount < 100) {
                          setState(() {
                            isError = true;
                          });
                        } else {
                          setState(() {
                            isError = false;
                          });
                        }
                      } else {
                        setState(() {
                          isError = true;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  if (isError)
                    const Text(
                      'Please enter a valid amount within the specified range.',
                      style: TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: isError ? null : _submitTask,
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      "Submit Task",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
            // Second Tab: History
            historyData.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Align(
                          alignment: Alignment
                              .centerRight, // Align the title to the right
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
                  ),
          ],
        ),
      ),
    );
  }
}
