import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provide/provide.dart';

import '../provide/index.dart';
import 'my_bottom_sheet.dart';
import 'shop_car_list_widget.dart';

// 购物车

class ShopCar extends StatefulWidget {
  ShopCar({Key key}) : super(key: key);

  @override
  State createState() => _ShopCarState();
}

class _ShopCarState extends State<ShopCar> with WidgetsBindingObserver {
  GlobalKey _shopCarImageKey = GlobalKey();
  GlobalKey<NavigatorState> _navigator = GlobalKey();

  bool _isHideChildNavigator = true;

  Future<void> _toggleBottomSheet() async {
    if (_isHideChildNavigator) {
      // 显示导航
      setState(() {
        _isHideChildNavigator = false;
      });

      // 入栈  弹出底部弹窗
      await _navigator.currentState.push(ModalBottomSheetRoute<void>(
        builder: (context) => ShopCarList(),
        theme: Theme.of(context, shadowThemeOnly: true),
        isScrollControlled: false,
        backgroundColor: Colors.transparent,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      ));

      await _hideBottomSheet();
    } else {
      // 出栈
      _navigator.currentState.pop();
      await _hideBottomSheet();
    }
  }

  Future<void> _hideBottomSheet() async {
    // 等待关闭动画执行
    await Future.delayed(Duration(milliseconds: 300));
    // 隐藏导航
    setState(() {
      _isHideChildNavigator = true;
    });
  }

  // 创建圆形的购物车Widget
  Widget _buildShopCarImage(BuildContext context) {
    return SizedBox(
      key: _shopCarImageKey,
      width: 60,
      height: 60,
      child: Provide<ShopCarProvide>(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF141D27),
            shape: BoxShape.circle,
          ),
        ),
        builder: (context, child, shopCarProvide) {
          int count = shopCarProvide.allCount;
          // 是否隐藏 总件数
          bool isHideCounter = count <= 0;
          if (count <= 0) {
            if (!_isHideChildNavigator) {
              // 正在显示中
//              _hideBottomSheet();
            }
          }
          return CupertinoButton(
            minSize: 0,
            pressedOpacity: 1,
            padding: EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                child,
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Color(isHideCounter ? 0xFF2B343C : 0xFF0087E3),
                    shape: BoxShape.circle,
                  ),
                ),
                Image.asset(isHideCounter ? 'assets/icon_shop_car.png' : 'assets/icon_shop_car_white.png', width: 32),
                Positioned(
                  top: 0,
                  right: 0,
                  width: 26,
                  height: 14,
                  child: Offstage(
                    offstage: isHideCounter,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        color: Color(0xFFF01414),
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: TextStyle(fontSize: 10, color: CupertinoColors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              _toggleBottomSheet();
            },
          );
        },
      ),
    );
  }

  // 创建底部黑色条
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: Color(0xFF141D27),
      child: Provide<ShopCarProvide>(
        builder: (context, child, shopCarProvide) {
          int totalPrice = shopCarProvide.totalPrice;
          String giveText;
          if (totalPrice == 0) {
            giveText = '¥20元起送';
          } else if (totalPrice < 20) {
            giveText = '还差${20 - totalPrice}元起送';
          } else {
            giveText = '去结算';
          }
          return Row(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: 80)),
              Text('¥$totalPrice', style: TextStyle(fontSize: 16, color: totalPrice > 0 ? CupertinoColors.white : Color(0xFF606060), fontWeight: FontWeight.bold)),
              Padding(padding: EdgeInsets.only(left: 10)),
              Container(
                height: 30,
                width: 1,
                color: Color(0xFF606060),
              ),
              Padding(padding: EdgeInsets.only(left: 10)),
              Text('另需配送费¥4元', style: TextStyle(fontSize: 12, color: Color(0xFF606060), fontWeight: FontWeight.bold)),
              Expanded(child: Container()),
              Container(
                width: 100,
                color: totalPrice < 20 ? Color(0xFF2B343C) : Color(0xFF00B43C),
                alignment: Alignment.center,
                child: Text(
                  giveText,
                  style: TextStyle(
                    fontSize: 12,
                    color: totalPrice < 20 ? Color(0xFF606060) : CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void initShopCarPosition() {
    final ballAnimProvide = Provide.value<BallAnimProvide>(context);
    RenderBox renderBox = _shopCarImageKey.currentContext.findRenderObject();
    // 购物车大小存储到全局
    ballAnimProvide.shopCarSize = renderBox.size;
    // 购物车在屏幕的位置存储到全局
    ballAnimProvide.shopCarPosition = renderBox.localToGlobal(Offset.zero);
  }

  void _onAfterRendering(Duration timeStamp) {
    // 绘制完成的第一帧调用  并且只调用一次
    initShopCarPosition();
  }

  @override
  void didChangeDependencies() {
    // 无需调用移出方法,因为当回调执行后,里边的List会被自动清空
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ShopCar oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // 购物车列表
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 50,
          child: Offstage(
            offstage: _isHideChildNavigator,
            // 子导航
            child: Navigator(
              key: _navigator,
              onGenerateRoute: (settings) {
                // 显示的时候默认回调用一次,用于构建根路由的Widget,所以必须返回一个路由
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => Container(),
                );
              },
            ),
          ),
        ),
        // 底部购物车条
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 60,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 50,
                child: _buildBottomBar(context),
              ),
              Positioned(
                left: 10,
                width: 60,
                height: 60,
                child: _buildShopCarImage(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
