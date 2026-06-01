import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/domain/models/name.dart';
import 'package:lilt/features/home/home_screen.dart';
import 'package:lilt/features/pool_config/veto_screen.dart';

enum _PoolPreset { quick, standard, comprehensive, custom }

/// Rough estimate of comparisons to convergence for a given pool size.
/// Based on PRD §5.3: 30→~52, 60→~90, 120→~175.
int _estimatedComparisons(int n) {
  if (n <= 0) return 0;
  return (n * 1.6).ceil();
}

class PoolConfigScreen extends ConsumerStatefulWidget {
  final bool isPartnerB;
  final bool isCoupleFlow;
  final String? partnerASessionId;

  const PoolConfigScreen({
    super.key,
    this.isPartnerB = false,
    this.isCoupleFlow = false,
    this.partnerASessionId,
  });

  @override
  ConsumerState<PoolConfigScreen> createState() => _PoolConfigScreenState();
}

class _PoolConfigScreenState extends ConsumerState<PoolConfigScreen> {
  NameGender? _genderFilter; // null = all
  _PoolPreset _preset = _PoolPreset.standard;
  int _customSize = 60;
  final List<String> _excludeIds = [];
  final TextEditingController _excludeController = TextEditingController();
  final TextEditingController _customNameController = TextEditingController();
  bool _autoStarting = false;

  @override
  void initState() {
    super.initState();
    if (widget.isPartnerB && widget.partnerASessionId != null) {
      _autoStarting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAsPartnerB());
    }
  }

  Future<void> _startAsPartnerB() async {
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final partnerA = await sessionRepo.getSession(widget.partnerASessionId!);
    if (!mounted) return;
    if (partnerA == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Partner A's session not found.")),
      );
      setState(() => _autoStarting = false);
      return;
    }

    final session = await sessionRepo.createSession(
      participantLabel: 'Partner B',
      poolIds: partnerA.poolIds,
      genderFilter: partnerA.genderFilter,
      poolSize: partnerA.poolSize,
    );
    if (!mounted) return;
    ref.invalidate(allSessionsProvider);
    context.pushReplacement(
        '/matchup/${session.id}?partnerA=${widget.partnerASessionId}');
  }

  int get _poolSize => switch (_preset) {
        _PoolPreset.quick => 30,
        _PoolPreset.standard => 60,
        _PoolPreset.comprehensive => 120,
        _PoolPreset.custom => _customSize,
      };

  /// Extract display name from ID (e.g. "mary-kate-f" → "mary-kate").
  /// ID format: {lowercase-name}-{gender-code}, gender is last segment.
  static String _displayFromId(String id) {
    final lastDash = id.lastIndexOf('-');
    if (lastDash < 0) return id;
    return id.substring(0, lastDash);
  }

  @override
  void dispose() {
    _excludeController.dispose();
    _customNameController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    final namesRepo = ref.read(namesRepositoryProvider);
    final sessionRepo = ref.read(sessionRepositoryProvider);

    final allNames = await namesRepo.getForFilter(gender: _genderFilter);
    final eligible = allNames
        .where((n) => !_excludeIds.contains(n.id))
        .toList()
      ..shuffle(math.Random());
    final candidatePool = eligible.take(_poolSize).toList();

    if (candidatePool.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Need at least 2 names to start ranking.')),
        );
      }
      return;
    }

    // Optional veto pass — user can skip with "Done" button
    List<Name> pool = candidatePool;
    if (mounted) {
      final vetoed = await Navigator.of(context).push<List<Name>>(
        MaterialPageRoute(
          builder: (_) => VetoScreen(pool: candidatePool),
        ),
      );
      if (vetoed != null && vetoed.length >= 2) {
        pool = vetoed;
      } else if (vetoed != null && vetoed.length < 2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Need at least 2 names after veto.')),
          );
        }
        return;
      } else {
        // User pressed back — cancel session creation
        return;
      }
    }

    final label = widget.isPartnerB
        ? 'Partner B'
        : (widget.isCoupleFlow || widget.partnerASessionId != null
            ? 'Partner A'
            : null);

    final session = await sessionRepo.createSession(
      participantLabel: label,
      poolIds: pool.map((n) => n.id).toList(),
      genderFilter: _genderFilter == null
          ? 'all'
          : Name.genderToCode(_genderFilter!),
      poolSize: pool.length,
    );
    if (!mounted) return;
    ref.invalidate(allSessionsProvider);

    if (widget.isPartnerB && widget.partnerASessionId != null) {
      context.pushReplacement(
          '/matchup/${session.id}?partnerA=${widget.partnerASessionId}');
    } else {
      context.pushReplacement('/matchup/${session.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_autoStarting) {
      return Scaffold(
        appBar: AppBar(title: const Text('Partner B')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading the same pool Partner A ranked…'),
            ],
          ),
        ),
      );
    }

    final estimate = _estimatedComparisons(_poolSize);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPartnerB
            ? 'Partner B — Configure Pool'
            : 'Set Up Your Pool'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isPartnerB)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Partner A has finished. Configure your session with the same pool.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            Text('Gender', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<NameGender?>(
              segments: const [
                ButtonSegment(value: null, label: Text('All')),
                ButtonSegment(value: NameGender.male, label: Text('Boys')),
                ButtonSegment(value: NameGender.female, label: Text('Girls')),
              ],
              selected: {_genderFilter},
              onSelectionChanged: (s) =>
                  setState(() => _genderFilter = s.first),
            ),
            const SizedBox(height: 24),
            Text('Pool Size', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            RadioGroup<_PoolPreset>(
              groupValue: _preset,
              onChanged: (v) => setState(() => _preset = v!),
              child: Column(
                children: _PoolPreset.values.map((preset) {
                  final label = switch (preset) {
                    _PoolPreset.quick => 'Quick  (~30 names)',
                    _PoolPreset.standard => 'Standard  (~60 names)',
                    _PoolPreset.comprehensive => 'Comprehensive  (~120 names)',
                    _PoolPreset.custom => 'Custom',
                  };
                  return RadioListTile<_PoolPreset>(
                    value: preset,
                    title: Text(label),
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ),
            if (_preset == _PoolPreset.custom)
              Slider(
                value: _customSize.toDouble(),
                min: 10,
                max: 200,
                divisions: 38,
                label: '$_customSize names',
                onChanged: (v) => setState(() => _customSize = v.round()),
              ),
            const SizedBox(height: 8),
            Text(
              '~$estimate comparisons to convergence',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Text('Add a Name (optional)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'A name not in our list? Add it here — it enters the ranking pool like any other.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _customNameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Cressida',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () async {
                  final text = _customNameController.text.trim();
                  if (text.isEmpty) return;
                  final gender = _genderFilter ?? NameGender.neutral;
                  final id =
                      '${text.toLowerCase()}-${Name.genderToCode(gender)}';
                  final namesRepo = ref.read(namesRepositoryProvider);
                  final existing = await namesRepo.getByIds([id]);
                  if (existing.isEmpty) {
                    await namesRepo.addCustomName(Name(
                      id: id,
                      display: text,
                      gender: gender,
                      isCustom: true,
                    ));
                  }
                  setState(() => _customNameController.clear());
                },
                child: const Text('Add'),
              ),
            ]),
            const SizedBox(height: 24),
            Text('Hard Vetoes (optional)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Names to exclude before ranking begins.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _excludeController,
                  decoration: const InputDecoration(
                    hintText: 'Name to exclude',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () async {
                  final text = _excludeController.text.trim();
                  if (text.isEmpty) return;
                  final namesRepo = ref.read(namesRepositoryProvider);
                  final all =
                      await namesRepo.getForFilter(gender: _genderFilter);
                  final match = all
                      .where((n) =>
                          n.display.toLowerCase() == text.toLowerCase())
                      .toList();
                  if (match.isNotEmpty) {
                    setState(() => _excludeIds.add(match.first.id));
                  } else {
                    final gender = _genderFilter == null
                        ? 'n'
                        : Name.genderToCode(_genderFilter!);
                    setState(() =>
                        _excludeIds.add('${text.toLowerCase()}-$gender'));
                  }
                  _excludeController.clear();
                },
                child: const Text('Exclude'),
              ),
            ]),
            if (_excludeIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _excludeIds
                    .map((id) => Chip(
                          label: Text(_displayFromId(id)),
                          onDeleted: () =>
                              setState(() => _excludeIds.remove(id)),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _startSession,
              child: Text(widget.isPartnerB
                  ? 'Start Partner B Session'
                  : 'Start Ranking'),
            ),
          ],
        ),
      ),
    );
  }
}
