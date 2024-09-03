import 'package:ficha3/BASE_DE_DADOS/APIS/api_usuarios.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_codigoverificacao.dart';
import 'package:ficha3/PAGINA_DE_LOGIN/PaginaLogin.dart';
import 'package:flutter/material.dart';

class PasswordResetPage extends StatefulWidget {
  final String email;

  const PasswordResetPage({super.key, required this.email});

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  void _submitCode() async {
    final code = _codeController.text;

    if (code.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        final isValidCode =
            await FuncoesCodigoverificacao.verifyCode(widget.email, code);
        if (isValidCode) {
          // Código de verificação válido, navegue para a página de redefinição de senha
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewPasswordPage(email: widget.email),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código inválido. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao verificar código. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira o código de verificação'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Código'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Digite o código de verificação enviado para seu e-mail',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Código de Verificação',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitCode,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verificar Código'),
            ),
          ],
        ),
      ),
    );
  }
}

class NewPasswordPage extends StatefulWidget {
  final String email;

  const NewPasswordPage({super.key, required this.email});

  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  void _submitNewPassword() async {
  final password = _passwordController.text;
  final confirmPassword = _confirmPasswordController.text;

  if (password.isEmpty || confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor, preencha todos os campos.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('As senhas não coincidem.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // Verifique o email para obter o userId
    final apiUsuarios = ApiUsuarios();
    final user = await apiUsuarios.verificarEmail(widget.email);

    if (user != null) {
      final userId = user['userId'];
      print("-------------------------- USER ID ------------------------ $userId");

      await apiUsuarios.updatePassword(userId, password);
      print("Senha alterada com sucesso!");
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha alterada com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PaginaLogin(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não encontrado.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print("Erro ao alterar a senha: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao alterar a senha: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Senha'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitNewPassword,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Alterar Senha'),
            ),
          ],
        ),
      ),
    );
  }
}
