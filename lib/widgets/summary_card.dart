import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class SummaryCard extends StatefulWidget {
  const SummaryCard({
    super.key,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final displayedBalance = _isVisible
        ? format.format(provider.netBalance)
        : '••••••';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// TOP HEADER
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              /// LEFT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Balance',
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// BALANCE + VISIBILITY
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            displayedBalance,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.bold,
                              letterSpacing: -1,
                              color:
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        InkWell(
                          borderRadius:
                              BorderRadius.circular(
                                  30),
                          onTap: () {
                            setState(() {
                              _isVisible = !_isVisible;
                            });
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration:
                                BoxDecoration(
                              color:
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(
                                          0.08),
                              shape:
                                  BoxShape.circle,
                            ),
                            child: Icon(
                              _isVisible
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                              size: 18,
                              color:
                                  Theme.of(context)
                                      .colorScheme
                                      .primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// SMALL CHIP
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.08),
                        borderRadius:
                            BorderRadius.circular(
                                20),
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons
                                .north_east_rounded,
                            size: 12,
                            color: Theme.of(
                                    context)
                                .colorScheme
                                .primary,
                          ),
                          const SizedBox(
                              width: 4),
                          Text(
                            '100%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
                              color: Theme.of(
                                      context)
                                  .colorScheme
                                  .primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              /// WALLET ICON
              Container(
                width: 62,
                height: 62,
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(
                              0.18),
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(
                              0.06),
                    ],
                  ),
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  Icons
                      .account_balance_wallet_rounded,
                  size: 28,
                  color:
                      Theme.of(context)
                          .colorScheme
                          .primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          /// SUMMARY BOXES
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  value: format.format(
                    provider.totalCredit,
                  ),
                  icon:
                      Icons.arrow_upward_rounded,
                  color:
                      const Color(0xFF2E7D32),
                  hideValue: !_isVisible,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _MetricBox(
                  value: format.format(
                    provider.totalDebit,
                  ),
                  icon:
                      Icons.arrow_downward_rounded,
                  color:
                      const Color(0xFFD32F2F),
                  hideValue: !_isVisible,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.value,
    required this.icon,
    required this.color,
    this.hideValue = false,
  });

  final String value;
  final IconData icon;
  final Color color;
  final bool hideValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .dividerColor
            .withOpacity(0.03),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(0.12),
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  hideValue ? '••••' : value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Theme.of(context)
                            .colorScheme
                            .onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}