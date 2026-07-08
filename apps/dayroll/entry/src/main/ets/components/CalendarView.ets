import { intl } from '@kit.LocalizationKit'
import { SunColor, SunSpacing } from 'sunpebble_ui'

// 与 Index 同构，局部复制避免新建共享类型文件
interface RollEntry {
  date: string
  mood: string
  line: string
}

@ComponentV2
export struct CalendarView {
  @Param entries: RollEntry[] = []
  @Param calMonth: string = ''
  @Event onMonthChange: (month: string) => void = () => {}
  @Event onPickDay: (dateKey: string) => void = () => {}

  private moods: string[] = ['😄', '🙂', '😐', '😞', '😣']

  private pad(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  private year(): number {
    return Number(this.calMonth.split('-')[0])
  }

  private month0(): number {
    return Number(this.calMonth.split('-')[1]) - 1
  }

  private todayKey(): string {
    const d = new Date()
    return `${d.getFullYear()}-${this.pad(d.getMonth() + 1)}-${this.pad(d.getDate())}`
  }

  private mondayStart(): boolean {
    return new intl.Locale().toString().toLowerCase().startsWith('zh')
  }

  private daysInMonth(): number {
    return new Date(this.year(), this.month0() + 1, 0).getDate()
  }

  private leadBlanks(): number {
    const firstDow = new Date(this.year(), this.month0(), 1).getDay() // 0=Sun..6=Sat
    return this.mondayStart() ? (firstDow + 6) % 7 : firstDow
  }

  // 42 格（6 周）：前导空 + 1..daysInMonth + 末尾空，空用 '' 占位
  private cells(): string[] {
    const out: string[] = []
    const lead = this.leadBlanks()
    for (let i = 0; i < lead; i++) {
      out.push('')
    }
    const total = this.daysInMonth()
    for (let d = 1; d <= total; d++) {
      out.push(`${this.year()}-${this.pad(this.month0() + 1)}-${this.pad(d)}`)
    }
    while (out.length % 7 !== 0) {
      out.push('')
    }
    return out
  }

  private weekdayLabels(): string[] {
    const fmt = new intl.DateTimeFormat(new intl.Locale().toString(),
      { weekday: 'narrow' } as intl.DateTimeOptions)
    // 2024-01-07 是周日、2024-01-08 是周一
    const base = this.mondayStart() ? 8 : 7
    const labels: string[] = []
    for (let i = 0; i < 7; i++) {
      labels.push(fmt.format(new Date(2024, 0, base + i)))
    }
    return labels
  }

  private moodFor(dayKey: string): string {
    const e = this.entries.find((x: RollEntry) => x.date === dayKey)
    return e && this.moods.includes(e.mood) ? e.mood : ''
  }

  private hasEntry(dayKey: string): boolean {
    return this.entries.some((x: RollEntry) => x.date === dayKey)
  }

  private isFuture(dayKey: string): boolean {
    return dayKey.localeCompare(this.todayKey()) > 0
  }

  private shiftMonth(delta: number): void {
    const d = new Date(this.year(), this.month0() + delta, 1)
    this.onMonthChange(`${d.getFullYear()}-${this.pad(d.getMonth() + 1)}`)
  }

  private monthTitle(): string {
    const fmt = new intl.DateTimeFormat(new intl.Locale().toString(),
      { year: 'numeric', month: 'long' } as intl.DateTimeOptions)
    return fmt.format(new Date(this.year(), this.month0(), 1))
  }

  @Builder
  private navButton(glyph: string, delta: number) {
    Button(glyph)
      .width(36).height(36).borderRadius(999)
      .backgroundColor('#F5EBD9').fontColor(SunColor.ink)
      .fontSize(18).fontWeight(FontWeight.Bold)
      .onClick(() => this.shiftMonth(delta))
  }

  @Builder
  private dayCell(key: string) {
    Column() {
      if (key.length === 0) {
        Text('')
      } else if (this.moodFor(key).length > 0) {
        Text(this.moodFor(key)).fontSize(18).lineHeight(22)
      } else {
        Text(key.slice(8))
          .fontSize(12)
          .fontColor(this.isFuture(key) ? '#D8CCBA' : SunColor.pebble)
      }
    }
    .width('100%').aspectRatio(1)
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .borderRadius(8)
    .borderWidth(key === this.todayKey() ? 2 : 0)
    .borderColor(SunColor.ink)
    .backgroundColor(this.hasEntry(key) ? '#F5EBD9' : Color.Transparent)
    .onClick(() => {
      if (key.length > 0 && !this.isFuture(key)) {
        this.onPickDay(key)
      }
    })
  }

  build() {
    Column({ space: SunSpacing.md }) {
      Row() {
        this.navButton('‹', -1)
        Text(this.monthTitle())
          .fontSize(15).fontWeight(FontWeight.Bold).letterSpacing(1)
          .fontColor(SunColor.ink).layoutWeight(1).textAlign(TextAlign.Center)
        this.navButton('›', 1)
      }
      .width('100%').alignItems(VerticalAlign.Center)

      Row() {
        ForEach(this.weekdayLabels(), (w: string, i: number) => {
          Text(w)
            .fontSize(10).fontWeight(FontWeight.Bold).fontColor(SunColor.pebble)
            .layoutWeight(1).textAlign(TextAlign.Center)
        }, (w: string, i: number) => `${i}`)
      }
      .width('100%')

      Grid() {
        ForEach(this.cells(), (key: string, i: number) => {
          GridItem() { this.dayCell(key) }
        }, (key: string, i: number) => `${this.calMonth}-${i}`)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .columnsGap(4).rowsGap(4)
      .width('100%')
    }
    .width('100%').alignItems(HorizontalAlign.Start)
    .padding({ left: 20, right: 20, top: SunSpacing.md, bottom: 40 })
    .backgroundColor('#FFFDF7')
  }
}
