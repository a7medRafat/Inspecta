import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/reply_type.dart';

extension ReplyTypeLabel on ReplyType {
  String label(AppLocalizations t) => switch (this) {
    ReplyType.accept => t.replyAccept,
    ReplyType.offer => t.replyOffer,
    ReplyType.reject => t.replyReject,
  };
}
