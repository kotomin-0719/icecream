import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CrepeApp(),
    ),
  );
}

class CrepeApp extends StatefulWidget {
  const CrepeApp({super.key});

  @override
  State<CrepeApp> createState() => _CrepeAppState();
}

class _CrepeAppState extends State<CrepeApp> {
  // =========================
  // 商品
  // =========================

  final foods = {
    '🍫 チョコクレープ': 500,
    '🍓 いちごクレープ': 550,
    '🍌 バナナクレープ': 500,
  };

  final foodCosts = {
    '🍫 チョコクレープ': 180,
    '🍓 いちごクレープ': 220,
    '🍌 バナナクレープ': 190,
  };

  late String food = foods.keys.first;

  // =========================
  // 生地
  // =========================

  final batters = {
    'プレーン': 0,
    'チョコ': 50,
    '抹茶': 50,
  };

  String batter = 'プレーン';

  // =========================
  // サイズ
  // =========================

  final sizes = {
    'S': -50,
    'M': 0,
    'L': 100,
  };

  String size = 'M';

  // =========================
  // トッピング
  // =========================

  final toppingPrices = {
    '🍓 いちご': 150,
    '🍌 バナナ': 100,
    '🍫 チョコソース': 80,
    '☁️ ホイップ': 80,
    '🍨 アイス': 150,
  };

  final toppingCosts = {
    '🍓 いちご': 70,
    '🍌 バナナ': 40,
    '🍫 チョコソース': 20,
    '☁️ ホイップ': 30,
    '🍨 アイス': 60,
  };

  final selectedToppings = <String>{};

  // =========================
  // 無料サービス
  // =========================

  bool spoon = false;
  bool napkin = false;
  bool bag = false;

  // =========================
  // 注文
  // =========================

  int order = 0;
  String receipt = '';

  // =========================
  // 1つだけ選ぶボタン
  // =========================

  Widget choiceButtons(
    Iterable<String> items,
    String value,
    void Function(String) change,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          ChoiceChip(
            label: Text(item),
            selected: value == item,
            selectedColor: const Color(0xFFFFC1CC),
            backgroundColor: Colors.white,
            onSelected: (_) {
              setState(() {
                change(item);
              });
            },
          ),
      ],
    );
  }

  // =========================
  // 無料サービス
  // =========================

  Widget serviceCheckbox(
    String label,
    bool value,
    void Function(bool) change,
  ) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      activeColor: const Color(0xFFE86A92),
      onChanged: (v) {
        setState(() {
          change(v ?? false);
        });
      },
    );
  }

  // =========================
  // タイトル
  // =========================

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6D4C41),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // =========================
    // トッピング料金
    // =========================

    int toppingTotal = 0;

    for (final topping in selectedToppings) {
      toppingTotal += toppingPrices[topping]!;
    }

    // =========================
    // セット割引
    // いちご + ホイップで50円引き
    // =========================

    final bool setDiscount =
        selectedToppings.contains('🍓 いちご') &&
        selectedToppings.contains('☁️ ホイップ');

    final int discount = setDiscount ? 50 : 0;

    // =========================
    // 税抜価格
    // =========================

    final subtotal =
        foods[food]! +
        batters[batter]! +
        sizes[size]! +
        toppingTotal -
        discount;

    // 消費税10%
    final tax = subtotal ~/ 10;

    // 税込
    final total = subtotal + tax;

    // =========================
    // 原価計算
    // =========================

    int totalCost = foodCosts[food]!;

    for (final topping in selectedToppings) {
      totalCost += toppingCosts[topping]!;
    }

    // 生地の追加原価
    if (batter != 'プレーン') {
      totalCost += 20;
    }

    // Lサイズの追加原価
    if (size == 'L') {
      totalCost += 40;
    }

    // Sなら少し原価が安くなる
    if (size == 'S') {
      totalCost -= 20;
    }

    // 税抜売上 - 原価
    final profit = subtotal - totalCost;

    // =========================
    // 商品選択
    // =========================

    final products = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in foods.keys)
          ChoiceChip(
            label: Text('$item ${foods[item]}円'),
            selected: food == item,
            selectedColor: const Color(0xFFFFC1CC),
            backgroundColor: Colors.white,
            onSelected: (_) {
              setState(() {
                food = item;
              });
            },
          ),
      ],
    );

    // =========================
    // トッピング
    // =========================

    final toppings = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final topping in toppingPrices.keys)
          FilterChip(
            label: Text(
              '$topping +${toppingPrices[topping]}円',
            ),
            selected: selectedToppings.contains(topping),
            selectedColor: const Color(0xFFFFD9E2),
            backgroundColor: Colors.white,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedToppings.add(topping);
                } else {
                  selectedToppings.remove(topping);
                }
              });
            },
          ),
      ],
    );

    // =========================
    // 注文票
    // =========================

    final ticket = order == 0
        ? const SizedBox.shrink()
        : Card(
            margin: const EdgeInsets.only(top: 24),
            color: Colors.white,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🧾 注文番号 #$order',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Text(
                    receipt,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),

      // =========================
      // 上部
      // =========================

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFFB7C5),
        foregroundColor: const Color(0xFF6D4C41),
        title: const Text(
          '🥞 Crepe Shop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // =========================
      // 本文
      // =========================

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // メインビジュアル

              const Center(
                child: Text(
                  '🥞🍓',
                  style: TextStyle(
                    fontSize: 80,
                  ),
                ),
              ),

              const Center(
                child: Text(
                  'My Crepe',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE86A92),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              const Center(
                child: Text(
                  '好きな組み合わせで、自分だけのクレープを作ろう！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF795548),
                  ),
                ),
              ),

              // =========================
              // 商品
              // =========================

              sectionTitle('① クレープを選ぶ'),

              products,

              // =========================
              // 生地
              // =========================

              sectionTitle('② 生地を選ぶ'),

              choiceButtons(
                batters.keys.map(
                  (name) => batters[name] == 0
                      ? name
                      : '$name +${batters[name]}円',
                ),
                batter,
                (selected) {
                  batter = selected.split(' ').first;
                },
              ),

              // =========================
              // サイズ
              // =========================

              sectionTitle('③ サイズを選ぶ'),

              choiceButtons(
                [
                  'S -50円',
                  'M',
                  'L +100円',
                ],
                size,
                (selected) {
                  size = selected.split(' ').first;
                },
              ),

              // =========================
              // トッピング
              // =========================

              sectionTitle('④ トッピングを選ぶ'),

              toppings,

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🍓 いちご ＋ ☁️ ホイップを選ぶと50円OFF！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE0527D),
                  ),
                ),
              ),

              // 割引表示

              if (setDiscount)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    '🎉 おすすめセット割 −50円',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // =========================
              // 無料サービス
              // =========================

              sectionTitle('⑤ 無料サービス'),

              serviceCheckbox(
                '🥄 スプーン',
                spoon,
                (v) => spoon = v,
              ),

              serviceCheckbox(
                '🧻 ナプキン',
                napkin,
                (v) => napkin = v,
              ),

              serviceCheckbox(
                '🛍️ 持ち帰り袋',
                bag,
                (v) => bag = v,
              ),

              const Divider(height: 40),

              // =========================
              // 金額
              // =========================

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '税抜　$subtotal円',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '消費税　$tax円',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '合計　$total円',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE86A92),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // 注文ボタン
              // =========================

              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE86A92),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    order = Random().nextInt(999) + 1;

                    receipt =
                        '$food\n'
                        '生地：$batter\n'
                        'サイズ：$size\n'
                        'トッピング：'
                        '${selectedToppings.isEmpty ? 'なし' : selectedToppings.join('・')}\n'
                        '${setDiscount ? '🎉 セット割：−50円\n' : ''}'
                        '\n'
                        '🥄 スプーン：${spoon ? 'あり' : 'なし'}\n'
                        '🧻 ナプキン：${napkin ? 'あり' : 'なし'}\n'
                        '🛍️ 持ち帰り袋：${bag ? 'あり' : 'なし'}\n'
                        '\n'
                        '税抜：$subtotal円\n'
                        '消費税：$tax円\n'
                        '合計：$total円';
                  });
                },
                child: const Text(
                  '🥞 注文する',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 注文票

              ticket,

              // =========================
              // 利益表示
              // =========================

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBC8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Text(
                      '💰 店舗用：利益シミュレーション',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '想定原価：$totalCost円',
                    ),

                    Text(
                      '税抜売上：$subtotal円',
                    ),

                    Text(
                      '想定利益：$profit円',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}