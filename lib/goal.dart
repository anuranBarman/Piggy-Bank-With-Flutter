import 'payment.dart';

class Goal {
  int id;
  String title;
  double total;
  double saved;
  List<Payment> payments;
  bool isFavorite;

  Goal(this.id,this.title,this.total,this.saved,this.payments,this.isFavorite);

}