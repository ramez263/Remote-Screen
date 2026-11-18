class SurveyQuestion {
  final String question;
  final List<String> options;

  const SurveyQuestion({required this.question, required this.options});
}

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final int durationMinutes;
  final double rewardEgp;
  final int rewardPoints;
  final bool isTopRated;
  final bool isFeatured;
  bool active;
  int completedCount;
  final List<SurveyQuestion> questions;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationMinutes,
    required this.rewardEgp,
    required this.rewardPoints,
    this.isTopRated = false,
    this.isFeatured = false,
    this.active = true,
    this.completedCount = 0,
    required this.questions,
  });
}

class WithdrawalRequest {
  final String id;
  final String userName;
  final String method;
  final String accountInfo;
  final double amountEgp;
  String status; // pending, approved, rejected
  final DateTime createdAt;

  WithdrawalRequest({
    required this.id,
    required this.userName,
    required this.method,
    required this.accountInfo,
    required this.amountEgp,
    this.status = 'pending',
    required this.createdAt,
  });
}

class AppStateController {
  double balanceEgp = 0.0;
  double targetGoalEgp = 386.0;
  int points = 0;
  int xp = 0;
  int streakDays = 0;
  int freeSpinsLeft = 2;
  int freeScratchesLeft = 2;
  String adminPassword = 'admin2026';

  final List<TaskItem> tasks = [
    TaskItem(
      id: 't1',
      title: 'استبيان تجربة التطبيقات البنكية الرقمية',
      description: 'شاركنا رأيك في استخدام المحافظ الإلكترونية.',
      category: 'survey',
      durationMinutes: 5,
      rewardEgp: 6.38,
      rewardPoints: 45,
      isTopRated: true,
      isFeatured: true,
      completedCount: 412,
      questions: const [
        SurveyQuestion(
          question: 'ما أكثر وسيلة دفع تستخدمها أسبوعيًا؟',
          options: ['فودافون كاش', 'إنستا باي', 'البطاقات البنكية'],
        ),
        SurveyQuestion(
          question: 'ما العامل الأهم عند اختيار تطبيق مالي؟',
          options: ['سرعة التحويل', 'انخفاض الرسوم', 'سهولة الواجهة'],
        ),
      ],
    ),
    TaskItem(
      id: 't2',
      title: 'تقييم خدمات التوصيل السريع',
      description: 'استبيان سريع حول سرعة وجودة التوصيل.',
      category: 'quick',
      durationMinutes: 3,
      rewardEgp: 7.66,
      rewardPoints: 50,
      completedCount: 538,
      questions: const [
        SurveyQuestion(
          question: 'ما متوسط وقت التوصيل المقبول لديك؟',
          options: ['أقل من 30 دقيقة', '30 - 45 دقيقة', 'ساعة كاملة'],
        ),
      ],
    ),
    TaskItem(
      id: 't3',
      title: 'دراسة عادات التسوق الإلكتروني',
      description: 'أسئلة حول العروض وتأثير التقييمات.',
      category: 'survey',
      durationMinutes: 13,
      rewardEgp: 4.08,
      rewardPoints: 35,
      completedCount: 289,
      questions: const [
        SurveyQuestion(
          question: 'هل تقرأ مراجعات المشترين قبل الطلب؟',
          options: ['دائمًا', 'أحيانًا', 'نادرًا'],
        ),
      ],
    ),
  ];

  final List<WithdrawalRequest> withdrawals = [
    WithdrawalRequest(
      id: 'w1',
      userName: 'سارة عبد الرحمن',
      method: 'فودافون كاش',
      accountInfo: '0109****412',
      amountEgp: 386.0,
      status: 'approved',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    WithdrawalRequest(
      id: 'w2',
      userName: 'محمد طارق',
      method: 'إنستا باي',
      accountInfo: 'm.tarek@instapay',
      amountEgp: 150.0,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  double get multiplier {
    if (xp >= 2000) return 1.15;
    if (xp >= 1200) return 1.10;
    if (xp >= 500) return 1.05;
    return 1.0;
  }

  void completeTask(TaskItem task) {
    balanceEgp += double.parse((task.rewardEgp * multiplier).toStringAsFixed(2));
    points += (task.rewardPoints * multiplier).round();
    xp += 35;
    task.completedCount += 1;
  }
}
