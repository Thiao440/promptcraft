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
