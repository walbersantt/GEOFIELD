/// Flags de desenvolvimento, alteradas manualmente e com revisão.
///
/// Quando [kDevBypassAuth] é true, o AuthGate ignora a autenticação e mostra a
/// MainShell direto, sem exigir que o Supabase esteja configurado. Isso permite
/// navegar pelas telas do app enquanto o .env ainda não foi preenchido.
///
/// Quando false, o fluxo real de login volta a valer normalmente.
///
/// IMPORTANTE: esta flag deve ser definida como false antes de qualquer build
/// de produção ou teste de integração com Supabase. Não é lida de .env nem de
/// SharedPreferences: é uma constante em tempo de compilação.
const bool kDevBypassAuth = false;
