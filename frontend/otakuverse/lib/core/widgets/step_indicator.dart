import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isCompleted = stepNumber < currentStep;
        final isActive = stepNumber == currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? AppColors.crimsonRed
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (stepNumber < totalSteps) const SizedBox(width: 4),
            ],
          ),
        );
      }),
    );
  }
}