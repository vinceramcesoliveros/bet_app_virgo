import 'package:bet_app_virgo/cashier/cashier.dart';
import 'package:bet_app_virgo/cashier/dashboard/cubit/grand_total_cubit.dart';
import 'package:bet_app_virgo/cashier/dashboard/widgets/grand_total_builder.dart';
import 'package:bet_app_virgo/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cashier/grand_total_draws/cubit/grand_total_draws_cubit.dart';
import '../../cashier/grand_total_draws/widgets/scaffold.dart';
import '../../login/bloc/login_bloc.dart';
import '../../login/widgets/builder.dart';
import '../../login/widgets/scaffold.dart';
import '../../utils/utils.dart';
import '../combinations/scaffold.dart';
import '../draws/widgets/scaffold.dart';
import '../generate_hits/scaffold.dart';
import '../sold_out/scaffold.dart';
import '../win_category/scaffold.dart';

class BetDashboardScaffold extends StatelessWidget {
  static const String path = "/dashboard";
  const BetDashboardScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _BetDashboardWillPopScope(
      child: GrandTotalProvider(
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text("BET APPLICATION"),
                  accountEmail: Text("DASHBOARD v1.06"),
                ),
                ListTile(
                  title: Text("Top 10 Combinations"),
                  onTap: () =>
                      Navigator.pushNamed(context, BetCombinationScaffold.path),
                ),
                ListTile(
                  title: Text("History"),
                  onTap: () => Navigator.pushNamed(
                      context, CashierBetHistoryScaffold.path),
                ),
                ListTile(
                  title: Text("Low Win Summary"),
                  onTap: () =>
                      Navigator.pushNamed(context, BetCategoryScaffold.path),
                ),
                ListTile(
                  title: Text("Generate Hits"),
                  onTap: () =>
                      Navigator.pushNamed(context, BetGenerateHitScaffold.path),
                ),
                ListTile(
                  title: Text("Sold Out / Low Win"),
                  onTap: () =>
                      Navigator.pushNamed(context, BetSoldOutScaffold.path),
                ),
                ListTile(
                    title: Text("Draws"),
                    onTap: () =>
                        Navigator.pushNamed(context, AdminDrawScaffold.path)),
                ListTile(
                  title: Text("Bet Cancellation"),
                  onTap: null,
                ),
                ListTile(
                  title: Text("LOGOUT"),
                  onTap: () {
                    context.read<LoginBloc>().add(LogoutEvent());
                    Navigator.pushReplacementNamed(
                        context, BetLoginScaffold.path);
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("THIS MONTH"),
                  Text("P 25,000", style: textTheme.caption),
                ],
              )),
          body: BetDashboardBody(),
        ),
      ),
    );
  }
}

class _BetDashboardWillPopScope extends StatelessWidget {
  const _BetDashboardWillPopScope({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text("Logout"),
                content: Text("Do you want to logout?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("CANCEL"),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        context.read<LoginBloc>().add(LogoutEvent());
                      },
                      child: Text("LOGOUT")),
                ],
              );
            });
        return false;
      },
      child: child,
    );
  }
}

class BetDashboardBody extends StatefulWidget {
  const BetDashboardBody({Key? key}) : super(key: key);

  @override
  State<BetDashboardBody> createState() => _BetDashboardBodyState();
}

class _BetDashboardBodyState extends State<BetDashboardBody> {
  @override
  void initState() {
    context.read<GrandTotalCubit>().refetchAdmin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(child: _GrandTotalListview()),
      ],
    );
  }
}

class _GrandTotalListview extends StatelessWidget {
  const _GrandTotalListview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GrandTotalCubit>().state;

    if (state is GrandTotalAdminLoaded) {
      if (state.error != null) {
        return Text("${state.error}");
      }
      final items = state.items;
      return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _GrandTotalContainer(grandTotal: item);
          });
    }

    return notNil;
  }
}

class _GrandTotalContainer extends StatelessWidget {
  const _GrandTotalContainer({required this.grandTotal, Key? key})
      : super(key: key);
  final AdminGrandTotal grandTotal;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final tapal = grandTotal.betAmount - grandTotal.hits;
    final isPositive = tapal > 0;
    final color = isPositive ? Colors.green[600] : Colors.red[600];
    return InkWell(
      onTap: () {
        final state = context.read<GrandTotalCubit>().state;
        if (state is GrandTotalAdminLoaded) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => LoginSuccessBuilder(
                builder: (user) {
                  return BlocProvider(
                    create: (context) => GrandTotalDrawsCubit(
                        user: UserAccount(id: grandTotal.userId, type: "C"))
                      ..fetch(
                        fromDate: state.fromDate,
                        toDate: state.toDate,
                      ),
                    child: GrandTotalDrawsScaffold(),
                  );
                },
              ),
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "${grandTotal.createdBy}",
              style: textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.yellow,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "GRAND TOTAL",
                  style: textTheme.subtitle1?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text("BET", style: textTheme.button),
                        Text(
                          "${grandTotal.readableBetAmount}",
                          style: textTheme.subtitle1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Text("HITS", style: textTheme.button),
                        Text(
                          "${grandTotal.readableHits}",
                          style: textTheme.subtitle1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Text("TAPAL/KABIG", style: textTheme.button),
                        Text(
                          "${tapal}",
                          style: textTheme.subtitle1?.copyWith(
                            color: color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GrandTotalLoadingIndicator extends StatelessWidget {
  const GrandTotalLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GrandTotalBuilder(
      builder: (state) => notNil,
      onLoading: Center(child: CircularProgressIndicator.adaptive()),
      onError: (err) => Text(
        "$err",
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }
}
