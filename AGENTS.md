# AGENTS.md — GeoField

Documento de contexto compartilhado para o OpenCode (e para qualquer agente que trabalhe neste repositório). Leia antes de alterar qualquer arquivo. Em caso de conflito entre este documento e o código, **o código vigente vence**; atualize este arquivo quando uma decisão mudar.

## 1. Visão do projeto

**GeoField** é um app mobile Flutter/Dart, offline-first, para levantamentos topográficos e captura de pontos GPS em campo. Público-alvo: agrimensores, topógrafos e profissionais que medem terrenos. O app permite criar levantamentos, capturar pontos (manual e automático), visualizar em mapa, calcular distância/perímetro/área e sincronizar com Supabase quando houver conexão.

**Slogan interno:** medir em campo, com ou sem sinal.

## 2. Stack fixa (não alterar sem discussão)

- Flutter 3.50.1 / Dart 3.14.0 (stable)
- **UI:** `package:material_ui/material_ui.dart` — **não migrar** para `package:flutter/material.dart`. `dart fix --dry-run --code=migrate_design_widgets` retornou `Nothing to fix!`.
- **Backend:** `supabase_flutter ^2.18.3` (inicializa com `publishableKey`; `anonKey` está depreciado). Auth por e-mail/senha + Google via `signInWithOAuth` com `redirectTo: 'geofield://login-callback'`. **Sem `google_sign_in` e sem client IDs no app.**
- **Banco local:** Drift (`drift ^2.35.4`, `drift_flutter ^0.3.1`) + `syncable ^1.0.3`. Código gerado em `lib/data/app_database.g.dart` — **não editar manualmente**.
- **Mapa:** `flutter_map ^8.3.2` + `latlong2 ^0.10.1`.
- **Localização:** `flutter_offline_background_location ^1.0.0` (expõe apenas `intervalMinutes`; não há stream nem leitura única). **Não adicionar `geolocator`** — decisão registrada.
- **Permissões:** `permission_handler ^13.0.2`.
- **Conectividade:** `connectivity_plus ^7.3.2`.
- **Env:** `flutter_dotenv ^6.0.2`.
- **Utilitários:** `uuid ^4.6.0`, `equatable ^3.0.0`.
- **Dev:** `drift_dev ^2.35.3`, `build_runner ^2.17.1`.

## 3. Estrutura de pastas
lib/
app.dart # MaterialApp + AuthGate
main.dart # bootstrap: Env.load → SupabaseConfig.initialize → runApp
config/
env.dart # leitura de SUPABASE_URL / SUPABASE_ANON_KEY
supabase_config.dart # Supabase.initialize + client
dev_flags.dart # kDevBypassAuth (temporário, ver §7)
data/
app_database.dart # Drift + syncable
app_database.g.dart # gerado, não editar
models/
survey.dart # row class Survey
point.dart # row class SurveyPoint
screens/
foundation_home.dart # referência histórica da Etapa 2 (não usada como home)
main_shell.dart # bottom nav: Início / Levantamentos / Perfil
auth/
auth_gate.dart # decide entre LoginScreen e MainShell
login_screen.dart # login real
home/home_screen.dart # Home real
measure/measure_screen.dart # Medir terreno (print 3, simulado, sem persistência)
measure/gps_quality_screen.dart # Qualidade do GPS (print 7, valores simulados, sem persistência)
notes/notes_screen.dart # Registrar anotações (print 4, simulado, sem persistência)
camera/camera_screen.dart # Fotografar (print 5, câmera placeholder, sem persistência)
surveys/survey_details_screen.dart # Detalhes do levantamento (print 7, mock em memória, sem persistência)
surveys/surveys_screen.dart # placeholder
profile/profile_screen.dart # placeholder
services/
auth_service.dart # encapsula Supabase Auth; traduz erros para pt-BR
widgets/
connectivity_state.dart # detecção de conectividade
supabase/
schema.sql # tabelas, RLS, trigger de conflito, publicação Realtime
DESIGN.md # tokens visuais extraídos do Figma
.env # credenciais locais (ignorado no git)
.env.example # placeholders exatos


## 4. Banco de dados Supabase

Tabelas em `supabase/schema.sql` (executar manualmente no SQL Editor do Supabase):

- `public.surveys` — `id`, `user_id`, `created_at`, `updated_at`, `deleted`, `name`, `description`. PK `(id, user_id)`.
- `public.points` — `id`, `user_id`, `survey_id`, `created_at`, `updated_at`, `deleted`, `latitude`, `longitude`, `accuracy`, `source` (`manual`/`automatic`), `captured_at`. PK `(id, user_id)`.

Já inclui: RLS por `auth.uid() = user_id`, trigger `discard_older_updates()` (descarta atualização mais antiga em conflito entre dispositivos), publicação `supabase_realtime` para `syncable`.

## 5. Decisões travadas

- Exclusão é **lógica** (`deleted`), nunca física.
- `material_ui` mantido; não migrar.
- Não adicionar `geolocator`.
- Google OAuth sem `google_sign_in`; redirect `geofield://login-callback` (a registrar no `AndroidManifest.xml` e no Supabase Dashboard — pendente).
- `AuthService` usa `SupabaseConfig.client` (que retorna `Supabase.instance.client`) para respeitar a inicialização feita em `main.dart`.
- `AuthException` é traduzido para `AuthFailure` com mensagem em pt-BR; erros do stream não chegam à UI.
- `signUp` e `resetPasswordForEmail` usam `kAuthRedirectTo` (`geofield://login-callback`).
- Todos os valores visuais vêm de `DESIGN.md`. Se um valor do print não estiver no `DESIGN.md`, usar o valor do print e registrar em comentário no código que veio do print.
- `hover`/`disabled`/`focus` não foram definidos no Figma: implementar apenas estado normal; `disabled` usa opacidade padrão do Material 3, com comentário registrando a decisão. **Não inventar cores de hover/focus.**
- Não inventar credenciais, IDs ou dados fictícios. Onde o print mostra dados de exemplo (nome, levantamento, coordenadas), usar dados reais quando existirem e placeholders neutros quando não existirem.

## 6. Estado atual do código

**Concluído e validado** (`dart analyze` limpo, `flutter test` passando):

- Etapa 1: diagnóstico do template; nenhuma funcionalidade GeoField existia antes.
- Etapa 2 (Fundação): `pubspec.yaml`, `.env`/`.env.example`, `.gitignore`, `lib/config/`, `lib/data/` (+ `.g.dart`), `lib/models/`, `lib/widgets/connectivity_state.dart`, `lib/app.dart`, `lib/main.dart`, `supabase/schema.sql`, `test/widget_test.dart`. `DESIGN.md` criado.
- Etapa 3.1: `lib/services/auth_service.dart`.
- Etapa 4.1: `lib/screens/main_shell.dart` + placeholders de Home, Levantamentos e Perfil.
- Ajuste pré-4.2: `AuthGate`, `FoundationHome` movida para arquivo separado, `lib/app.dart` apontando para `AuthGate`.
- Etapa 4.2: `lib/screens/auth/login_screen.dart` revisado contra o print (logo placeholder `Icons.eco` até o SVG do Figma ser exportado).
- Etapa 4.3: `lib/screens/home/home_screen.dart` real (saudação dinâmica, avatar, cards de levantamento em estado vazio, grade de acesso rápido com SnackBar "Em breve", cards de levantamento com SnackBar "Em breve").
- Etapa 4.4: `lib/screens/measure/measure_screen.dart` — "Medir terreno" do print 3, mapa placeholder, pontos simulados e cálculos de área/perímetro; sem GPS real, sem `flutter_map` e sem persistência.
- Etapa 4.5: `lib/screens/notes/notes_screen.dart` — "Registrar anotações" do print 4, textos simulados, campo de texto e botões com SnackBar "Em breve"; sem persistência. Acesso ligado na Home e na tela "Medir terreno".
- Etapa 4.6: `lib/screens/camera/camera_screen.dart` — "Fotografar" do print 5, fundo `#234B3A`, visor placeholder 3:4, miniaturas simuladas e botões creme "Capturar"/"Ver todas as fotos" com SnackBar "Em breve"; sem câmera real e sem persistência. Acesso ligado na Home e na tela "Medir terreno".
- Etapa 4.7: `lib/screens/surveys/survey_details_screen.dart` — "Detalhes do levantamento" do print 7, mock em memória ("Sítio Boa Vista", área/perímetro e P01–P06) e quatro ações com SnackBar "Em breve"; sem Drift, mapa, galeria ou CSV reais. Acesso ligado no card "Último levantamento" da Home.
- Etapa 4.8: `lib/screens/measure/gps_quality_screen.dart` — "Qualidade do GPS" do print 7, precisão/coordenadas simuladas e aviso obrigatório do §7; botões "Tentar novamente" e "Salvar ponto mesmo assim" com SnackBar "Em breve". O botão "Finalizar" de `MeasureScreen` agora abre esta tela (sem persistência).
- Bypass temporário: `lib/config/dev_flags.dart` com `kDevBypassAuth = true`; `auth_gate.dart` com early return para `MainShell`; `test/widget_test.dart` ajustado para a `MainShell`.

**Pendente:**

- Telas de cadastro e recuperação de senha (o OpenCode não consegue ler os prints; precisam de descrição em texto).
- CRUD de levantamentos (Drift + Supabase + syncable).
- Captura de pontos manual e automática.
- Mapa real (`flutter_map`) com marcadores, polyline, polygon.
- Cálculos de distância, perímetro e área ligados aos pontos reais.
- Sincronização com Supabase e tratamento de conflitos na UI.
- Deep link Android `geofield://login-callback` no `AndroidManifest.xml` e cadastro da URL no Supabase Dashboard.
- Ligação dos callbacks `onRegisterTap` / `onForgotPasswordTap` no `AuthGate` quando as telas existirem.
- Substituição do logo `Icons.eco` pelo SVG do Figma.
- Versões reais de Levantamentos e Perfil.

## 7. Pendências conhecidas e armadilhas

- `.env` local está vazio (`SUPABASE_URL=`, `SUPABASE_ANON_KEY=`). O usuário deve preencher. Nunca colocar a `service_role` key no app; usar apenas a publishable/anon.
- `kDevBypassAuth = true` em `lib/config/dev_flags.dart` faz o app abrir direto na `MainShell`, ignorando o login. **Desligar (`false`) antes de qualquer build de produção ou teste de integração com Supabase real.** Ao desligar, ajustar `test/widget_test.dart` de volta para verificar "Bem-vindo de volta".
- `flutter pub get` no Windows pode falhar com `Building with plugins requires symlink support`. Solução: ativar Developer Mode (`start ms-settings:developers`) ou rodar terminal como administrador. Isso não impede `dart analyze` nem `flutter test`.
- `dart run build_runner build --delete-conflicting-outputs` funciona, mas a opção `--delete-conflicting-outputs` é avisada como removida/ignorada; `dart run build_runner build` também é válido.
- A API do Figma atingiu o limite do plano Starter. **Não chamar `get_design_context` nem `get_screenshot`** até segunda ordem; usar `DESIGN.md` e as descrições em texto dos prints.
- Projeto sem commits (`git status --short` mostra `?? ./`). Fazer commit inicial antes de mudanças grandes é recomendado.
- O aviso de precisão do GPS é obrigatório onde couber: "coordenadas de GPS de smartphone não são topograficamente precisas; a precisão depende do dispositivo, do ambiente e do sinal GNSS."

## 8. Regras de trabalho com o OpenCode

- Trabalhar em sub-passos pequenos, um por vez, aguardando confirmação entre eles.
- Para cada sub-passo, informar: arquivos criados/alterados, finalidade de cada um, código completo quando substituir arquivo, local exato, comandos de terminal e como testar manualmente.
- Não declarar um sub-passo concluído sem `dart analyze` limpo e `flutter test` passando.
- Não criar projeto Flutter novo. Não substituir código que funciona. Preservar `lib/config/`, `lib/data/`, `lib/models/`, `lib/widgets/connectivity_state.dart`, `lib/services/auth_service.dart`, `lib/app.dart`, `lib/main.dart`, `supabase/schema.sql`, `DESIGN.md`.
- Não inventar funcionalidades não implementadas, nem apresentar planejamento como concluído.
- Não inventar resultados de testes, credenciais, IDs ou referências.
- Textos em pt-BR. Material 3 limpo/profissional. Botões grandes.

## 9. Comandos úteis

```bash
cd C:\projetos\GEOFIELD\geofield
flutter pub get
dart run build_runner build
dart analyze
flutter test
flutter run

10. Histórico de decisões (ordem cronológica)
Stack fixada (Flutter, Supabase, Drift, syncable, flutter_map, flutter_offline_background_location).

material_ui mantido; sem migração.

Sem geolocator; respeitar intervalMinutes do plugin.

Google OAuth via signInWithOAuth + geofield://login-callback; sem google_sign_in.

.env local criado vazio para o asset existir.

DESIGN.md gerado a partir do Figma (tokens reais).

Bypass de autenticação via kDevBypassAuth para navegar enquanto o Supabase não está configurado.

8.Home real implementada com dados reais quando existirem e placeholders neutros quando não