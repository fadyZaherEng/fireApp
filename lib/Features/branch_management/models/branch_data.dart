class BranchData {
  final String branchName;
  final String employeeId;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? mallName;
  final double? space;
  final String systemType;
  final List<BranchWorkingDayData> workingDays;

  BranchData({
    required this.branchName,
    required this.employeeId,
    this.latitude,
    this.longitude,
    this.address,
    this.mallName,
    this.space,
    required this.systemType,
    required this.workingDays,
  });
}

class BranchWorkingDayData {
  final String day;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  BranchWorkingDayData({
    required this.day,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });
}
