import 'package:flutter_test/flutter_test.dart';
import '../lib/services/analysis_service.dart';
import '../lib/services/sofascore_repository.dart';
import '../lib/utils/constants.dart';

void main() {
  group('Filtro A - Más de 7.5 corners', () {
    test('L < 1.38 pasa el filtro A', () {
      expect(AnalysisService.filterA(1.30), isTrue);
      expect(AnalysisService.filterA(1.00), isTrue);
    });

    test('L = 1.38 exacto NO pasa el filtro A (valor de borde)', () {
      expect(AnalysisService.filterA(AppConstants.filterA_maxLocalOdds), isFalse);
    });

    test('L > 1.38 no pasa el filtro A', () {
      expect(AnalysisService.filterA(1.39), isFalse);
      expect(AnalysisService.filterA(2.00), isFalse);
    });
  });

  group('Filtro B - Menos de 11.5 corners', () {
    test('L > 2.05 Y V > L Y V < 3.30 pasa el filtro B', () {
      expect(AnalysisService.filterB(2.10, 2.50), isTrue);
      expect(AnalysisService.filterB(2.50, 3.00), isTrue);
    });

    test('L = 2.05 exacto NO pasa el filtro B (valor de borde)', () {
      expect(AnalysisService.filterB(AppConstants.filterB_minLocalOdds, 2.50), isFalse);
    });

    test('V = 3.30 exacto NO pasa el filtro B (valor de borde)', () {
      expect(AnalysisService.filterB(2.10, AppConstants.filterB_maxVisitorOdds), isFalse);
    });

    test('V <= L no pasa el filtro B', () {
      expect(AnalysisService.filterB(2.10, 2.00), isFalse);
    });

    test('V >= 3.30 no pasa el filtro B', () {
      expect(AnalysisService.filterB(2.10, 3.31), isFalse);
    });
  });

  group('Conversión de cuotas fraccionales a decimales', () {
    test('13/10 -> 2.30', () {
      expect(SofascoreRepository.parseFractionalOdds('13/10'), 2.3);
    });

    test('1/2 -> 1.50', () {
      expect(SofascoreRepository.parseFractionalOdds('1/2'), 1.5);
    });

    test('6/4 -> 2.50', () {
      expect(SofascoreRepository.parseFractionalOdds('6/4'), 2.5);
    });

    test('Decimal directo -> mismo valor', () {
      expect(SofascoreRepository.parseFractionalOdds('2.50'), 2.5);
    });
  });

  group('Cálculo de cuota total de combinada', () {
    test('Producto de cuotas', () {
      final odds = [2.0, 1.5, 1.8];
      final total = odds.fold(1.0, (p, o) => p * o);
      expect(total, 5.4);
    });

    test('Cuota total con una selección', () {
      final odds = [1.85];
      final total = odds.fold(1.0, (p, o) => p * o);
      expect(total, 1.85);
    });
  });

  group('Liquidación de combinadas (corners)', () {
    test('Más de 7.5: corners = 8 acierta', () {
      expect(8 >= AppConstants.minTotalCornersForOver7, isTrue);
    });

    test('Más de 7.5: corners = 7 falla', () {
      expect(7 >= AppConstants.minTotalCornersForOver7, isFalse);
    });

    test('Menos de 11.5: corners = 11 acierta', () {
      expect(11 <= AppConstants.maxTotalCornersForUnder11, isTrue);
    });

    test('Menos de 11.5: corners = 12 falla', () {
      expect(12 <= AppConstants.maxTotalCornersForUnder11, isFalse);
    });
  });
}
