import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class InboxScreen extends StatefulWidget {
  final int? selectedMessageId; // Seçili mesaj ID'si / Selected message ID

  const InboxScreen({super.key, this.selectedMessageId});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  int _selectedMessageIndex =
      -1; // Seçili mesaj indexi / Selected message index

  // Mesaj listesi / Messages list
  final List<Map<String, dynamic>> _messages = [
    {
      'id': 1,
      'subject': 'Öğrenci Belgesi Talebiniz Hakkında',
      'sender': 'Öğrenci İşleri',
      'senderEmail': 'ogrenciisleri@medipol.edu.tr',
      'date': '24.06.2025',
      'time': '14:30',
      'isRead': false,
      'hasAttachment': true,
      'content': '''Sayın Elif Yılmaz,

24.06.2025 tarihinde talepte bulunduğunuz öğrenci belgesi hazırlanmıştır. 

Belgenizi aşağıdaki şekillerde temin edebilirsiniz:
• Öğrenci İşleri ofisimizden şahsen teslim alabilirsiniz
• Kargo ile adresinize göndermek için ek ücret karşılığında başvurabilirsiniz

Ofis saatleri: Pazartesi-Cuma 09:00-17:00

Saygılarımızla,
Öğrenci İşleri Müdürlüğü''',
      'attachments': ['ogrenci_belgesi_2025.pdf'],
    },
    {
      'id': 2,
      'subject': 'Burs Başvuru Sonucu',
      'sender': 'Burs ve Yardım İşleri',
      'senderEmail': 'burs@medipol.edu.tr',
      'date': '22.06.2025',
      'time': '10:15',
      'isRead': false,
      'hasAttachment': false,
      'content': '''Sayın Elif Yılmaz,

2024-2025 Akademik Yılı Başarı Bursu başvurunuz değerlendirilmiş olup, başvurunuzun KABUL edildiğini bildiririz.

Burs Detayları:
• Burs Türü: Başarı Bursu (%25)
• Geçerli Dönem: 2025-2026 Güz Dönemi
• Ödeme Tarihi: Kayıt yenileme sonrası

Burs hakkinizı kullanabilmek için kayıt yenileme işlemlerinizi zamanında tamamlamanız gerekmektedir.

Tebrikler!
Burs ve Yardım İşleri Müdürlüğü''',
      'attachments': [],
    },
    {
      'id': 3,
      'subject': 'Dönem Sonu Sınav Programı',
      'sender': 'Akademik Birim',
      'senderEmail': 'akademik@medipol.edu.tr',
      'date': '20.06.2025',
      'time': '16:45',
      'isRead': true,
      'hasAttachment': true,
      'content': '''Sayın Öğrencimiz,

2024-2025 Bahar Dönemi final sınav programı aşağıdaki gibi belirlenmiştir:

• Visual Programming: 25.06.2025 Çarşamba 09:00-11:00
• Database Management: 27.06.2025 Cuma 14:00-16:00  
• Object Oriented Programming: 30.06.2025 Pazartesi 09:00-11:00

Sınav kuralları:
- Sınavlara 15 dakika geç kalınabilir
- Kimlik belgesi zorunludur
- Elektronik cihazlar sınav salonuna alınamaz

Başarılar dileriz.
Akademik Birim''',
      'attachments': ['sinav_programi_2025_bahar.pdf'],
    },
    {
      'id': 4,
      'subject': 'Kütüphane Kitap İade Hatırlatması',
      'sender': 'Kütüphane',
      'senderEmail': 'kutuphane@medipol.edu.tr',
      'date': '19.06.2025',
      'time': '11:20',
      'isRead': true,
      'hasAttachment': false,
      'content': '''Sayın Elif Yılmaz,

Aşağıda belirtilen kitapların iade tarihi yaklaşmaktadır:

1. "Algorithm Design" - Son İade Tarihi: 28.06.2025
2. "Database Systems" - Son İade Tarihi: 30.06.2025

Kitapları zamanında iade etmediğiniz takdirde ceza ücreti uygulanacaktır.

Online iade yenileme işlemini öğrenci portal üzerinden yapabilirsiniz.

Kütüphane Müdürlüğü''',
      'attachments': [],
    },
    {
      'id': 5,
      'subject': 'Mezuniyet Töreni Davetiyesi',
      'sender': 'Protokol',
      'senderEmail': 'protokol@medipol.edu.tr',
      'date': '15.06.2025',
      'time': '09:30',
      'isRead': true,
      'hasAttachment': true,
      'content': '''Değerli Öğrencimiz,

2025 Yılı Mezuniyet Töreni'ne davet edildiğinizi bildiririz.

Tören Detayları:
• Tarih: 5 Temmuz 2025 Cumartesi
• Saat: 14:00
• Mekan: Medipol Üniversitesi Konferans Salonu
• Davetli Sayısı: Mezun başına 4 kişi

Davetiye için ekteki formu doldurarak protokol birimine iletmeniz gerekmektedir.

Protokol Birimi''',
      'attachments': ['mezuniyet_davetiye_formu.pdf'],
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedMessageId != null) {
      final index = _messages.indexWhere(
        (m) => m['id'] == widget.selectedMessageId,
      );
      if (index != -1) {
        setState(() {
          _selectedMessageIndex = index;
          _messages[index]['isRead'] = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.inbox,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Arama functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // TODO: Yenileme functionality
            },
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Row(
          children: [
            // Sol taraf - Mesaj listesi / Left side - Message list
            Flexible(
              flex: _selectedMessageIndex == -1
                  ? 1
                  : 2, // Seçili değilse tam genişlik, seçiliyse 2/5 oranında / Full width when not selected, 2/5 ratio when selected
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    // Mesaj sayısı ve filtre / Message count and filter
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${_messages.length} ${AppLocalizations.of(context)!.messages}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_messages.where((m) => !m['isRead']).length} ${AppLocalizations.of(context)!.unread}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mesaj listesi / Message list
                    Expanded(
                      child: ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageItem(_messages[index], index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sağ taraf - Mesaj detayı / Right side - Message detail
            if (_selectedMessageIndex != -1)
              Flexible(
                flex: 3, // 3/5 oranında genişlik / 3/5 ratio width
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _buildMessageDetail(_messages[_selectedMessageIndex]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Mesaj öğesi oluştur / Build message item
  Widget _buildMessageItem(Map<String, dynamic> message, int index) {
    final isSelected = _selectedMessageIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMessageIndex = index;
          _messages[index]['isRead'] = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E3A8A).withValues(alpha: 0.1)
              : (message['isRead'] ? Colors.white : Colors.blue[50]),
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
            left: isSelected
                ? const BorderSide(color: Color(0xFF1E3A8A), width: 3)
                : BorderSide.none,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gönderen ve tarih / Sender and date
            Row(
              children: [
                Expanded(
                  child: Text(
                    message['sender'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${message['date']} ${message['time']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Konu / Subject
            Row(
              children: [
                if (!message['isRead'])
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E3A8A),
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(
                    message['subject'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: message['isRead']
                          ? FontWeight.w500
                          : FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (message['hasAttachment'])
                  const Icon(Icons.attach_file, size: 16, color: Colors.grey),
              ],
            ),

            const SizedBox(height: 6),

            // Mesaj önizleme / Message preview
            Text(
              message['content'].split(
                '\n',
              )[0], // İlk satırı göster / Show first line
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Mesaj detay görünümü / Message detail view
  Widget _buildMessageDetail(Map<String, dynamic> message) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Swipe left detection / Sol kaydırma algılama
        if (details.delta.dx < -10) {
          setState(() {
            _selectedMessageIndex = -1;
          });
        }
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Mesaj başlığı / Message header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Geri butonu ve konu / Back button and subject
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedMessageIndex = -1;
                          });
                        },
                        icon: const Icon(Icons.arrow_back),
                        color: const Color(0xFF1E3A8A),
                        tooltip: AppLocalizations.of(context)!.back,
                      ),
                      Expanded(
                        child: Text(
                          message['subject'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Gönderen bilgileri / Sender information
                  Row(
                    children: [
                      // Gönderen avatar / Sender avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            message['sender'][0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Gönderen detayları / Sender details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['sender'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              message['senderEmail'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Tarih ve saat / Date and time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            message['date'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            message['time'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Ek dosyalar / Attachments
                  if (message['hasAttachment'] &&
                      message['attachments'].isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.attach_file,
                                size: 16,
                                color: Color(0xFF1E3A8A),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${AppLocalizations.of(context)!.attachments} (${message['attachments'].length})',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...message['attachments'].map<Widget>((attachment) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      attachment,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF1E3A8A),
                                        decoration: TextDecoration.underline,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.download,
                                    size: 16,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Mesaj içeriği / Message content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  message['content'],
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // Alt butonlar / Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Yanıtla functionality
                    },
                    icon: const Icon(Icons.reply, size: 16),
                    label: Text(AppLocalizations.of(context)!.reply),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: İlet functionality
                    },
                    icon: const Icon(Icons.forward, size: 16),
                    label: Text(AppLocalizations.of(context)!.forward),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E3A8A),
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Sil functionality
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red[600],
                    tooltip: AppLocalizations.of(context)!.delete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
