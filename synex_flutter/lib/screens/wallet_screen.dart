import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// WALLET SCREEN
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class WalletScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const WalletScreen({super.key, this.userData});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<Map> _transactions = [];
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    FirebaseDatabase.instance.ref('users/$uid/transactions').onValue.listen((event) {
      if (!event.snapshot.exists || !mounted) return;
      final data = event.snapshot.value as Map;
      final list = data.values.map((v) => Map<String, dynamic>.from(v as Map)).toList();
      list.sort((a, b) => ((b['date'] ?? 0) as num).compareTo((a['date'] ?? 0) as num));
      if (mounted) setState(() => _transactions = list);
    });
  }

  List<Map> get _filtered {
    switch (_filter) {
      case 'credit': return _transactions.where((t) => (t['amount'] as num? ?? 0) > 0).toList();
      case 'debit': return _transactions.where((t) => (t['amount'] as num? ?? 0) < 0).toList();
      case 'pending': return _transactions.where((t) => t['status'] == 'pending').toList();
      default: return _transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bal = widget.userData?['wallet'] ?? 0;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg2,
        title: Text('Wallet', style: GoogleFonts.orbitron(
          fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.white,
        )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // Balance hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), AppColors.blue1],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text('Total Balance',
                  style: GoogleFonts.rajdhani(
                    fontSize: 13, color: Colors.white.withOpacity(0.65),
                    letterSpacing: 1,
                  )),
                const SizedBox(height: 4),
                Text('â‚¹$bal',
                  style: GoogleFonts.orbitron(
                    fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white,
                  )),
                const SizedBox(height: 4),
                Text('Available to use',
                  style: GoogleFonts.rajdhani(
                    fontSize: 11, color: Colors.white.withOpacity(0.45),
                  )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SynexButton(
                        label: 'Add Money',
                        icon: Icons.add_rounded,
                        onTap: () => _showDepositSheet(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SynexButton(
                        label: 'Withdraw',
                        icon: Icons.arrow_upward_rounded,
                        outlined: true,
                        onTap: () => _showWithdrawSheet(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter tabs
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text('Transactions',
                  style: GoogleFonts.orbitron(
                    fontSize: 13, color: AppColors.blue3, fontWeight: FontWeight.w700,
                  )),
                const Spacer(),
                ...['all', 'credit', 'debit', 'pending'].map((f) => GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _filter == f ? AppColors.blue1 : AppColors.card2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _filter == f ? AppColors.blue2 : AppColors.border,
                      ),
                    ),
                    child: Text(f[0].toUpperCase() + f.substring(1),
                      style: GoogleFonts.rajdhani(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: _filter == f ? Colors.white : AppColors.muted,
                      )),
                  ),
                )),
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_rounded,
                          size: 48, color: AppColors.muted.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text('No transactions yet',
                          style: GoogleFonts.rajdhani(
                            color: AppColors.muted, fontSize: 14,
                          )),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final tx = _filtered[i];
                      final amount = (tx['amount'] as num? ?? 0);
                      final isCredit = amount > 0;
                      final isPending = tx['status'] == 'pending';
                      final col = isPending ? AppColors.warn : isCredit ? AppColors.success : AppColors.danger;
                      return SynexCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: col.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isPending ? Icons.hourglass_empty_rounded :
                                isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                color: col, size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx['type'] ?? '',
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white,
                                    )),
                                  if (tx['desc'] != null)
                                    Text(tx['desc'], style: GoogleFonts.rajdhani(
                                      fontSize: 11, color: AppColors.muted,
                                    )),
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: col.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: col.withOpacity(0.3)),
                                    ),
                                    child: Text((tx['status'] ?? 'completed').toString().toUpperCase(),
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 9, color: col, fontWeight: FontWeight.w700, letterSpacing: 0.5,
                                      )),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isCredit ? '+' : ''}â‚¹${amount.abs()}',
                              style: GoogleFonts.orbitron(
                                fontSize: 15, fontWeight: FontWeight.w700, color: col,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDepositSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _DepositSheet(),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _WithdrawSheet(userData: widget.userData),
    );
  }
}

class _DepositSheet extends StatefulWidget {
  const _DepositSheet();

  @override
  State<_DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<_DepositSheet> {
  final _amtCtrl = TextEditingController();
  final _utrCtrl = TextEditingController();
  int? _selectedAmt;
  bool _loading = false;
  String _upiId = 'synex@upi';

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref('settings/upi').get().then((snap) {
      if (snap.exists && mounted) {
        final d = snap.value as Map;
        setState(() => _upiId = d['id']?.toString() ?? 'synex@upi');
      }
    });
  }

  Future<void> _submit() async {
    final amt = int.tryParse(_amtCtrl.text);
    final utr = _utrCtrl.text.trim();
    if (amt == null || amt < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid amount')));
      return;
    }
    if (utr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter UTR/Transaction ID')));
      return;
    }
    setState(() => _loading = true);
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    try {
      final db = FirebaseDatabase.instance.ref();
      final key = db.child('depositRequests').push().key;
      final snap = await db.child('users/$uid').get();
      final udata = Map<String, dynamic>.from(snap.value as Map);
      await db.child('depositRequests/$key').set({
        'userId': uid, 'userName': udata['name'] ?? '',
        'email': udata['email'] ?? '', 'amount': amt, 'utr': utr,
        'status': 'pending', 'date': ServerValue.timestamp,
      });
      final txKey = db.child('users/$uid/transactions').push().key;
      await db.child('users/$uid/transactions/$txKey').set({
        'type': 'Deposit', 'amount': amt,
        'date': ServerValue.timestamp, 'status': 'pending',
        'desc': 'Awaiting admin approval',
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request submitted! Admin will approve soon.',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border, borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Add Money ðŸ’°',
            style: GoogleFonts.orbitron(
              fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white,
            )),
          const SizedBox(height: 16),

          // UPI ID
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.cyan, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UPI ID / Pay to:',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11, color: AppColors.muted, letterSpacing: 0.5,
                        )),
                      Text(_upiId,
                        style: GoogleFonts.orbitron(
                          fontSize: 13, color: AppColors.cyan, fontWeight: FontWeight.w700,
                        )),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => copyToClipboard(context, _upiId, 'UPI ID'),
                  child: const Icon(Icons.copy_rounded, color: AppColors.blue3, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Amount chips
          Text('SELECT AMOUNT',
            style: GoogleFonts.rajdhani(
              fontSize: 11, color: AppColors.muted, letterSpacing: 1, fontWeight: FontWeight.w700,
            )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [100, 200, 500, 1000, 2000].map((amt) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAmt = amt;
                  _amtCtrl.text = amt.toString();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: _selectedAmt == amt ? const LinearGradient(
                    colors: [AppColors.blue1, AppColors.blue2],
                  ) : null,
                  color: _selectedAmt == amt ? null : AppColors.card2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedAmt == amt ? AppColors.blue2 : AppColors.border,
                  ),
                ),
                child: Text('â‚¹$amt',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: _selectedAmt == amt ? Colors.white : AppColors.muted,
                  )),
              ),
            )).toList(),
          ),
          const SizedBox(height: 14),

          SynexTextField(
            label: 'Amount (â‚¹)',
            hint: 'Enter amount',
            controller: _amtCtrl,
            keyboardType: TextInputType.number,
          ),
          SynexTextField(
            label: 'UTR / Transaction ID',
            hint: '12-digit UTR number',
            controller: _utrCtrl,
          ),

          SynexButton(
            label: 'Submit for Approval',
            icon: Icons.check_rounded,
            loading: _loading,
            width: double.infinity,
            onTap: _submit,
          ),
        ],
      ),
    );
  }
}

class _WithdrawSheet extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const _WithdrawSheet({this.userData});

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _amtCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final amt = int.tryParse(_amtCtrl.text);
    final upi = _upiCtrl.text.trim();
    if (amt == null || amt < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum withdrawal â‚¹100')));
      return;
    }
    if (upi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter UPI ID')));
      return;
    }
    final bal = (widget.userData?['wallet'] ?? 0) as int;
    if (bal < amt) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance')));
      return;
    }
    setState(() => _loading = true);
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    try {
      final db = FirebaseDatabase.instance.ref();
      final snap = await db.child('users/$uid').get();
      final udata = Map<String, dynamic>.from(snap.value as Map);
      final key = db.child('withdrawalRequests').push().key;
      await db.child('withdrawalRequests/$key').set({
        'userId': uid, 'userName': udata['name'] ?? '',
        'email': udata['email'] ?? '', 'amount': amt, 'upiId': upi,
        'status': 'pending', 'date': ServerValue.timestamp,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawal requested! ðŸ“¤',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bal = widget.userData?['wallet'] ?? 0;
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border, borderRadius: BorderRadius.circular(2),
            ),
          )),
          const SizedBox(height: 16),
          Text('Withdraw Funds ðŸ“¤',
            style: GoogleFonts.orbitron(
              fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white,
            )),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warn.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warn.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.warn, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Min â‚¹100 Â· Balance: â‚¹$bal Â· Processing 24hrs',
                    style: GoogleFonts.rajdhani(fontSize: 13, color: AppColors.warn)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SynexTextField(
            label: 'Amount (â‚¹)',
            hint: 'Min â‚¹100',
            controller: _amtCtrl,
            keyboardType: TextInputType.number,
          ),
          SynexTextField(
            label: 'Your UPI ID',
            hint: 'yourname@okhdfcbank',
            controller: _upiCtrl,
          ),
          SynexButton(
            label: 'Request Withdrawal',
            icon: Icons.arrow_upward_rounded,
            loading: _loading,
            width: double.infinity,
            onTap: _submit,
          ),
        ],
      ),
    );
  }
}
