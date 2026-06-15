# OvsbMissing - Gerenciador Inteligente de Faltas Escolares

Um aplicativo Android desenvolvido em Flutter para auxiliar estudantes a gerenciar estrategicamente suas faltas escolares.

## 👤 Créditos

**Desenvolvido por:** @BeaGabi.cnt  
**GitHub:** [github.com/Gabicnt](https://github.com/Gabicnt)

## 🎯 Funcionalidades

- ✅ Cadastro de período letivo com datas e frequência mínima
- ✅ Cálculo automático de faltas permitidas
- ✅ Margem de segurança configurável (percentual ou absoluta)
- ✅ Sugestão inteligente de dias para faltar
- ✅ Calendário visual com cores (estilo Kindle monocromático)
- ✅ Registro de faltas (planejadas e realizadas)
- ✅ Eventos: dias importantes, ausências forçadas, atividades
- ✅ Busca automática de feriados (BrasilAPI)
- ✅ Backup e restauração de dados
- ✅ Notificações locais

## 🎨 Design

Interface minimalista monocromática inspirada em dispositivos Kindle:
- Preto (#000000) - textos principais
- Cinza escuro (#333333) - textos secundários
- Cinza médio (#999999) - elementos inativos
- Cinza claro (#E0E0E0) - bordas e separadores
- Off-white (#F5F5F0) - fundo de tela
- Branco (#FFFFFF) - cards e diálogos

## 🚀 Como executar

### Pré-requisitos

1. Flutter SDK 3.0+ instalado
2. Android Studio ou VS Code com extensões Flutter
3. Dispositivo Android ou emulador

### Instalação

```bash
# Clone ou copie os arquivos para seu projeto Flutter
cd flutter_project

# Instale as dependências
flutter pub get

# Execute em modo debug
flutter run

# Gere o APK
flutter build apk --release
```

### Baixar fontes Inter

Baixe a fonte Inter do Google Fonts e coloque em:
- `assets/fonts/Inter-Regular.ttf`
- `assets/fonts/Inter-Medium.ttf`
- `assets/fonts/Inter-SemiBold.ttf`
- `assets/fonts/Inter-Bold.ttf`

Ou remova a seção `fonts` do `pubspec.yaml` para usar Google Fonts via download.

## 📁 Estrutura do Projeto

```
lib/
├── main.dart              # Entry point
├── app.dart               # Tema e configuração do app
├── models/                # Modelos de dados
│   ├── periodo.dart
│   ├── falta.dart
│   ├── evento.dart
│   └── dia_especial.dart
├── providers/             # Gerenciamento de estado
│   ├── periodo_provider.dart
│   ├── faltas_provider.dart
│   ├── eventos_provider.dart
│   └── settings_provider.dart
├── services/              # Serviços
│   ├── database_service.dart
│   ├── feriados_service.dart
│   ├── notification_service.dart
│   ├── connectivity_service.dart
│   └── backup_service.dart
├── screens/               # Telas
│   ├── home_screen.dart
│   ├── setup_screen.dart
│   ├── calendar_screen.dart
│   └── settings_screen.dart
├── widgets/               # Componentes reutilizáveis
│   ├── card_saldo.dart
│   ├── mini_calendario.dart
│   ├── bottom_sheet_dia.dart
│   └── evento_form.dart
└── utils/                 # Utilitários
    ├── cores.dart
    ├── constantes.dart
    └── calculos.dart
```

## 📊 Banco de Dados

SQLite local com as tabelas:
- `periodos` - Configuração do período letivo
- `dias_especiais` - Feriados, recessos, dias importantes
- `faltas` - Registro de faltas
- `eventos` - Eventos do calendário
- `configuracoes` - Preferências do app
- `feriados_cache` - Cache de feriados da API

## 🔧 Configurações Android

### android/app/src/main/AndroidManifest.xml

Adicione as permissões necessárias:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### Configurar notificações

No arquivo `android/app/src/main/res/values/styles.xml`, adicione:

```xml
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:windowBackground">@drawable/launch_background</item>
</style>
```

## 📝 Regras de Negócio

### Cálculo de faltas
- **Dias letivos** = total de dias no período - fins de semana - feriados
- **Faltas permitidas** = dias letivos × (1 - frequência mínima)
- **Saldo disponível** = faltas permitidas - faltas usadas - margem

### Margem de segurança
- Percentual: Ex: 10% das faltas permitidas
- Absoluta: Ex: reservar 2 faltas fixas

### Sugestão inteligente
O algoritmo prioriza dias que:
- Não sejam fins de semana ou feriados
- Não sejam dias importantes (provas)
- Tenham pelo menos 2 dias de distância de dias importantes
- Preferencialmente segundas ou sextas (estender fim de semana)

## 🌐 APIs Externas

- **BrasilAPI**: Feriados nacionais
  - `GET https://brasilapi.com.br/api/feriados/v1/{ano}`

## 📄 Licença

MIT License - Uso livre para fins educacionais.

---

Desenvolvido com ❤️ por **@BeaGabi.cnt** para estudantes que precisam gerenciar suas faltas com inteligência.

🔗 [GitHub](https://github.com/Gabicnt)
