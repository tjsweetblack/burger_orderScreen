import 'package:auth_bloc/helpers/extensions.dart';
import 'package:flutter/material.dart';

import '../../../../routing/routes.dart';
import '../../../../theming/styles.dart';

class DoNotHaveAccountText extends StatelessWidget {
  const DoNotHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(Routes.signupScreen);
      },
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Ainda não tem uma conta?',
              style: TextStyles.font11DarkBlue400Weight,
            ),
            TextSpan(
              text: ' Cadastre-se',
              style: TextStyles.font11Blue600Weight,
            ),
          ],
        ),
      ),
    );
  }
}
