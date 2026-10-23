String csatLabel(int value) {
  switch (value) {
    case 1:
      return 'Very dissatisfied';
    case 2:
      return 'Dissatisfied';
    case 3:
      return 'Neutral';
    case 4:
      return 'Satisfied';
    case 5:
      return 'Very satisfied';
    default:
      return '';
  }
}

String questionCountText(int count) {
  return count == 1 ? '1 question' : '$count questions';
}
