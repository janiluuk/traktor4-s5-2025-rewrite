function deviceName(flavor) {
    switch (flavor) {
        case 0:
            return 'D2';
        case 1:
            return 'S8';
        case 2:
            return 'S5';
        case 3:
            return 'S4MK3';
        default:
            return 'Unknown';
    }
}
