part of '../../pay.dart';

const _supportedPlatforms = [TargetPlatform.android];

class GooglePayButton extends StatefulWidget {
  final Pay googlePayClient;

  final RawGooglePayButton googlePayButton;
  final EdgeInsets margin;

  final onPaymentResult;
  final onError;
  final Widget? childOnError;
  final Widget? loadingIndicator;

  const GooglePayButton._(
    Key? key,
    this.googlePayClient,
    this.googlePayButton,
    this.margin,
    this.onPaymentResult,
    this.onError,
    this.childOnError,
    this.loadingIndicator,
  ) : super(key: key);

  factory GooglePayButton({
    Key? key,
    required paymentConfigurationAsset,
    required paymentItems,
    required onPaymentResult,
    type,
    style,
    margin = EdgeInsets.zero,
    onPressed,
    onError,
    childOnError,
    loadingIndicator,
  }) {
    Pay googlePayClient = Pay.fromAsset(paymentConfigurationAsset);
    RawGooglePayButton googlePayButton = RawGooglePayButton(
      type: type,
      style: style,
      margin: margin,
      onPressed: () async {
        onPressed?.call();
        onPaymentResult(
          await googlePayClient.showPaymentSelector(paymentItems: paymentItems),
        );
      },
    );

    return GooglePayButton._(
      key,
      googlePayClient,
      googlePayButton,
      margin,
      onPaymentResult,
      onError,
      childOnError,
      loadingIndicator,
    );
  }

  static bool get supported =>
      _supportedPlatforms.contains(defaultTargetPlatform);

  @override
  _GooglePayButtonState createState() => _GooglePayButtonState();
}

class _GooglePayButtonState extends State<GooglePayButton> {
  late final Future<bool> _userCanPayFuture;

  Widget containerizeChildOrShrink([Widget? child]) {
    if (child != null) {
      return Container(
        margin: widget.margin,
        child: child,
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    _userCanPayFuture = widget.googlePayClient.userCanPay();
  }

  @override
  Widget build(BuildContext context) {
    if (!GooglePayButton.supported) return containerizeChildOrShrink();

    return FutureBuilder<bool>(
      future: _userCanPayFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            widget.onError(snapshot.error);
          }

          if (snapshot.data == true) {
            return widget.googlePayButton;
          } else {
            return containerizeChildOrShrink(widget.childOnError);
          }
        }

        return containerizeChildOrShrink(widget.loadingIndicator);
      },
    );
  }
}
