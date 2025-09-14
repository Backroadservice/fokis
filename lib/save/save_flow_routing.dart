/// �ۑ�API��HTTP�X�e�[�^�X��UI����Ƀ}�b�v���鏃Dart�w�B
/// Flutter/UI ����� SaveRouting.routeFor(status) ���ĂԂ����ɂ���B
library save_flow_routing;

/// �������]���o�̗L��/�����i�{�Ԃ� false �� Canary �� true�j
const bool conflictResolverEnabled = true;

/// UI���Ŏ�蓾�镪��
enum UiRoute {
  stay,                   // ���̂܂܁iSnackBar���j
  closeEditor,            // ���� �� �G�f�B�^�����
  openConflictResolver,   // ����������ʂ�
  showDialog,             // �_�C�A���O�\���i�v��/�ē��j
}

/// ���[�e�B���O���ʁiUI�ɓn���Œ���̏��j
class SaveRoutingDecision {
  final UiRoute route;
  final String message;     // �\�����b�Z�[�W
  final bool canRetry;      // �Ď��s�\��
  final bool showOpenAction; // SnackBar�Ɂu�J���v���̃A�N�V�������o�����i409�z��j

  const SaveRoutingDecision({
    required this.route,
    required this.message,
    this.canRetry = false,
    this.showOpenAction = false,
  });

  @override
  String toString() =>
      'SaveRoutingDecision(route=$route, canRetry=$canRetry, showOpenAction=$showOpenAction, msg="$message")';
}

/// ���C���̃}�b�s���O�֐�
SaveRoutingDecision routeForHttp(int status, {bool resolverEnabled = conflictResolverEnabled}) {
  switch (status) {
    case 200:
    case 201:
      return const SaveRoutingDecision(
        route: UiRoute.closeEditor,
        message: '�ۑ����܂���',
        canRetry: false,
      );

    case 409:
      if (resolverEnabled) {
        return const SaveRoutingDecision(
          route: UiRoute.openConflictResolver,
          message: '�T�[�o�[���ōX�V������܂����i�����j�B�������܂����H',
          canRetry: false,
          showOpenAction: true,
        );
      } else {
        return const SaveRoutingDecision(
          route: UiRoute.stay,
          message: '�������������܂����i��ŉ�����ʂ�񋟁j',
          canRetry: true,
          showOpenAction: false,
        );
      }

    case 413: // Payload Too Large
      return const SaveRoutingDecision(
        route: UiRoute.showDialog,
        message: '�ۑ��f�[�^���傫�����܂��B�N���b�v����𑜓x�������Ă��������B',
        canRetry: false,
      );

    case 422: // Unprocessable Entity
      return const SaveRoutingDecision(
        route: UiRoute.showDialog,
        message: '���͂ɕs��������܂��B�n�C���C�g�ӏ����C���̂����ĕۑ����Ă��������B',
        canRetry: true,
      );

    case 408: // Request Timeout
      return const SaveRoutingDecision(
        route: UiRoute.stay,
        message: '�^�C���A�E�g���܂����B�l�b�g���[�N�����m�F�̂����Ď��s���Ă��������B',
        canRetry: true,
      );

    default:
      if (status >= 500 && status < 600) {
        return const SaveRoutingDecision(
          route: UiRoute.stay,
          message: '�T�[�o�[�G���[���������܂����B���΂炭���Ă���Ď��s���Ă��������B',
          canRetry: true,
        );
      }
      return SaveRoutingDecision(
        route: UiRoute.stay,
        message: '����`�̃X�e�[�^�X����M���܂����i$status�j�B',
        canRetry: true,
      );
  }
}
