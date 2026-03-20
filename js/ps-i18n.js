/**
 * ps-i18n.js — Centralized translation system for The Prompt Studio
 *
 * Usage:
 *   T('plans.starter.desc')          → returns string for current lang
 *   T('plans.starter.desc', 'fr')    → returns string for specific lang
 *   TH('plans.starter.desc')         → returns <span data-fr>...</span><span data-en>...</span> for all langs
 *
 * To add translations: add keys to the I18N object below.
 * To trigger re-renders on lang change: PS_I18N.onChange(callback)
 *
 * Depends on: ps-lang.js (loaded first)
 */
const PS_I18N = (() => {
  'use strict';

  const _callbacks = [];

  /* ════════════════════════════════════════════════════════════════════════
   * TRANSLATIONS
   * ════════════════════════════════════════════════════════════════════════ */
  const I18N = {

    /* ── Common / shared ────────────────────────────────────────────────── */
    common: {
      loading:        { fr: 'Chargement…',       en: 'Loading…',          es: 'Cargando…',         pt: 'Carregando…',        ar: 'جار التحميل…' },
      close:          { fr: 'Fermer',             en: 'Close',             es: 'Cerrar',             pt: 'Fechar',             ar: 'إغلاق' },
      cancel:         { fr: 'Annuler',            en: 'Cancel',            es: 'Cancelar',           pt: 'Cancelar',           ar: 'إلغاء' },
      save:           { fr: 'Enregistrer',        en: 'Save',              es: 'Guardar',            pt: 'Salvar',             ar: 'حفظ' },
      create:         { fr: 'Créer',              en: 'Create',            es: 'Crear',              pt: 'Criar',              ar: 'إنشاء' },
      delete:         { fr: 'Supprimer',          en: 'Delete',            es: 'Eliminar',           pt: 'Excluir',            ar: 'حذف' },
      view_plans:     { fr: 'Voir les offres',    en: 'View plans',        es: 'Ver ofertas',        pt: 'Ver ofertas',        ar: 'عرض الخطط' },
      get_started:    { fr: 'Commencer',          en: 'Get started',       es: 'Empezar',            pt: 'Começar',            ar: 'ابدأ الآن' },
      coming_soon:    { fr: 'Bientôt disponible', en: 'Coming soon',       es: 'Próximamente',       pt: 'Em breve',           ar: 'قريبًا' },
      contact_us:     { fr: 'Nous contacter',     en: 'Contact us',        es: 'Contáctenos',        pt: 'Fale conosco',       ar: 'تواصل معنا' },
      per_mo:         { fr: '€/mois',             en: '€/mo',              es: '€/mes',              pt: '€/mês',              ar: '€/شهر' },
      per_yr:         { fr: '€/an',               en: '€/yr',              es: '€/año',              pt: '€/ano',              ar: '€/سنة' },
      unlimited:      { fr: 'Illimité',           en: 'Unlimited',         es: 'Ilimitado',          pt: 'Ilimitado',          ar: 'غير محدود' },
      free_trial:     { fr: 'Essai gratuit',      en: 'Free trial',        es: 'Prueba gratis',      pt: 'Teste grátis',       ar: 'تجربة مجانية' },
      most_popular:   { fr: 'Le plus populaire',  en: 'Most popular',      es: 'El más popular',     pt: 'O mais popular',     ar: 'الأكثر شعبية' },
      ad_free:        { fr: 'Sans publicité',     en: 'Ad-free',           es: 'Sin anuncios',       pt: 'Sem anúncios',       ar: 'بدون إعلانات' },
      with_ads:       { fr: 'Avec publicités',    en: 'Includes ads',      es: 'Con anuncios',       pt: 'Com anúncios',       ar: 'مع إعلانات' },
    },

    /* ── Navigation / sidebar ───────────────────────────────────────────── */
    nav: {
      my_workspaces:  { fr: 'Mes espaces',        en: 'My workspaces',     es: 'Mis espacios',       pt: 'Meus espaços',       ar: 'مساحاتي' },
      my_projects:    { fr: 'Mes projets',         en: 'My projects',       es: 'Mis proyectos',      pt: 'Meus projetos',      ar: 'مشاريعي' },
      my_account:     { fr: 'Mon compte',          en: 'My account',        es: 'Mi cuenta',          pt: 'Minha conta',        ar: 'حسابي' },
      my_workspace:   { fr: 'Mon espace',          en: 'My workspace',      es: 'Mi espacio',         pt: 'Meu espaço',         ar: 'مساحتي' },
      report_bug:     { fr: 'Signaler un bug',     en: 'Report a bug',      es: 'Reportar un error',  pt: 'Reportar um bug',    ar: 'الإبلاغ عن خطأ' },
      log_out:        { fr: 'Déconnexion',         en: 'Log out',           es: 'Cerrar sesión',      pt: 'Sair',               ar: 'تسجيل الخروج' },
      navigation:     { fr: 'Navigation',          en: 'Navigation',        es: 'Navegación',         pt: 'Navegação',          ar: 'التنقل' },
      feedback:       { fr: 'Feedback',            en: 'Feedback',          es: 'Comentarios',        pt: 'Feedback',           ar: 'ملاحظات' },
      vertical:       { fr: 'Verticale',           en: 'Vertical',          es: 'Vertical',           pt: 'Vertical',           ar: 'قطاع' },
    },

    /* ── Dashboard ──────────────────────────────────────────────────────── */
    dashboard: {
      title:              { fr: 'Mon espace',                                     en: 'My workspace',                                    es: 'Mi espacio',                                      pt: 'Meu espaço',                                     ar: 'مساحتي' },
      page_title:         { fr: 'Mon espace – The Prompt Studio',                 en: 'My workspace – The Prompt Studio',                es: 'Mi espacio – The Prompt Studio',                  pt: 'Meu espaço – The Prompt Studio',                 ar: 'مساحتي – The Prompt Studio' },
      no_sub:             { fr: 'Aucun abonnement actif',                         en: 'No active subscription',                          es: 'Sin suscripción activa',                          pt: 'Nenhuma assinatura ativa',                        ar: 'لا يوجد اشتراك نشط' },
      choose_vertical:    { fr: 'Choisissez votre verticale',                     en: 'Choose your vertical',                            es: 'Elige tu vertical',                               pt: 'Escolha seu vertical',                            ar: 'اختر قطاعك' },
      choose_vertical_desc:{ fr: 'Sélectionnez le secteur qui correspond à votre métier.<br>Vos outils IA seront disponibles immédiatement après souscription.',
                             en: 'Select the industry that matches your work.<br>Your AI tools will be available immediately after subscribing.',
                             es: 'Seleccione el sector de su actividad.<br>Sus herramientas IA estarán disponibles tras suscribirse.',
                             pt: 'Selecione o setor do seu trabalho.<br>Suas ferramentas IA estarão disponíveis após assinar.',
                             ar: 'اختر القطاع المناسب لعملك.<br>أدوات الذكاء الاصطناعي ستكون متاحة فور الاشتراك.' },
      tools_access:       { fr: 'accès aux outils',                              en: 'tools',                                           es: 'herramientas',                                    pt: 'ferramentas',                                     ar: 'أدوات' },
      free_trial_days:    { fr: 'Essai gratuit ({d}j restants)',                  en: 'Free trial ({d}d left)',                           es: 'Prueba gratis ({d}d)',                             pt: 'Teste grátis ({d}d)',                              ar: 'تجربة مجانية ({d} يوم)' },
      gen_per_month:      { fr: 'générations/mois',                               en: 'generations/month',                                es: 'generaciones/mes',                                pt: 'gerações/mês',                                    ar: 'عمليات/شهر' },
      used:               { fr: 'utilisées',                                      en: 'used',                                            es: 'usadas',                                          pt: 'usadas',                                          ar: 'مستخدمة' },
      // Filter buttons
      filter_all:         { fr: 'Tous',              en: 'All',               es: 'Todos',              pt: 'Todos',              ar: 'الكل' },
      filter_available:   { fr: 'Accessibles',       en: 'Available',         es: 'Accesibles',         pt: 'Disponíveis',        ar: 'متاحة' },
      filter_locked:      { fr: 'Verrouillés',       en: 'Locked',            es: 'Bloqueados',         pt: 'Bloqueados',         ar: 'مقفلة' },
      available:          { fr: 'accessibles',       en: 'available',         es: 'accesibles',         pt: 'disponíveis',        ar: 'متاحة' },
      tool:               { fr: 'outil',             en: 'tool',              es: 'herramienta',        pt: 'ferramenta',         ar: 'أداة' },
      tools:              { fr: 'outils',            en: 'tools',             es: 'herramientas',       pt: 'ferramentas',        ar: 'أدوات' },
      no_tools_cat:       { fr: 'Aucun outil dans cette catégorie.',              en: 'No tools in this category.',                      es: 'Sin herramientas en esta categoría.',              pt: 'Nenhuma ferramenta nesta categoria.',              ar: 'لا أدوات في هذه الفئة.' },
      view_all:           { fr: 'Voir tous',         en: 'View all',          es: 'Ver todos',          pt: 'Ver todos',          ar: 'عرض الكل' },
      // Suggest tool
      suggest_tool:       { fr: 'Proposer un outil',                              en: 'Suggest a tool',                                  es: 'Sugerir herramienta',                             pt: 'Sugerir ferramenta',                              ar: 'اقتراح أداة' },
      suggest_tool_desc:  { fr: 'Un outil vous manque ? Décrivez-le et nous le développerons si la demande est forte.',
                            en: 'Missing a tool? Describe it and we\'ll build it if there\'s enough demand.',
                            es: '¿Falta una herramienta? Descríbala y la crearemos si hay demanda.',
                            pt: 'Faltando uma ferramenta? Descreva-a e criaremos se houver demanda.',
                            ar: 'أداة مفقودة؟ صفها وسنبنيها إذا كان هناك طلب كاف.' },
      suggest_idea:       { fr: 'Proposer une idée', en: 'Submit an idea',    es: 'Enviar idea',        pt: 'Enviar ideia',       ar: 'إرسال فكرة' },
      // Complete profile
      complete_profile:   { fr: 'Complétez votre profil pour une meilleure expérience.',
                            en: 'Complete your profile for a better experience.',
                            es: 'Complete su perfil para una mejor experiencia.',
                            pt: 'Complete seu perfil para uma melhor experiência.',
                            ar: 'أكمل ملفك الشخصي لتجربة أفضل.' },
      complete_btn:       { fr: 'Compléter',         en: 'Complete',          es: 'Completar',          pt: 'Completar',          ar: 'إكمال' },
      // Announce bar
      announce:           { fr: 'Bientôt disponible — L\'app mobile The Prompt Studio : vos outils IA pro, partout, tout le temps.',
                            en: 'Coming soon — The Prompt Studio mobile app: your pro AI tools, anywhere, anytime.',
                            es: 'Próximamente — La app móvil The Prompt Studio: tus herramientas IA pro, en cualquier lugar.',
                            pt: 'Em breve — O app móvel The Prompt Studio: suas ferramentas IA pro, em qualquer lugar.',
                            ar: 'قريبًا — تطبيق The Prompt Studio للجوال: أدوات الذكاء الاصطناعي المهنية في كل مكان.' },
      // Projects
      projects_title:     { fr: 'Mes projets',                                   en: 'My projects',                                     es: 'Mis proyectos',                                   pt: 'Meus projetos',                                   ar: 'مشاريعي' },
      projects_sub:       { fr: 'Gérez vos dossiers et utilisez les outils IA en contexte',
                            en: 'Manage your files and use AI tools in context',
                            es: 'Gestione sus archivos y use herramientas IA en contexto',
                            pt: 'Gerencie seus arquivos e use ferramentas IA em contexto',
                            ar: 'أدر ملفاتك واستخدم أدوات الذكاء الاصطناعي في السياق' },
      crm_title:          { fr: 'CRM & Gestion de projets',                      en: 'CRM & Project Management',                        es: 'CRM y Gestión de proyectos',                      pt: 'CRM e Gestão de projetos',                        ar: 'CRM وإدارة المشاريع' },
      crm_locked:         { fr: 'Le CRM intégré est disponible à partir de l\'offre <strong style="color:#c9a84c">Gold</strong>.<br>Créez des projets, centralisez vos dossiers et utilisez les outils IA en contexte.',
                            en: 'The built-in CRM is available starting from the <strong style="color:#c9a84c">Gold</strong> plan.<br>Create projects, centralize your files, and use AI tools in context.',
                            es: 'El CRM integrado está disponible desde el plan <strong style="color:#c9a84c">Gold</strong>.<br>Cree proyectos, centralice archivos y use herramientas IA.',
                            pt: 'O CRM integrado está disponível a partir do plano <strong style="color:#c9a84c">Gold</strong>.<br>Crie projetos, centralize arquivos e use ferramentas IA.',
                            ar: 'نظام CRM المدمج متاح من خطة <strong style="color:#c9a84c">Gold</strong>.<br>أنشئ مشاريع وادر ملفاتك.' },
      upgrade_gold:       { fr: 'Passer à Gold',    en: 'Upgrade to Gold',   es: 'Mejorar a Gold',     pt: 'Upgrade para Gold',  ar: 'الترقية إلى Gold' },
      new_project:        { fr: 'Nouveau projet',   en: 'New project',       es: 'Nuevo proyecto',     pt: 'Novo projeto',       ar: 'مشروع جديد' },
      all_verticals:      { fr: 'Toutes les verticales',                         en: 'All verticals',                                   es: 'Todas las verticales',                            pt: 'Todas as verticais',                              ar: 'جميع القطاعات' },
      active:             { fr: 'En cours',          en: 'Active',            es: 'Activos',            pt: 'Ativos',             ar: 'نشطة' },
      completed:          { fr: 'Terminés',          en: 'Completed',         es: 'Completados',        pt: 'Concluídos',         ar: 'مكتملة' },
      archived:           { fr: 'Archivés',          en: 'Archived',          es: 'Archivados',         pt: 'Arquivados',         ar: 'مؤرشفة' },
      all:                { fr: 'Tous',              en: 'All',               es: 'Todos',              pt: 'Todos',              ar: 'الكل' },
      no_info:            { fr: 'Aucune info renseignée',                        en: 'No info provided',                                es: 'Sin información',                                 pt: 'Sem informação',                                  ar: 'لا معلومات' },
      project_name_ph:    { fr: 'Nom du projet (ex: Appartement T3 Paris 11)',   en: 'Project name (e.g. Apartment 3BR Paris 11th)',    es: 'Nombre del proyecto',                             pt: 'Nome do projeto',                                 ar: 'اسم المشروع' },
      err_project_name:   { fr: 'Veuillez saisir un nom de projet.',             en: 'Please enter a project name.',                    es: 'Ingrese un nombre de proyecto.',                  pt: 'Insira um nome de projeto.',                      ar: 'الرجاء إدخال اسم المشروع.' },
      err_project_vert:   { fr: 'Veuillez sélectionner une verticale.',          en: 'Please select a vertical.',                       es: 'Seleccione una vertical.',                        pt: 'Selecione um vertical.',                          ar: 'الرجاء اختيار قطاع.' },
      err_project_create: { fr: 'Erreur lors de la création du projet.',         en: 'Error creating project.',                         es: 'Error al crear proyecto.',                        pt: 'Erro ao criar projeto.',                          ar: 'خطأ في إنشاء المشروع.' },
      // Welcome
      welcome_to:         { fr: 'Bienvenue sur',    en: 'Welcome to',        es: 'Bienvenido a',       pt: 'Bem-vindo ao',       ar: 'مرحبًا في' },
      welcome_trial:      { fr: 'Votre offre <strong>{tier}</strong> est active avec un <strong>essai gratuit de 7 jours</strong>. Aucun prélèvement avant la fin de l\'essai.',
                            en: 'Your <strong>{tier}</strong> plan is active with a <strong>7-day free trial</strong>. You won\'t be charged until the trial ends.',
                            es: 'Su plan <strong>{tier}</strong> está activo con <strong>7 días de prueba gratis</strong>. No se le cobrará hasta que termine.',
                            pt: 'Seu plano <strong>{tier}</strong> está ativo com <strong>7 dias de teste grátis</strong>. Sem cobrança até o fim do teste.',
                            ar: 'خطتك <strong>{tier}</strong> نشطة مع <strong>تجربة مجانية 7 أيام</strong>. لن يتم الخصم حتى انتهاء التجربة.' },
      welcome_active:     { fr: 'Votre offre <strong>{tier}</strong> est active. Tous vos outils IA sont prêts.',
                            en: 'Your <strong>{tier}</strong> plan is now active. All your AI tools are ready to use.',
                            es: 'Su plan <strong>{tier}</strong> está activo. Todas sus herramientas IA están listas.',
                            pt: 'Seu plano <strong>{tier}</strong> está ativo. Todas as ferramentas IA estão prontas.',
                            ar: 'خطتك <strong>{tier}</strong> نشطة الآن. جميع أدوات الذكاء الاصطناعي جاهزة.' },
      welcome_first:      { fr: 'Votre espace est prêt. Explorez vos outils IA ci-dessous.',
                            en: 'Your workspace is set up and ready. Explore your AI tools below.',
                            es: 'Su espacio está listo. Explore sus herramientas IA.',
                            pt: 'Seu espaço está pronto. Explore suas ferramentas IA.',
                            ar: 'مساحتك جاهزة. استكشف أدوات الذكاء الاصطناعي.' },
      welcome_trial_badge:{ fr: 'Essai gratuit · {d} jours restants',            en: 'Free trial · {d} days remaining',                 es: 'Prueba gratis · {d} días',                        pt: 'Teste grátis · {d} dias',                         ar: 'تجربة مجانية · {d} أيام' },
      welcome_cta:        { fr: 'C\'est parti',     en: 'Get started',       es: 'Empezar',            pt: 'Começar',            ar: 'ابدأ الآن' },
      loading_tools:      { fr: 'Outils en cours de chargement…',                en: 'Loading tools…',                                  es: 'Cargando herramientas…',                          pt: 'Carregando ferramentas…',                         ar: 'جار تحميل الأدوات…' },
    },

    /* ── Tarifs / Pricing ───────────────────────────────────────────────── */
    tarifs: {
      meta_desc:        { fr: 'Choisissez votre verticale et votre offre. Accès instantané aux outils IA conçus pour votre métier.',
                          en: 'Choose your vertical and plan. Instant access to AI tools built for your industry.',
                          es: 'Elige tu vertical y tu plan. Acceso instantáneo a herramientas IA para tu sector.',
                          pt: 'Escolha seu vertical e plano. Acesso instantâneo a ferramentas IA para seu setor.',
                          ar: 'اختر قطاعك وخطتك. وصول فوري لأدوات الذكاء الاصطناعي.' },
      free_trial_7d:    { fr: 'Essai gratuit 7j',   en: 'Free 7-day trial',  es: 'Prueba gratis 7d',   pt: 'Teste grátis 7d',    ar: 'تجربة 7 أيام' },
      contact_team:     { fr: 'Contacter l\'équipe', en: 'Contact us',        es: 'Contactar',          pt: 'Fale conosco',       ar: 'تواصل معنا' },
      trial_note:       { fr: '7 jours d\'essai gratuit · annulation possible à tout moment',
                          en: '7-day free trial · cancel anytime',
                          es: '7 días de prueba gratis · cancela cuando quieras',
                          pt: '7 dias de teste grátis · cancele a qualquer momento',
                          ar: '7 أيام تجربة مجانية · إلغاء في أي وقت' },
      save_yearly:      { fr: '€/an — économie {s}€',                           en: '€/yr — save {s}€',                                es: '€/año — ahorro {s}€',                             pt: '€/ano — economia {s}€',                           ar: '€/سنة — وفر {s}€' },
      yearly_equiv:     { fr: 'soit {a}€/an en annuel',                         en: '{a}€/yr if billed annually',                      es: '{a}€/año en anual',                               pt: '{a}€/ano se anual',                               ar: '{a}€/سنة إذا سنوي' },
    },

    /* ── Plans descriptions (per tier) ──────────────────────────────────── */
    plans: {
      starter: {
        desc:     { fr: "Découvrez l'IA métier avec les outils essentiels.",         en: "Discover AI-powered tools for your industry essentials.",   es: "Descubra las herramientas IA esenciales para su sector.",  pt: "Descubra ferramentas IA essenciais para seu setor.",  ar: "اكتشف أدوات الذكاء الاصطناعي الأساسية لقطاعك." },
        features: {
          f1: { fr: '3 outils essentiels',       en: '3 essential tools',          es: '3 herramientas esenciales',     pt: '3 ferramentas essenciais',     ar: '3 أدوات أساسية' },
          f2: { fr: '50 générations / mois',      en: '50 generations / month',     es: '50 generaciones / mes',         pt: '50 gerações / mês',            ar: '50 عملية / شهر' },
          f3: { fr: 'Historique 7 jours',          en: '7-day history',              es: 'Historial 7 días',              pt: 'Histórico 7 dias',             ar: 'سجل 7 أيام' },
          f4: { fr: 'Export : copie',              en: 'Export: copy',               es: 'Exportar: copiar',              pt: 'Exportar: copiar',             ar: 'تصدير: نسخ' },
          f5: { fr: 'Support email',               en: 'Email support',              es: 'Soporte por email',             pt: 'Suporte por email',            ar: 'دعم بالبريد' },
          f6: { fr: '⚠️ Avec publicités',          en: '⚠️ Includes ads',            es: '⚠️ Con anuncios',               pt: '⚠️ Com anúncios',              ar: '⚠️ مع إعلانات' },
        },
        locked: {
          l1: { fr: 'Sans publicité (Pro+)',                     en: 'Ad-free (Pro+)',                        es: 'Sin anuncios (Pro+)',                    pt: 'Sem anúncios (Pro+)',                    ar: 'بدون إعلانات (Pro+)' },
          l2: { fr: 'Chatbot IA générique (Pro)',                en: 'Generic AI chatbot (Pro)',              es: 'Chatbot IA genérico (Pro)',              pt: 'Chatbot IA genérico (Pro)',              ar: 'شات بوت IA عام (Pro)' },
          l3: { fr: 'Chatbot IA spécialiste métier (Pro)',       en: 'Industry-specialist AI chatbot (Pro)',  es: 'Chatbot IA especialista (Pro)',          pt: 'Chatbot IA especialista (Pro)',          ar: 'شات بوت IA متخصص (Pro)' },
          l4: { fr: 'Outils avancés (Pro)',                      en: 'Advanced tools (Pro)',                  es: 'Herramientas avanzadas (Pro)',           pt: 'Ferramentas avançadas (Pro)',            ar: 'أدوات متقدمة (Pro)' },
          l5: { fr: 'CRM & Gestion de projets (Gold)',           en: 'CRM & Project management (Gold)',       es: 'CRM y Gestión de proyectos (Gold)',     pt: 'CRM e Gestão de projetos (Gold)',       ar: 'CRM وإدارة المشاريع (Gold)' },
          l6: { fr: 'Outils premium (Gold)',                     en: 'Premium tools (Gold)',                  es: 'Herramientas premium (Gold)',            pt: 'Ferramentas premium (Gold)',            ar: 'أدوات متميزة (Gold)' },
        },
      },
      pro: {
        desc:     { fr: "Les outils avancés + les chatbots IA, sans aucune publicité.",  en: "Advanced tools + AI chatbots, completely ad-free.",  es: "Herramientas avanzadas + chatbots IA, sin anuncios.",  pt: "Ferramentas avançadas + chatbots IA, sem anúncios.",  ar: "أدوات متقدمة + شات بوت IA، بدون إعلانات." },
        features: {
          f1: { fr: '✨ Sans publicité',                          en: '✨ Ad-free',                             es: '✨ Sin anuncios',                        pt: '✨ Sem anúncios',                        ar: '✨ بدون إعلانات' },
          f2: { fr: '7 outils (essentiels + avancés)',            en: '7 tools (essential + advanced)',         es: '7 herramientas (esenciales + avanzadas)', pt: '7 ferramentas (essenciais + avançadas)', ar: '7 أدوات (أساسية + متقدمة)' },
          f3: { fr: '150 générations / mois',                     en: '150 generations / month',                es: '150 generaciones / mes',                pt: '150 gerações / mês',                    ar: '150 عملية / شهر' },
          f4: { fr: '💬 Chatbot IA générique',                    en: '💬 Generic AI chatbot',                  es: '💬 Chatbot IA genérico',                pt: '💬 Chatbot IA genérico',                ar: '💬 شات بوت IA عام' },
          f5: { fr: '💬 Chatbot IA spécialiste métier',           en: '💬 Industry-specialist AI chatbot',      es: '💬 Chatbot IA especialista',            pt: '💬 Chatbot IA especialista',            ar: '💬 شات بوت IA متخصص' },
          f6: { fr: 'Historique 30 jours',                        en: '30-day history',                         es: 'Historial 30 días',                     pt: 'Histórico 30 dias',                     ar: 'سجل 30 يوم' },
          f7: { fr: 'Export copie + PDF',                         en: 'Export copy + PDF',                      es: 'Exportar copia + PDF',                  pt: 'Exportar cópia + PDF',                  ar: 'تصدير نسخة + PDF' },
          f8: { fr: 'Support prioritaire',                        en: 'Priority support',                       es: 'Soporte prioritario',                   pt: 'Suporte prioritário',                   ar: 'دعم مميز' },
        },
        locked: {
          l1: { fr: 'CRM & Gestion de projets (Gold)',           en: 'CRM & Project management (Gold)',       es: 'CRM y Gestión de proyectos (Gold)',     pt: 'CRM e Gestão de projetos (Gold)',       ar: 'CRM وإدارة المشاريع (Gold)' },
          l2: { fr: 'Outils premium (Gold)',                     en: 'Premium tools (Gold)',                  es: 'Herramientas premium (Gold)',           pt: 'Ferramentas premium (Gold)',            ar: 'أدوات متميزة (Gold)' },
          l3: { fr: 'Tons personnalisés',                        en: 'Custom tones',                          es: 'Tonos personalizados',                  pt: 'Tons personalizados',                   ar: 'نغمات مخصصة' },
          l4: { fr: 'Export DOCX',                               en: 'DOCX export',                            es: 'Exportar DOCX',                         pt: 'Exportar DOCX',                         ar: 'تصدير DOCX' },
        },
      },
      gold: {
        desc:     { fr: "Accès complet : CRM, outils premium, sans limite.",  en: "Full access: CRM, premium tools, unlimited.",  es: "Acceso completo: CRM, herramientas premium, sin límite.",  pt: "Acesso completo: CRM, ferramentas premium, ilimitado.",  ar: "وصول كامل: CRM، أدوات متميزة، بلا حدود." },
        features: {
          f1: { fr: '✨ Sans publicité',                en: '✨ Ad-free',                    es: '✨ Sin anuncios',              pt: '✨ Sem anúncios',              ar: '✨ بدون إعلانات' },
          f2: { fr: '10 outils complets',               en: '10 complete tools',             es: '10 herramientas completas',   pt: '10 ferramentas completas',    ar: '10 أدوات كاملة' },
          f3: { fr: 'Générations illimitées',            en: 'Unlimited generations',         es: 'Generaciones ilimitadas',     pt: 'Gerações ilimitadas',         ar: 'عمليات غير محدودة' },
          f4: { fr: '📁 CRM & Gestion de projets',      en: '📁 CRM & Project management',   es: '📁 CRM y Gestión de proyectos', pt: '📁 CRM e Gestão de projetos', ar: '📁 CRM وإدارة المشاريع' },
          f5: { fr: '💬 Chatbots IA (générique + spécialiste)', en: '💬 AI chatbots (generic + specialist)', es: '💬 Chatbots IA (genérico + especialista)', pt: '💬 Chatbots IA (genérico + especialista)', ar: '💬 شات بوت IA (عام + متخصص)' },
          f6: { fr: 'Historique 90 jours',               en: '90-day history',                es: 'Historial 90 días',           pt: 'Histórico 90 dias',           ar: 'سجل 90 يوم' },
          f7: { fr: 'Tous les exports (PDF, DOCX…)',     en: 'All exports (PDF, DOCX…)',      es: 'Todos los exportes (PDF, DOCX…)', pt: 'Todas exportações (PDF, DOCX…)', ar: 'جميع التصديرات (PDF, DOCX…)' },
          f8: { fr: 'Tons personnalisés',                en: 'Custom tones',                  es: 'Tonos personalizados',        pt: 'Tons personalizados',         ar: 'نغمات مخصصة' },
          f9: { fr: 'Support prioritaire + chat',        en: 'Priority support + chat',       es: 'Soporte prioritario + chat',  pt: 'Suporte prioritário + chat',  ar: 'دعم مميز + محادثة' },
          f10:{ fr: 'Nouveaux outils en avant-première', en: 'Early access to new tools',     es: 'Acceso anticipado a nuevos',  pt: 'Acesso antecipado a novos',   ar: 'وصول مبكر للأدوات الجديدة' },
        },
        locked: {},
      },
      team: {
        desc:     { fr: "Collaborez en équipe avec intégrations & automatisations.",  en: "Collaborate as a team with integrations & automations.",  es: "Colabore en equipo con integraciones y automatizaciones.",  pt: "Colabore em equipe com integrações e automações.",  ar: "تعاون كفريق مع التكامل والأتمتة." },
        features: {
          f1: { fr: '✨ Sans publicité',                           en: '✨ Ad-free',                              es: '✨ Sin anuncios',                         pt: '✨ Sem anúncios',                        ar: '✨ بدون إعلانات' },
          f2: { fr: 'Jusqu\'à 3 verticales',                      en: 'Up to 3 verticals',                      es: 'Hasta 3 verticales',                     pt: 'Até 3 verticais',                        ar: 'حتى 3 قطاعات' },
          f3: { fr: '10 outils / verticale',                      en: '10 tools / vertical',                    es: '10 herramientas / vertical',             pt: '10 ferramentas / vertical',              ar: '10 أدوات / قطاع' },
          f4: { fr: 'Générations illimitées',                      en: 'Unlimited generations',                  es: 'Generaciones ilimitadas',                pt: 'Gerações ilimitadas',                    ar: 'عمليات غير محدودة' },
          f5: { fr: '📁 CRM & Gestion de projets',                en: '📁 CRM & Project management',            es: '📁 CRM y Gestión de proyectos',          pt: '📁 CRM e Gestão de projetos',            ar: '📁 CRM وإدارة المشاريع' },
          f6: { fr: '💬 Chatbots IA',                              en: '💬 AI chatbots',                          es: '💬 Chatbots IA',                         pt: '💬 Chatbots IA',                         ar: '💬 شات بوت IA' },
          f7: { fr: '🔗 Intégrations API (CRM, email, outils métier)', en: '🔗 API integrations (CRM, email, business tools)', es: '🔗 Integraciones API (CRM, email)', pt: '🔗 Integrações API (CRM, email)',  ar: '🔗 تكامل API (CRM, بريد)' },
          f8: { fr: '⚡ Automatisations & workflows',              en: '⚡ Automations & workflows',              es: '⚡ Automatizaciones y workflows',         pt: '⚡ Automações e workflows',               ar: '⚡ أتمتة وسير عمل' },
          f9: { fr: 'Espace partagé & analytics',                  en: 'Shared workspace & analytics',           es: 'Espacio compartido y analytics',         pt: 'Espaço compartilhado e analytics',       ar: 'مساحة مشتركة وتحليلات' },
          f10:{ fr: 'Historique illimité',                          en: 'Unlimited history',                      es: 'Historial ilimitado',                    pt: 'Histórico ilimitado',                    ar: 'سجل غير محدود' },
          f11:{ fr: 'Support dédié',                               en: 'Dedicated support',                      es: 'Soporte dedicado',                      pt: 'Suporte dedicado',                       ar: 'دعم مخصص' },
        },
        locked: {},
      },
    },

    /* ── Contact page ─────────────────────────────────────────────────── */
    contact: {
      eyebrow:        { fr: 'Contact',                       en: 'Contact',                        es: 'Contacto',                       pt: 'Contato',                        ar: 'تواصل' },
      h1_line1:       { fr: 'Parlons de',                    en: "Let's discuss",                  es: 'Hablemos de',                    pt: 'Vamos falar do',                 ar: 'لنناقش' },
      h1_line2:       { fr: 'votre projet.',                 en: 'your project.',                  es: 'su proyecto.',                    pt: 'seu projeto.',                   ar: 'مشروعك.' },
      intro:          { fr: "Besoin d'un renseignement sur nos toolkits IA, d'un accompagnement sur-mesure ou d'aide pour choisir votre offre ? Remplissez le formulaire ou écrivez-nous directement.",
                        en: 'Need information about our AI toolkits, custom consulting, or help choosing the right plan? Fill out the form or reach out directly.',
                        es: '¿Necesita información sobre nuestros toolkits IA, consultoría personalizada o ayuda para elegir su plan? Complete el formulario o escríbanos.',
                        pt: 'Precisa de informações sobre nossos toolkits IA, consultoria personalizada ou ajuda para escolher seu plano? Preencha o formulário ou entre em contato.',
                        ar: 'تحتاج معلومات عن أدوات الذكاء الاصطناعي، استشارة مخصصة، أو مساعدة في اختيار خطتك؟ املأ النموذج أو تواصل معنا مباشرة.' },
      email_desc:     { fr: 'Réponse sous 24h en semaine',   en: 'Response within 24h on weekdays', es: 'Respuesta en 24h en días hábiles', pt: 'Resposta em 24h em dias úteis',  ar: 'رد خلال 24 ساعة في أيام العمل' },
      subscribe_label:{ fr: 'Abonnement',                    en: 'Subscribe',                      es: 'Suscripción',                    pt: 'Assinatura',                     ar: 'اشتراك' },
      subscribe_value:{ fr: 'Choisir votre offre',           en: 'Choose your plan',               es: 'Elegir su plan',                 pt: 'Escolha seu plano',              ar: 'اختر خطتك' },
      subscribe_desc: { fr: 'Starter, Pro, Gold ou Team — essai gratuit 7 jours', en: 'Starter, Pro, Gold or Team — 7-day free trial', es: 'Starter, Pro, Gold o Team — prueba gratis 7 días', pt: 'Starter, Pro, Gold ou Team — teste grátis 7 dias', ar: 'Starter, Pro, Gold أو Team — تجربة مجانية 7 أيام' },
      help_title:     { fr: 'On peut vous aider avec',       en: 'We can help you with',           es: 'Podemos ayudarle con',           pt: 'Podemos ajudá-lo com',           ar: 'يمكننا مساعدتك في' },
      tag_toolkit:    { fr: 'Toolkit IA métier',             en: 'Industry AI toolkit',            es: 'Toolkit IA sectorial',           pt: 'Toolkit IA setorial',            ar: 'أدوات IA للقطاع' },
      tag_consulting: { fr: 'Conseil sur mesure',            en: 'Custom AI consulting',           es: 'Consultoría IA a medida',        pt: 'Consultoria IA personalizada',   ar: 'استشارة IA مخصصة' },
      tag_team:       { fr: 'Offre Team & API',              en: 'Team plan & API',                es: 'Plan Team y API',                pt: 'Plano Team e API',               ar: 'خطة Team و API' },
      tag_onboarding: { fr: 'Onboarding & formation',        en: 'Onboarding & training',          es: 'Onboarding y formación',         pt: 'Onboarding e treinamento',       ar: 'تهيئة وتدريب' },
      tag_integration:{ fr: 'Intégrations métier',           en: 'Business integrations',          es: 'Integraciones empresariales',    pt: 'Integrações empresariais',       ar: 'تكامل الأعمال' },
      tag_vertical:   { fr: 'Outils IA par secteur',        en: 'AI tools by industry',           es: 'Herramientas IA por sector',     pt: 'Ferramentas IA por setor',       ar: 'أدوات IA حسب القطاع' },
      // Form
      form_title:     { fr: 'Envoyez-nous un message',      en: 'Send us a message',              es: 'Envíenos un mensaje',            pt: 'Envie-nos uma mensagem',         ar: 'أرسل لنا رسالة' },
      form_sub:       { fr: 'Réponse sous 24h · Sans engagement', en: 'Response within 24h · No commitment', es: 'Respuesta en 24h · Sin compromiso', pt: 'Resposta em 24h · Sem compromisso', ar: 'رد خلال 24 ساعة · بدون التزام' },
      label_fname:    { fr: 'Prénom',                        en: 'First name',                     es: 'Nombre',                         pt: 'Nome',                           ar: 'الاسم الأول' },
      label_lname:    { fr: 'Nom',                           en: 'Last name',                      es: 'Apellido',                       pt: 'Sobrenome',                      ar: 'اسم العائلة' },
      label_email:    { fr: 'Email professionnel',           en: 'Professional email',             es: 'Email profesional',              pt: 'Email profissional',             ar: 'البريد المهني' },
      label_company:  { fr: 'Entreprise',                    en: 'Company',                        es: 'Empresa',                        pt: 'Empresa',                        ar: 'الشركة' },
      label_subject:  { fr: 'Sujet',                         en: 'Subject',                        es: 'Asunto',                         pt: 'Assunto',                        ar: 'الموضوع' },
      label_message:  { fr: 'Message',                       en: 'Message',                        es: 'Mensaje',                        pt: 'Mensagem',                       ar: 'الرسالة' },
      ph_fname:       { fr: 'Jean',                          en: 'John',                           es: 'Juan',                           pt: 'João',                           ar: 'أحمد' },
      ph_lname:       { fr: 'Dupont',                        en: 'Smith',                          es: 'García',                         pt: 'Silva',                          ar: 'محمد' },
      ph_email:       { fr: 'jean.dupont@entreprise.com',    en: 'john.smith@company.com',         es: 'juan.garcia@empresa.com',        pt: 'joao.silva@empresa.com',         ar: 'ahmed@company.com' },
      ph_company:     { fr: 'Votre entreprise',              en: 'Your company',                   es: 'Su empresa',                     pt: 'Sua empresa',                    ar: 'شركتك' },
      ph_message:     { fr: 'Décrivez votre besoin…',        en: 'Describe your needs…',           es: 'Describa su necesidad…',         pt: 'Descreva sua necessidade…',      ar: 'صف احتياجاتك…' },
      subject_default:{ fr: 'Choisissez un sujet',           en: 'Choose a subject',               es: 'Elija un tema',                  pt: 'Escolha um assunto',             ar: 'اختر موضوعًا' },
      subj_toolkit:   { fr: 'Abonnement AI Toolkit',         en: 'AI Toolkit subscription',        es: 'Suscripción AI Toolkit',         pt: 'Assinatura AI Toolkit',          ar: 'اشتراك AI Toolkit' },
      subj_consulting:{ fr: 'Conseil sur mesure',            en: 'Custom consulting',              es: 'Consultoría personalizada',      pt: 'Consultoria personalizada',      ar: 'استشارة مخصصة' },
      subj_team:      { fr: 'Offre Team / Entreprise',       en: 'Team / Enterprise plan',         es: 'Plan Team / Empresa',            pt: 'Plano Team / Empresa',           ar: 'خطة Team / المؤسسات' },
      subj_demo:      { fr: 'Demande de démo',               en: 'Request a demo',                 es: 'Solicitar demo',                 pt: 'Solicitar demo',                 ar: 'طلب عرض تجريبي' },
      subj_integration:{ fr: 'Intégration API / technique',  en: 'API / technical integration',    es: 'Integración API / técnica',      pt: 'Integração API / técnica',       ar: 'تكامل API / تقني' },
      subj_other:     { fr: 'Autre',                         en: 'Other',                          es: 'Otro',                           pt: 'Outro',                          ar: 'آخر' },
      btn_submit:     { fr: 'Envoyer le message →',          en: 'Send message →',                 es: 'Enviar mensaje →',               pt: 'Enviar mensagem →',              ar: 'إرسال الرسالة →' },
      form_note:      { fr: "En envoyant ce formulaire, vous acceptez d'être contacté par The Prompt Studio. Aucun spam, désabonnement en 1 clic.",
                        en: 'By submitting this form, you agree to be contacted by The Prompt Studio. No spam, unsubscribe in 1 click.',
                        es: 'Al enviar este formulario, acepta ser contactado por The Prompt Studio. Sin spam, cancelación en 1 clic.',
                        pt: 'Ao enviar este formulário, você aceita ser contatado pela The Prompt Studio. Sem spam, cancelamento em 1 clique.',
                        ar: 'بإرسال هذا النموذج، توافق على التواصل من The Prompt Studio. بدون بريد مزعج.' },
      success_title:  { fr: 'Message envoyé',                en: 'Message sent',                   es: 'Mensaje enviado',                pt: 'Mensagem enviada',               ar: 'تم إرسال الرسالة' },
      success_desc:   { fr: 'Nous vous répondons sous 24h. À très vite !', en: 'We\'ll get back to you within 24h. Talk soon!', es: 'Le respondemos en 24h. ¡Hasta pronto!', pt: 'Respondemos em 24h. Até breve!', ar: 'سنرد عليك خلال 24 ساعة.' },
      // Footer
      foot_desc:      { fr: 'Toolkits IA premium pour professionnels.', en: 'Premium AI toolkits for professionals.', es: 'Toolkits IA premium para profesionales.', pt: 'Toolkits IA premium para profissionais.', ar: 'أدوات IA متميزة للمحترفين.' },
      foot_products:  { fr: 'Produits',                      en: 'Products',                       es: 'Productos',                      pt: 'Produtos',                       ar: 'المنتجات' },
      foot_legal:     { fr: 'Informations légales',          en: 'Legal',                          es: 'Información legal',              pt: 'Informações legais',             ar: 'معلومات قانونية' },
      foot_mentions:  { fr: 'Mentions légales',              en: 'Legal notice',                   es: 'Aviso legal',                    pt: 'Aviso legal',                    ar: 'إشعار قانوني' },
      foot_terms:     { fr: 'CGV',                           en: 'Terms of service',               es: 'Condiciones',                    pt: 'Termos',                         ar: 'شروط الخدمة' },
      foot_privacy:   { fr: 'Politique de confidentialité',  en: 'Privacy policy',                 es: 'Política de privacidad',         pt: 'Política de privacidade',        ar: 'سياسة الخصوصية' },
      foot_shop:      { fr: 'Boutique Lemon Squeezy',        en: 'Lemon Squeezy store',            es: 'Tienda Lemon Squeezy',           pt: 'Loja Lemon Squeezy',             ar: 'متجر Lemon Squeezy' },
      foot_copyright: { fr: '© 2026 The Prompt Studio — theprompt.studio — Tous droits réservés', en: '© 2026 The Prompt Studio — theprompt.studio — All rights reserved', es: '© 2026 The Prompt Studio — theprompt.studio — Todos los derechos reservados', pt: '© 2026 The Prompt Studio — theprompt.studio — Todos os direitos reservados', ar: '© 2026 The Prompt Studio — theprompt.studio — جميع الحقوق محفوظة' },
      foot_payments:  { fr: 'Paiements sécurisés via',       en: 'Secure payments via',            es: 'Pagos seguros vía',              pt: 'Pagamentos seguros via',         ar: 'مدفوعات آمنة عبر' },
      foot_vat:       { fr: 'TVA gérée dans 130+ pays',      en: 'VAT handled in 130+ countries',  es: 'IVA gestionado en 130+ países',  pt: 'IVA gerido em 130+ países',      ar: 'ضريبة القيمة المضافة في 130+ دولة' },
      // Cookie banner
      cookie_text:    { fr: "Nous utilisons des cookies techniques nécessaires au fonctionnement du site (Google Fonts, analyse de trafic anonymisée). En cliquant sur \"Accepter\", vous consentez à leur utilisation.",
                        en: 'We use technical cookies necessary for the site to function (Google Fonts, anonymous traffic analysis). By clicking "Accept", you consent to their use.',
                        es: 'Usamos cookies técnicas necesarias para el funcionamiento del sitio. Al hacer clic en "Aceptar", consiente su uso.',
                        pt: 'Usamos cookies técnicos necessários para o funcionamento do site. Ao clicar em "Aceitar", consente o uso.',
                        ar: 'نستخدم ملفات تعريف ارتباط تقنية ضرورية لعمل الموقع. بالنقر على "قبول"، توافق على استخدامها.' },
      cookie_accept:  { fr: 'Accepter',                      en: 'Accept',                         es: 'Aceptar',                        pt: 'Aceitar',                        ar: 'قبول' },
      cookie_refuse:  { fr: 'Continuer sans accepter',       en: 'Continue without accepting',     es: 'Continuar sin aceptar',          pt: 'Continuar sem aceitar',          ar: 'المتابعة بدون قبول' },
    },

    /* ── Nav shared (used across pages) ────────────────────────────────── */
    nav_page: {
      ai_tools:       { fr: 'Outils IA',                    en: 'AI Tools',                       es: 'Herramientas IA',                pt: 'Ferramentas IA',                 ar: 'أدوات IA' },
      consulting:     { fr: 'Conseil sur mesure',            en: 'Custom consulting',              es: 'Consultoría a medida',           pt: 'Consultoria personalizada',      ar: 'استشارة مخصصة' },
      contact:        { fr: 'Contact',                       en: 'Contact',                        es: 'Contacto',                       pt: 'Contato',                        ar: 'تواصل' },
      my_account:     { fr: 'Mon compte',                    en: 'My account',                     es: 'Mi cuenta',                      pt: 'Minha conta',                    ar: 'حسابي' },
      view_plans:     { fr: 'Voir les offres',               en: 'View plans',                     es: 'Ver ofertas',                    pt: 'Ver ofertas',                    ar: 'عرض الخطط' },
      // Vertical names
      v_immo:         { fr: 'Immobilier',                    en: 'Real Estate',                    es: 'Inmobiliaria',                   pt: 'Imobiliário',                    ar: 'عقارات' },
      v_commerce:     { fr: 'E-Commerce & Retail',           en: 'E-Commerce & Retail',            es: 'E-Commerce & Retail',            pt: 'E-Commerce & Varejo',            ar: 'تجارة إلكترونية' },
      v_legal:        { fr: 'Juridique',                     en: 'Legal',                          es: 'Legal',                          pt: 'Jurídico',                       ar: 'قانوني' },
      v_finance:      { fr: 'Finance & Comptabilité',        en: 'Finance & Accounting',           es: 'Finanzas y Contabilidad',        pt: 'Finanças e Contabilidade',       ar: 'مالية ومحاسبة' },
      v_marketing:    { fr: 'Marketing & Com.',              en: 'Marketing & Comms',              es: 'Marketing y Com.',               pt: 'Marketing e Com.',               ar: 'تسويق واتصالات' },
      v_rh:           { fr: 'Ressources Humaines',           en: 'Human Resources',                es: 'Recursos Humanos',              pt: 'Recursos Humanos',               ar: 'موارد بشرية' },
      v_sante:        { fr: 'Santé & Bien-être',             en: 'Health & Wellness',              es: 'Salud y Bienestar',              pt: 'Saúde e Bem-estar',              ar: 'صحة ورفاهية' },
      v_education:    { fr: 'Éducation & Formation',         en: 'Education & Training',           es: 'Educación y Formación',          pt: 'Educação e Formação',            ar: 'تعليم وتدريب' },
      v_restauration: { fr: 'Restauration',                  en: 'Food & Hospitality',             es: 'Restauración',                   pt: 'Restauração',                    ar: 'مطاعم وضيافة' },
      v_freelance:    { fr: 'Freelances & Consultants',      en: 'Freelancers & Consultants',      es: 'Freelancers y Consultores',      pt: 'Freelancers e Consultores',      ar: 'مستقلون واستشاريون' },
    },

    /* ── Custom consulting page ────────────────────────────────────────── */
    consulting: {
      label:          { fr: 'The Prompt Studio — Conseil sur mesure', en: 'The Prompt Studio — Custom Consulting', es: 'The Prompt Studio — Consultoría a medida', pt: 'The Prompt Studio — Consultoria personalizada', ar: 'The Prompt Studio — استشارة مخصصة' },
      h1_1:           { fr: 'Votre projet IA.',    en: 'Your AI project.',       es: 'Su proyecto IA.',        pt: 'Seu projeto IA.',        ar: 'مشروعك في الذكاء الاصطناعي.' },
      h1_2:           { fr: 'Réalisé.',             en: 'Delivered.',             es: 'Realizado.',             pt: 'Realizado.',             ar: 'منجز.' },
      hero_p:         { fr: "Vous avez un projet, un besoin métier, une idée d'automatisation. Peu importe votre secteur — immobilier, commerce, RH, logistique, santé, juridique — nous concevons et déployons les outils IA qui correspondent exactement à votre contexte.",
                        en: "You have a project, a business need, an automation idea. Whatever your industry — real estate, retail, HR, logistics, healthcare, legal — we design and deploy AI tools that match your exact context.",
                        es: "Tiene un proyecto, una necesidad empresarial, una idea de automatización. Sea cual sea su sector — inmobiliaria, comercio, RRHH, logística, salud, legal — diseñamos e implementamos herramientas IA adaptadas a su contexto.",
                        pt: "Você tem um projeto, uma necessidade empresarial, uma ideia de automação. Seja qual for seu setor — imobiliário, varejo, RH, logística, saúde, jurídico — projetamos e implantamos ferramentas IA adequadas ao seu contexto.",
                        ar: "لديك مشروع، حاجة عمل، فكرة أتمتة. أياً كان قطاعك — عقارات، تجارة، موارد بشرية، لوجستيات، صحة، قانوني — نصمم وننشر أدوات ذكاء اصطناعي تناسب سياقك بالضبط." },
      cta_diag:       { fr: 'Diagnostic gratuit (2h) →', en: 'Free diagnostic (2h) →', es: 'Diagnóstico gratuito (2h) →', pt: 'Diagnóstico gratuito (2h) →', ar: 'تشخيص مجاني (2 ساعة) →' },
      cta_services:   { fr: 'Nos prestations',      en: 'Our services',           es: 'Nuestros servicios',     pt: 'Nossos serviços',        ar: 'خدماتنا' },
      stats_title:    { fr: 'Ce que vous pouvez attendre', en: 'What you can expect', es: 'Lo que puede esperar', pt: 'O que você pode esperar', ar: 'ما يمكنك توقعه' },
      stat1_label:    { fr: 'Gain de temps moyen',  en: 'Average time saved',     es: 'Ahorro de tiempo medio', pt: 'Economia média de tempo', ar: 'متوسط توفير الوقت' },
      stat1_desc:     { fr: "Sur les tâches répétitives identifiées lors de l'audit initial.", en: 'On repetitive tasks identified during the initial audit.', es: 'En tareas repetitivas identificadas en la auditoría inicial.', pt: 'Em tarefas repetitivas identificadas na auditoria inicial.', ar: 'في المهام المتكررة المحددة خلال التدقيق الأولي.' },
      stat2_label:    { fr: 'Premier outil en production', en: 'First tool in production', es: 'Primera herramienta en producción', pt: 'Primeira ferramenta em produção', ar: 'أول أداة في الإنتاج' },
      stat2_desc:     { fr: "De l'idée au déploiement, sans transformer votre SI existant.", en: 'From idea to deployment, without disrupting your existing systems.', es: 'De la idea al despliegue, sin transformar sus sistemas existentes.', pt: 'Da ideia à implantação, sem alterar seus sistemas existentes.', ar: 'من الفكرة إلى النشر، دون تغيير أنظمتك الحالية.' },
      stat3_label:    { fr: 'Adapté à votre contexte', en: 'Tailored to your context', es: 'Adaptado a su contexto', pt: 'Adaptado ao seu contexto', ar: 'مصمم لسياقك' },
      stat3_desc:     { fr: "Pas de solution générique — chaque outil est pensé pour vos données et vos équipes.", en: 'No generic solutions — every tool is designed for your data and your teams.', es: 'Sin soluciones genéricas — cada herramienta está diseñada para sus datos y equipos.', pt: 'Sem soluções genéricas — cada ferramenta é projetada para seus dados e equipes.', ar: 'لا حلول عامة — كل أداة مصممة لبياناتك وفرقك.' },
      // Problem section
      prob_label:     { fr: 'Le constat',            en: 'The problem',            es: 'El diagnóstico',         pt: 'O diagnóstico',          ar: 'المشكلة' },
      prob_h2_1:      { fr: "L'IA est puissante.",   en: 'AI is powerful.',        es: 'La IA es poderosa.',     pt: 'A IA é poderosa.',       ar: 'الذكاء الاصطناعي قوي.' },
      prob_h2_2:      { fr: 'Mais mal déployée,',    en: 'But poorly deployed,',   es: 'Pero mal desplegada,',   pt: 'Mas mal implementada,',  ar: 'لكن بنشر سيء،' },
      prob_h2_3:      { fr: "elle ne sert à rien.",  en: "it's useless.",          es: 'no sirve de nada.',      pt: 'não serve para nada.',   ar: 'تصبح بلا فائدة.' },
      prob_sub:       { fr: "La plupart des projets IA échouent non pas par manque de technologie, mais par manque d'ancrage métier. On déploie des outils génériques là où il faut des solutions adaptées.",
                        en: 'Most AI projects fail not because of technology, but because of poor business alignment. Generic tools are deployed where tailored solutions are needed.',
                        es: 'La mayoría de proyectos IA fracasan no por falta de tecnología, sino por falta de alineamiento empresarial.',
                        pt: 'A maioria dos projetos de IA falham não por falta de tecnologia, mas por falta de alinhamento empresarial.',
                        ar: 'تفشل معظم مشاريع الذكاء الاصطناعي ليس بسبب التكنولوجيا، بل بسبب ضعف التوافق مع الأعمال.' },
      prob1_t:        { fr: "Cas d'usage mal définis", en: 'Poorly defined use cases', es: 'Casos de uso mal definidos', pt: 'Casos de uso mal definidos', ar: 'حالات استخدام محددة بشكل سيء' },
      prob1_d:        { fr: "On commence par \"faire de l'IA\" sans identifier les tâches à fort ROI. Résultat : des outils que personne n'utilise.", en: "Starting with \"doing AI\" without identifying high-ROI tasks. Result: tools nobody uses.", es: 'Se empieza por "hacer IA" sin identificar tareas de alto ROI. Resultado: herramientas que nadie usa.', pt: 'Começar por "fazer IA" sem identificar tarefas de alto ROI. Resultado: ferramentas que ninguém usa.', ar: 'البدء بـ"تطبيق الذكاء الاصطناعي" دون تحديد المهام ذات العائد العالي. النتيجة: أدوات لا يستخدمها أحد.' },
      prob2_t:        { fr: 'Outils trop génériques', en: 'Tools too generic', es: 'Herramientas demasiado genéricas', pt: 'Ferramentas genéricas demais', ar: 'أدوات عامة جداً' },
      prob2_d:        { fr: "ChatGPT, Copilot, Gemini : puissants, mais pas calibrés pour vos données, vos process, votre vocabulaire métier.", en: 'ChatGPT, Copilot, Gemini: powerful, but not calibrated for your data, processes, or industry jargon.', es: 'ChatGPT, Copilot, Gemini: potentes, pero no calibrados para sus datos ni vocabulario sectorial.', pt: 'ChatGPT, Copilot, Gemini: poderosos, mas não calibrados para seus dados nem vocabulário do setor.', ar: 'ChatGPT، Copilot، Gemini: قوية لكن غير مُعايرة لبياناتك وعملياتك ومصطلحات قطاعك.' },
      prob3_t:        { fr: 'Adoption en échec',     en: 'Failed adoption',        es: 'Adopción fallida',       pt: 'Adoção fracassada',      ar: 'فشل التبني' },
      prob3_d:        { fr: "Sans formation adaptée et sans accompagnement au changement, même les meilleurs outils restent inutilisés.", en: 'Without proper training and change management, even the best tools remain unused.', es: 'Sin formación adecuada ni gestión del cambio, incluso las mejores herramientas quedan sin uso.', pt: 'Sem treinamento adequado e gestão de mudança, até as melhores ferramentas ficam sem uso.', ar: 'بدون تدريب مناسب وإدارة تغيير، حتى أفضل الأدوات تبقى غير مستخدمة.' },
      prob4_t:        { fr: 'ROI difficile à mesurer', en: 'Hard-to-measure ROI',  es: 'ROI difícil de medir',   pt: 'ROI difícil de medir',   ar: 'عائد استثمار صعب القياس' },
      prob4_d:        { fr: "On investit sans avoir défini les indicateurs de succès. Six mois plus tard, impossible de justifier l'investissement.", en: "Investing without defining success metrics. Six months later, impossible to justify the spend.", es: 'Se invierte sin definir indicadores de éxito. Seis meses después, imposible justificar la inversión.', pt: 'Investir sem definir indicadores de sucesso. Seis meses depois, impossível justificar o investimento.', ar: 'الاستثمار دون تحديد مقاييس النجاح. بعد ستة أشهر، يستحيل تبرير الإنفاق.' },
      // Services section
      svc_label:      { fr: 'Nos prestations',      en: 'Our services',           es: 'Nuestros servicios',     pt: 'Nossos serviços',        ar: 'خدماتنا' },
      svc_h2_1:       { fr: 'Trois modes',          en: 'Three modes',            es: 'Tres modos',             pt: 'Três modos',             ar: 'ثلاثة أنماط' },
      svc_h2_2:       { fr: "d'intervention.",       en: 'of engagement.',         es: 'de intervención.',       pt: 'de intervenção.',        ar: 'للتدخل.' },
      svc_sub:        { fr: "Du diagnostic express au déploiement complet — nous intervenons au niveau qui correspond à votre maturité et à vos ressources.",
                        en: 'From quick diagnostics to full deployment — we engage at the level that matches your maturity and resources.',
                        es: 'Del diagnóstico rápido al despliegue completo — intervenimos al nivel que corresponde a su madurez y recursos.',
                        pt: 'Do diagnóstico rápido à implantação completa — atuamos no nível adequado à sua maturidade e recursos.',
                        ar: 'من التشخيص السريع إلى النشر الكامل — نتدخل بالمستوى المناسب لنضجك ومواردك.' },
      svc1_title:     { fr: 'Audit & Stratégie IA',  en: 'AI Audit & Strategy',   es: 'Auditoría y Estrategia IA', pt: 'Auditoria e Estratégia IA', ar: 'تدقيق واستراتيجية IA' },
      svc1_desc:      { fr: "Une immersion dans votre organisation pour cartographier les opportunités IA, prioriser les cas d'usage et définir une roadmap actionnable.",
                        en: 'An immersion in your organization to map AI opportunities, prioritize use cases, and define an actionable roadmap.',
                        es: 'Una inmersión en su organización para mapear oportunidades IA, priorizar casos de uso y definir una hoja de ruta accionable.',
                        pt: 'Uma imersão em sua organização para mapear oportunidades de IA, priorizar casos de uso e definir um roadmap acionável.',
                        ar: 'غوص في مؤسستك لرسم فرص الذكاء الاصطناعي، وتحديد أولويات حالات الاستخدام، ووضع خارطة طريق قابلة للتنفيذ.' },
      svc1_l1:        { fr: 'Atelier de 2h avec vos équipes métier', en: '2h workshop with your business teams', es: 'Taller de 2h con sus equipos', pt: 'Workshop de 2h com suas equipes', ar: 'ورشة عمل لمدة ساعتين مع فرقك' },
      svc1_l2:        { fr: 'Cartographie des process automatisables', en: 'Mapping of automatable processes', es: 'Mapa de procesos automatizables', pt: 'Mapeamento de processos automatizáveis', ar: 'رسم خريطة العمليات القابلة للأتمتة' },
      svc1_l3:        { fr: 'Identification des quick wins (ROI rapide)', en: 'Quick wins identification (fast ROI)', es: 'Identificación de quick wins (ROI rápido)', pt: 'Identificação de quick wins (ROI rápido)', ar: 'تحديد المكاسب السريعة (عائد سريع)' },
      svc1_l4:        { fr: "Roadmap IA priorisée avec estimations", en: 'Prioritized AI roadmap with estimates', es: 'Hoja de ruta IA priorizada con estimaciones', pt: 'Roadmap IA priorizado com estimativas', ar: 'خارطة طريق IA مرتبة حسب الأولوية مع تقديرات' },
      svc1_l5:        { fr: "Recommandation d'outils et d'architectures", en: 'Tool and architecture recommendations', es: 'Recomendaciones de herramientas y arquitectura', pt: 'Recomendações de ferramentas e arquitetura', ar: 'توصيات الأدوات والهندسة المعمارية' },
      svc2_title:     { fr: 'Développement sur mesure', en: 'Custom development',  es: 'Desarrollo a medida',    pt: 'Desenvolvimento personalizado', ar: 'تطوير مخصص' },
      svc2_desc:      { fr: "Nous concevons et déployons des outils IA calibrés pour vos données et vos équipes — interfaces web, agents IA, automatisations, intégrations.",
                        en: 'We design and deploy AI tools calibrated for your data and teams — web interfaces, AI agents, automations, integrations.',
                        es: 'Diseñamos e implementamos herramientas IA calibradas para sus datos y equipos — interfaces web, agentes IA, automatizaciones, integraciones.',
                        pt: 'Projetamos e implantamos ferramentas IA calibradas para seus dados e equipes — interfaces web, agentes IA, automações, integrações.',
                        ar: 'نصمم وننشر أدوات ذكاء اصطناعي مُعايرة لبياناتك وفرقك — واجهات ويب، وكلاء IA، أتمتة، تكامل.' },
      svc2_l1:        { fr: 'Outils IA métier (interface web ou API)', en: 'Business AI tools (web interface or API)', es: 'Herramientas IA empresariales (web o API)', pt: 'Ferramentas IA empresariais (web ou API)', ar: 'أدوات IA للأعمال (واجهة ويب أو API)' },
      svc2_l2:        { fr: 'Agents IA sur vos données propriétaires', en: 'AI agents on your proprietary data', es: 'Agentes IA sobre sus datos propietarios', pt: 'Agentes IA em seus dados proprietários', ar: 'وكلاء IA على بياناتك الخاصة' },
      svc2_l3:        { fr: 'Automatisations (n8n, Make, Zapier, custom)', en: 'Automations (n8n, Make, Zapier, custom)', es: 'Automatizaciones (n8n, Make, Zapier, custom)', pt: 'Automações (n8n, Make, Zapier, custom)', ar: 'أتمتة (n8n، Make، Zapier، مخصصة)' },
      svc2_l4:        { fr: 'Intégrations à vos logiciels existants', en: 'Integrations with your existing software', es: 'Integraciones con su software existente', pt: 'Integrações com seus softwares existentes', ar: 'تكامل مع برامجك الحالية' },
      svc2_l5:        { fr: 'Documentation et tests utilisateurs inclus', en: 'Documentation and user testing included', es: 'Documentación y pruebas de usuario incluidas', pt: 'Documentação e testes de usuário incluídos', ar: 'التوثيق واختبار المستخدم مشمولان' },
      svc3_title:     { fr: 'Formation & Accompagnement', en: 'Training & Support', es: 'Formación y Acompañamiento', pt: 'Treinamento e Acompanhamento', ar: 'تدريب ودعم' },
      svc3_desc:      { fr: "L'IA n'est utile que si vos équipes savent l'utiliser. Nous formons vos collaborateurs et construisons une culture IA durable dans votre organisation.",
                        en: "AI is only useful if your teams know how to use it. We train your team and build a lasting AI culture in your organization.",
                        es: 'La IA solo es útil si sus equipos saben usarla. Formamos a sus colaboradores y construimos una cultura IA duradera.',
                        pt: 'A IA só é útil se suas equipes souberem usá-la. Treinamos seus colaboradores e construímos uma cultura de IA duradoura.',
                        ar: 'الذكاء الاصطناعي مفيد فقط إذا عرفت فرقك كيفية استخدامه. ندرب فريقك ونبني ثقافة IA مستدامة في مؤسستك.' },
      svc3_l1:        { fr: 'Ateliers de formation sur mesure (½ journée à 2 jours)', en: 'Custom training workshops (½ day to 2 days)', es: 'Talleres de formación a medida (½ día a 2 días)', pt: 'Workshops de treinamento personalizados (½ dia a 2 dias)', ar: 'ورش تدريب مخصصة (نصف يوم إلى يومين)' },
      svc3_l2:        { fr: 'Création de prompts métier pour vos équipes', en: 'Business prompt creation for your teams', es: 'Creación de prompts empresariales para sus equipos', pt: 'Criação de prompts empresariais para suas equipes', ar: 'إنشاء prompts أعمال لفرقك' },
      svc3_l3:        { fr: "Guide d'utilisation et bibliothèque de cas d'usage", en: 'User guide and use case library', es: 'Guía de uso y biblioteca de casos de uso', pt: 'Guia de uso e biblioteca de casos de uso', ar: 'دليل المستخدم ومكتبة حالات الاستخدام' },
      svc3_l4:        { fr: 'Accompagnement au changement', en: 'Change management support', es: 'Acompañamiento al cambio', pt: 'Acompanhamento de mudança', ar: 'دعم إدارة التغيير' },
      svc3_l5:        { fr: 'Suivi mensuel et optimisation continue', en: 'Monthly follow-up and continuous optimization', es: 'Seguimiento mensual y optimización continua', pt: 'Acompanhamento mensal e otimização contínua', ar: 'متابعة شهرية وتحسين مستمر' },
      // Process section
      proc_label:     { fr: 'Notre méthode',        en: 'Our method',             es: 'Nuestro método',         pt: 'Nosso método',           ar: 'منهجنا' },
      proc_h2_1:      { fr: 'Du diagnostic au',     en: 'From diagnostic to',     es: 'Del diagnóstico al',     pt: 'Do diagnóstico à',       ar: 'من التشخيص إلى' },
      proc_h2_2:      { fr: 'déploiement',          en: 'deployment',             es: 'despliegue',             pt: 'implantação',            ar: 'النشر' },
      proc_h2_3:      { fr: 'en 3 étapes.',         en: 'in 3 steps.',            es: 'en 3 pasos.',            pt: 'em 3 etapas.',           ar: 'في 3 خطوات.' },
      proc_sub:       { fr: "Pas de mois de conseil sans livrable. On identifie vite, on déploie vite, on mesure et on itère.",
                        en: 'No months of consulting without deliverables. We identify fast, deploy fast, measure, and iterate.',
                        es: 'Sin meses de consultoría sin entregables. Identificamos rápido, desplegamos rápido, medimos e iteramos.',
                        pt: 'Sem meses de consultoria sem entregas. Identificamos rápido, implantamos rápido, medimos e iteramos.',
                        ar: 'لا شهور استشارة بدون مخرجات. نحدد بسرعة، ننشر بسرعة، نقيس ونكرر.' },
      step1_week:     { fr: 'Semaine 1',            en: 'Week 1',                 es: 'Semana 1',               pt: 'Semana 1',               ar: 'الأسبوع 1' },
      step1_title:    { fr: 'Diagnostic',           en: 'Diagnostic',             es: 'Diagnóstico',            pt: 'Diagnóstico',            ar: 'التشخيص' },
      step1_desc:     { fr: "2h de travail avec vous et vos équipes pour cartographier les process, identifier les données disponibles et prioriser les cas d'usage à fort ROI.",
                        en: '2h working with you and your teams to map processes, identify available data, and prioritize high-ROI use cases.',
                        es: '2h de trabajo con usted y sus equipos para mapear procesos, identificar datos disponibles y priorizar casos de uso de alto ROI.',
                        pt: '2h de trabalho com você e suas equipes para mapear processos, identificar dados disponíveis e priorizar casos de uso de alto ROI.',
                        ar: 'ساعتان من العمل معك ومع فرقك لرسم العمليات وتحديد البيانات المتاحة وترتيب حالات الاستخدام ذات العائد العالي.' },
      step1_del:      { fr: '→ Livrable : Roadmap IA priorisée', en: '→ Deliverable: Prioritized AI roadmap', es: '→ Entregable: Hoja de ruta IA priorizada', pt: '→ Entregável: Roadmap IA priorizado', ar: '→ المخرج: خارطة طريق IA مرتبة حسب الأولوية' },
      step2_week:     { fr: 'Semaines 2–6',         en: 'Weeks 2–6',              es: 'Semanas 2–6',            pt: 'Semanas 2–6',            ar: 'الأسابيع 2-6' },
      step2_title:    { fr: 'Déploiement',          en: 'Deployment',             es: 'Despliegue',             pt: 'Implantação',            ar: 'النشر' },
      step2_desc:     { fr: "Développement et mise en production des outils identifiés. Formation de vos équipes. Premier outil opérationnel en moins de 2 semaines.",
                        en: 'Development and production deployment of identified tools. Team training. First operational tool in under 2 weeks.',
                        es: 'Desarrollo y puesta en producción de las herramientas identificadas. Formación de equipos. Primera herramienta operativa en menos de 2 semanas.',
                        pt: 'Desenvolvimento e implantação em produção das ferramentas identificadas. Treinamento de equipes. Primeira ferramenta operacional em menos de 2 semanas.',
                        ar: 'تطوير ونشر الأدوات المحددة في الإنتاج. تدريب الفرق. أول أداة تشغيلية في أقل من أسبوعين.' },
      step2_del:      { fr: '→ Livrable : Outils IA en production + documentation', en: '→ Deliverable: AI tools in production + documentation', es: '→ Entregable: Herramientas IA en producción + documentación', pt: '→ Entregável: Ferramentas IA em produção + documentação', ar: '→ المخرج: أدوات IA في الإنتاج + التوثيق' },
      step3_week:     { fr: 'Ongoing',              en: 'Ongoing',                es: 'Continuo',               pt: 'Contínuo',               ar: 'مستمر' },
      step3_title:    { fr: 'Optimisation',         en: 'Optimization',           es: 'Optimización',           pt: 'Otimização',             ar: 'التحسين' },
      step3_desc:     { fr: "Suivi des métriques d'impact, ajustements des modèles, nouvelles fonctionnalités au fil des besoins. Vos outils s'améliorent avec votre activité.",
                        en: 'Impact metrics tracking, model adjustments, new features as needs evolve. Your tools improve as your business grows.',
                        es: 'Seguimiento de métricas de impacto, ajustes de modelos, nuevas funcionalidades según las necesidades. Sus herramientas mejoran con su actividad.',
                        pt: 'Acompanhamento de métricas de impacto, ajustes de modelos, novas funcionalidades conforme necessidades. Suas ferramentas melhoram com seu negócio.',
                        ar: 'تتبع مقاييس التأثير، تعديلات النماذج، ميزات جديدة حسب الحاجة. أدواتك تتحسن مع نمو عملك.' },
      step3_del:      { fr: "→ Livrable : Rapport mensuel d'impact", en: '→ Deliverable: Monthly impact report', es: '→ Entregable: Informe mensual de impacto', pt: '→ Entregável: Relatório mensal de impacto', ar: '→ المخرج: تقرير تأثير شهري' },
      // Sectors
      sec_label:      { fr: 'Pour qui',             en: 'Who we serve',           es: 'Para quién',             pt: 'Para quem',              ar: 'لمن نخدم' },
      sec_h2_1:       { fr: 'Tous secteurs,',       en: 'All industries,',        es: 'Todos los sectores,',    pt: 'Todos os setores,',      ar: 'جميع القطاعات،' },
      sec_h2_2:       { fr: 'toutes tailles.',      en: 'all sizes.',             es: 'todos los tamaños.',     pt: 'todos os tamanhos.',     ar: 'جميع الأحجام.' },
      sec_sub:        { fr: "Dirigeants de PME, responsables métier, fondateurs en croissance — notre accompagnement s'adapte à votre contexte et à votre budget.",
                        en: 'SMB leaders, business managers, growing founders — our support adapts to your context and budget.',
                        es: 'Líderes de PYME, responsables de negocio, fundadores en crecimiento — nuestro acompañamiento se adapta a su contexto y presupuesto.',
                        pt: 'Líderes de PMEs, gerentes de negócios, fundadores em crescimento — nosso suporte se adapta ao seu contexto e orçamento.',
                        ar: 'قادة الشركات الصغيرة والمتوسطة، مديرو الأعمال، المؤسسون الناشئون — دعمنا يتكيف مع سياقك وميزانيتك.' },
      sec_immo:       { fr: 'Immobilier',            en: 'Real Estate',            es: 'Inmobiliaria',           pt: 'Imobiliário',            ar: 'عقارات' },
      sec_immo_d:     { fr: "Agents, promoteurs, syndics, property managers — automatisation des tâches admin et commerciales.", en: 'Agents, developers, property managers — automating admin and commercial tasks.', es: 'Agentes, promotores, administradores — automatización de tareas administrativas y comerciales.', pt: 'Agentes, promotores, administradores — automação de tarefas administrativas e comerciais.', ar: 'وكلاء، مطورون، مديرو عقارات — أتمتة المهام الإدارية والتجارية.' },
      sec_commerce:   { fr: 'Commerce & E-commerce', en: 'Retail & E-commerce',    es: 'Comercio y E-commerce',  pt: 'Comércio e E-commerce',  ar: 'تجارة وتجارة إلكترونية' },
      sec_commerce_d: { fr: "Fiches produits, SAV, emails marketing, gestion des retours — IA intégrée à vos outils ecom.", en: 'Product listings, customer service, marketing emails, returns management — AI integrated with your ecom tools.', es: 'Fichas de producto, SAV, emails marketing, gestión de devoluciones — IA integrada en sus herramientas ecom.', pt: 'Fichas de produto, SAC, emails marketing, gestão de devoluções — IA integrada às suas ferramentas ecom.', ar: 'قوائم المنتجات، خدمة العملاء، البريد التسويقي، إدارة المرتجعات — IA مدمج مع أدوات التجارة الإلكترونية.' },
      sec_legal:      { fr: 'Juridique',             en: 'Legal',                  es: 'Legal',                  pt: 'Jurídico',               ar: 'قانوني' },
      sec_legal_d:    { fr: "Cabinets d'avocats, notaires, juristes d'entreprise — rédaction, résumés, recherche assistée.", en: 'Law firms, notaries, in-house counsel — drafting, summaries, assisted research.', es: 'Bufetes de abogados, notarios, juristas de empresa — redacción, resúmenes, investigación asistida.', pt: 'Escritórios de advocacia, notários, juristas corporativos — redação, resumos, pesquisa assistida.', ar: 'مكاتب محاماة، كتاب عدل، مستشارون قانونيون — صياغة، ملخصات، بحث مساعد.' },
      sec_finance:    { fr: 'Finance & Comptabilité', en: 'Finance & Accounting',  es: 'Finanzas y Contabilidad', pt: 'Finanças e Contabilidade', ar: 'مالية ومحاسبة' },
      sec_finance_d:  { fr: "CGP, DAF, experts-comptables — rapports financiers automatisés, analyses de KPIs, synthèses d'investissement, prévisions budgétaires et due diligence IA.", en: 'Advisors, CFOs, accountants — automated financial reports, KPI analysis, investment summaries, budget forecasts, and AI due diligence.', es: 'Asesores, directores financieros, contadores — informes financieros automatizados, análisis de KPIs.', pt: 'Assessores, CFOs, contadores — relatórios financeiros automatizados, análise de KPIs.', ar: 'مستشارون، مدراء ماليون، محاسبون — تقارير مالية آلية، تحليل مؤشرات الأداء.' },
      sec_sante:      { fr: 'Santé & Médical',      en: 'Health & Medical',       es: 'Salud y Médico',         pt: 'Saúde e Médico',         ar: 'صحة وطب' },
      sec_sante_d:    { fr: "Cliniques, cabinets, laboratoires — aide à la documentation, triage, reporting administratif.", en: 'Clinics, practices, labs — documentation assistance, triage, administrative reporting.', es: 'Clínicas, consultorios, laboratorios — ayuda con documentación, triage, informes administrativos.', pt: 'Clínicas, consultórios, laboratórios — assistência documental, triagem, relatórios administrativos.', ar: 'عيادات، مكاتب، مختبرات — مساعدة التوثيق، الفرز، التقارير الإدارية.' },
      sec_logistique: { fr: 'Logistique & Industrie', en: 'Logistics & Industry', es: 'Logística e Industria',  pt: 'Logística e Indústria',  ar: 'لوجستيات وصناعة' },
      sec_logistique_d:{ fr: "Suivi de flux, prévision de stocks, maintenance prédictive, reporting opérationnel automatisé.", en: 'Flow tracking, stock forecasting, predictive maintenance, automated operational reporting.', es: 'Seguimiento de flujos, previsión de stocks, mantenimiento predictivo, informes operacionales automatizados.', pt: 'Rastreamento de fluxo, previsão de estoque, manutenção preditiva, relatórios operacionais automatizados.', ar: 'تتبع التدفق، توقع المخزون، الصيانة التنبؤية، التقارير التشغيلية الآلية.' },
      sec_rh:         { fr: 'RH & Recrutement',     en: 'HR & Recruitment',       es: 'RRHH y Reclutamiento',   pt: 'RH e Recrutamento',      ar: 'موارد بشرية وتوظيف' },
      sec_rh_d:       { fr: "Scoring de candidatures, rédaction d'offres, onboarding automatisé, support RH IA.", en: 'Application scoring, job post writing, automated onboarding, AI HR support.', es: 'Puntuación de candidaturas, redacción de ofertas, onboarding automatizado, soporte IA RRHH.', pt: 'Scoring de candidaturas, redação de vagas, onboarding automatizado, suporte IA RH.', ar: 'تقييم الطلبات، كتابة العروض، التهيئة الآلية، دعم الموارد البشرية بالذكاء الاصطناعي.' },
      sec_education:  { fr: 'Formation & Éducation', en: 'Training & Education',  es: 'Formación y Educación',  pt: 'Treinamento e Educação', ar: 'تدريب وتعليم' },
      sec_education_d:{ fr: "Création de contenus pédagogiques, support apprenant, correction automatisée, reporting LMS.", en: 'Learning content creation, learner support, automated grading, LMS reporting.', es: 'Creación de contenidos pedagógicos, soporte al alumno, corrección automatizada, informes LMS.', pt: 'Criação de conteúdo pedagógico, suporte ao aluno, correção automatizada, relatórios LMS.', ar: 'إنشاء محتوى تعليمي، دعم المتعلمين، التصحيح الآلي، تقارير LMS.' },
      sec_your:       { fr: 'Votre secteur',        en: 'Your industry',          es: 'Su sector',              pt: 'Seu setor',              ar: 'قطاعك' },
      sec_your_d:     { fr: "Votre métier n'est pas listé ? Contactez-nous — chaque projet est unique et nous adorons les défis inédits.", en: "Your industry not listed? Contact us — every project is unique and we love new challenges.", es: '¿Su sector no aparece? Contáctenos — cada proyecto es único y nos encantan los nuevos desafíos.', pt: 'Seu setor não está listado? Entre em contato — cada projeto é único e adoramos novos desafios.', ar: 'قطاعك غير مدرج؟ تواصل معنا — كل مشروع فريد ونحن نحب التحديات الجديدة.' },
      // Trust strip
      trust1:         { fr: 'Diagnostic 100% gratuit et sans engagement', en: '100% free diagnostic with no commitment', es: 'Diagnóstico 100% gratuito y sin compromiso', pt: 'Diagnóstico 100% gratuito e sem compromisso', ar: 'تشخيص مجاني 100% بدون التزام' },
      trust2:         { fr: 'Premier livrable en moins de 2 semaines', en: 'First deliverable in under 2 weeks', es: 'Primer entregable en menos de 2 semanas', pt: 'Primeira entrega em menos de 2 semanas', ar: 'أول مخرج في أقل من أسبوعين' },
      trust3:         { fr: 'Adapté à vos outils et données existants', en: 'Adapted to your existing tools and data', es: 'Adaptado a sus herramientas y datos existentes', pt: 'Adaptado às suas ferramentas e dados existentes', ar: 'متكيف مع أدواتك وبياناتك الحالية' },
      trust4:         { fr: 'Formation des équipes incluse', en: 'Team training included', es: 'Formación de equipos incluida', pt: 'Treinamento de equipes incluído', ar: 'تدريب الفرق مشمول' },
      // CTA
      cta_label:      { fr: "Passez à l'action",    en: 'Take action',            es: 'Pase a la acción',       pt: 'Passe à ação',           ar: 'ابدأ الآن' },
      cta_h2_1:       { fr: 'Commencez par un',     en: 'Start with a',           es: 'Comience con un',        pt: 'Comece com um',          ar: 'ابدأ بتشخيص' },
      cta_h2_2:       { fr: 'diagnostic gratuit.',   en: 'free diagnostic.',       es: 'diagnóstico gratuito.',  pt: 'diagnóstico gratuito.',  ar: 'مجاني.' },
      cta_sub:        { fr: "2 heures avec vos équipes pour cartographier vos opportunités IA et définir une roadmap priorisée — sans engagement, sans frais, sans jargon.",
                        en: '2 hours with your teams to map your AI opportunities and define a prioritized roadmap — no commitment, no fees, no jargon.',
                        es: '2 horas con sus equipos para mapear sus oportunidades IA y definir una hoja de ruta priorizada — sin compromiso, sin costes, sin jerga.',
                        pt: '2 horas com suas equipes para mapear oportunidades de IA e definir um roadmap priorizado — sem compromisso, sem custos, sem jargão.',
                        ar: 'ساعتان مع فرقك لرسم فرص الذكاء الاصطناعي ووضع خارطة طريق مرتبة — بدون التزام، بدون رسوم، بدون مصطلحات معقدة.' },
      cta_btn:        { fr: 'Réserver mon diagnostic gratuit →', en: 'Book my free diagnostic →', es: 'Reservar mi diagnóstico gratuito →', pt: 'Reservar meu diagnóstico gratuito →', ar: 'احجز تشخيصي المجاني →' },
      cta_email:      { fr: 'Envoyer un email',     en: 'Send an email',          es: 'Enviar un email',        pt: 'Enviar um email',        ar: 'أرسل بريداً إلكترونياً' },
      cta_note:       { fr: 'Réponse sous 24h · France, Belgique, Suisse · Remote ou présentiel', en: 'Response within 24h · Worldwide · Remote or on-site', es: 'Respuesta en 24h · Todo el mundo · Remoto o presencial', pt: 'Resposta em 24h · Worldwide · Remoto ou presencial', ar: 'رد خلال 24 ساعة · عالمياً · عن بُعد أو حضورياً' },
    },

    /* ── Vertical descriptions (for tarifs tabs) ────────────────────────── */
    vdescs: {
      immo:         { fr: 'Agents, promoteurs, syndics',               en: 'Agents, developers, property managers',     es: 'Agentes, promotores, administradores',      pt: 'Agentes, promotores, administradores',      ar: 'وكلاء، مطورون، مديرو عقارات' },
      commerce:     { fr: 'E-commerce, retail, marques',               en: 'E-commerce, retail, brands',                es: 'E-commerce, retail, marcas',                pt: 'E-commerce, varejo, marcas',                ar: 'تجارة إلكترونية، تجزئة، علامات' },
      legal:        { fr: 'Avocats, juristes, notaires',               en: 'Lawyers, legal advisors, notaries',         es: 'Abogados, asesores, notarios',              pt: 'Advogados, consultores, notários',          ar: 'محامون، مستشارون، كتّاب عدل' },
      finance:      { fr: 'CGP, analystes, DAF',                       en: 'Advisors, analysts, CFOs',                  es: 'Asesores, analistas, CFOs',                 pt: 'Assessores, analistas, CFOs',               ar: 'مستشارون، محللون، مدراء ماليون' },
      marketing:    { fr: 'Agences, CMO, growth',                      en: 'Agencies, CMOs, growth teams',              es: 'Agencias, CMOs, growth',                    pt: 'Agências, CMOs, growth',                    ar: 'وكالات، CMOs، فرق النمو' },
      rh:           { fr: 'DRH, recruteurs, managers',                 en: 'HR directors, recruiters, managers',        es: 'RRHH, reclutadores, managers',              pt: 'RH, recrutadores, gestores',                ar: 'موارد بشرية، مجندون، مديرون' },
      sante:        { fr: 'Praticiens, cliniques, coachs',             en: 'Practitioners, clinics, coaches',           es: 'Profesionales, clínicas, coaches',          pt: 'Profissionais, clínicas, coaches',          ar: 'ممارسون، عيادات، مدربون' },
      education:    { fr: 'Formateurs, écoles, EdTech',                en: 'Trainers, schools, EdTech',                 es: 'Formadores, escuelas, EdTech',              pt: 'Formadores, escolas, EdTech',               ar: 'مدربون، مدارس، EdTech' },
      restauration: { fr: 'Restaurants, traiteurs, franchises',        en: 'Restaurants, caterers, franchises',         es: 'Restaurantes, catering, franquicias',       pt: 'Restaurantes, catering, franquias',         ar: 'مطاعم، تموين، امتيازات' },
      freelance:    { fr: 'Indépendants, consultants, coachs',        en: 'Freelancers, consultants, coaches',         es: 'Freelancers, consultores, coaches',         pt: 'Freelancers, consultores, coaches',         ar: 'مستقلون، استشاريون، مدربون' },
    },
  };

  /* ════════════════════════════════════════════════════════════════════════
   * PUBLIC API
   * ════════════════════════════════════════════════════════════════════════ */

  /** Get current language */
  function lang() {
    return document.documentElement.getAttribute('data-lang') || 'en';
  }

  /**
   * T(path, [langOverride]) — Get translated string for the current (or specified) lang.
   *   T('common.loading')       → 'Loading…'
   *   T('common.loading', 'fr') → 'Chargement…'
   *   T('plans.starter.desc')   → plan description
   *
   * Supports simple {var} placeholders:
   *   T('dashboard.free_trial_days', null, { d: 5 }) → 'Free trial (5d left)'
   */
  function T(path, langOverride, vars) {
    const parts = path.split('.');
    let obj = I18N;
    for (const p of parts) {
      obj = obj?.[p];
      if (!obj) return path; // fallback: return key
    }
    // obj is now either a lang object {fr:'...',en:'...'} or nested
    const l = langOverride || lang();
    let str = obj[l] || obj['en'] || obj['fr'] || '';
    // Replace {var} placeholders
    if (vars) {
      Object.entries(vars).forEach(([k, v]) => {
        str = str.replace(new RegExp('\\{' + k + '\\}', 'g'), v);
      });
    }
    return str;
  }

  /**
   * TH(path) — Get all-language HTML spans for use in innerHTML.
   *   TH('common.loading') → '<span data-fr>Chargement…</span><span data-en>Loading…</span>...'
   */
  function TH(path, vars) {
    const parts = path.split('.');
    let obj = I18N;
    for (const p of parts) {
      obj = obj?.[p];
      if (!obj) return path;
    }
    const LANGS = ['fr', 'en', 'es', 'pt', 'ar'];
    return LANGS.map(l => {
      let str = obj[l] || '';
      if (vars) {
        Object.entries(vars).forEach(([k, v]) => {
          str = str.replace(new RegExp('\\{' + k + '\\}', 'g'), v);
        });
      }
      return str ? `<span data-${l}>${str}</span>` : '';
    }).join('');
  }

  /**
   * TList(basePath) — Get an array of translated strings from a keyed object.
   *   TList('plans.starter.features') → ['3 essential tools', '50 generations / month', ...]
   */
  function TList(basePath) {
    const parts = basePath.split('.');
    let obj = I18N;
    for (const p of parts) {
      obj = obj?.[p];
      if (!obj) return [];
    }
    const l = lang();
    return Object.values(obj).map(entry => entry[l] || entry['en'] || entry['fr'] || '');
  }

  /**
   * THList(basePath) — Get array of multilingual HTML spans.
   */
  function THList(basePath) {
    const parts = basePath.split('.');
    let obj = I18N;
    for (const p of parts) {
      obj = obj?.[p];
      if (!obj) return [];
    }
    const LANGS = ['fr', 'en', 'es', 'pt', 'ar'];
    return Object.keys(obj).map(key => {
      const entry = obj[key];
      return LANGS.map(l => entry[l] ? `<span data-${l}>${entry[l]}</span>` : '').join('');
    });
  }

  /**
   * Register a callback to be called whenever language changes.
   * Useful for re-rendering JS-generated content.
   */
  function onChange(cb) {
    _callbacks.push(cb);
  }

  /** Trigger all onChange callbacks (called by ps-lang.js) */
  function _notifyChange(newLang) {
    _callbacks.forEach(cb => { try { cb(newLang); } catch(e) { console.error('[i18n] onChange error:', e); } });
  }

  // Expose
  return { T, TH, TList, THList, lang, onChange, _notifyChange, _I18N: I18N };
})();

// Shortcuts for convenience
const T  = PS_I18N.T;
const TH = PS_I18N.TH;
