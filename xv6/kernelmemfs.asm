
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr  
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr  

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 80 fa 30 80       	mov    $0x8030fa80,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 4d 33 10 80       	mov    $0x8010334d,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 40 a9 10 80       	push   $0x8010a940
80100074:	68 00 40 30 80       	push   $0x80304000
80100079:	e8 38 4b 00 00       	call   80104bb6 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 87 30 80 fc 	movl   $0x803086fc,0x8030874c
80100088:	86 30 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 87 30 80 fc 	movl   $0x803086fc,0x80308750
80100092:	86 30 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 40 30 80 	movl   $0x80304034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 87 30 80    	mov    0x80308750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 86 30 80 	movl   $0x803086fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 47 a9 10 80       	push   $0x8010a947
801000c2:	50                   	push   %eax
801000c3:	e8 91 49 00 00       	call   80104a59 <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 87 30 80       	mov    0x80308750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 87 30 80       	mov    %eax,0x80308750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 86 30 80       	mov    $0x803086fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave  
801000f2:	c3                   	ret    

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 40 30 80       	push   $0x80304000
80100101:	e8 d2 4a 00 00       	call   80104bd8 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 87 30 80       	mov    0x80308750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 40 30 80       	push   $0x80304000
80100140:	e8 01 4b 00 00       	call   80104c46 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 3e 49 00 00       	call   80104a95 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 86 30 80 	cmpl   $0x803086fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 87 30 80       	mov    0x8030874c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 40 30 80       	push   $0x80304000
801001c1:	e8 80 4a 00 00       	call   80104c46 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 bd 48 00 00       	call   80104a95 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 86 30 80 	cmpl   $0x803086fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 4e a9 10 80       	push   $0x8010a94e
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave  
80100200:	c3                   	ret    

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 12 a6 00 00       	call   8010a844 <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave  
80100239:	c3                   	ret    

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 f8 48 00 00       	call   80104b47 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 5f a9 10 80       	push   $0x8010a95f
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 c7 a5 00 00       	call   8010a844 <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave  
80100282:	c3                   	ret    

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 af 48 00 00       	call   80104b47 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 66 a9 10 80       	push   $0x8010a966
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 3e 48 00 00       	call   80104af9 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 40 30 80       	push   $0x80304000
801002c6:	e8 0d 49 00 00       	call   80104bd8 <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 87 30 80    	mov    0x80308750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 86 30 80 	movl   $0x803086fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 87 30 80       	mov    0x80308750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 87 30 80       	mov    %eax,0x80308750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 40 30 80       	push   $0x80304000
80100336:	e8 0b 49 00 00       	call   80104c46 <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave  
80100340:	c3                   	ret    

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli    
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret    

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8c 03 00 00       	call   8010076f <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave  
801003f3:	c3                   	ret    

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 8a 30 80       	mov    0x80308a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 8a 30 80       	push   $0x80308a00
80100410:	e8 c3 47 00 00       	call   80104bd8 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 6d a9 10 80       	push   $0x8010a96d
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 20 03 00 00       	call   8010076f <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec 76 a9 10 80 	movl   $0x8010a976,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 44 02 00 00       	call   8010076f <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 27 02 00 00       	call   8010076f <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 18 02 00 00       	call   8010076f <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 0a 02 00 00       	call   8010076f <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 8a 30 80       	push   $0x80308a00
8010059e:	e8 a3 46 00 00       	call   80104c46 <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave  
801005a8:	c3                   	ret    

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 8a 30 80 00 	movl   $0x0,0x80308a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 1f 25 00 00       	call   80102ae2 <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 7d a9 10 80       	push   $0x8010a97d
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 91 a9 10 80       	push   $0x8010a991
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 95 46 00 00       	call   80104c98 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 93 a9 10 80       	push   $0x8010a993
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 89 30 80 01 	movl   $0x1,0x803089ec
80100638:	00 00 00 
  for(;;)
8010063b:	eb fe                	jmp    8010063b <panic+0x92>

8010063d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063d:	55                   	push   %ebp
8010063e:	89 e5                	mov    %esp,%ebp
80100640:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100643:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100647:	75 64                	jne    801006ad <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100649:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010064f:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100654:	89 c8                	mov    %ecx,%eax
80100656:	f7 ea                	imul   %edx
80100658:	89 d0                	mov    %edx,%eax
8010065a:	c1 f8 04             	sar    $0x4,%eax
8010065d:	89 ca                	mov    %ecx,%edx
8010065f:	c1 fa 1f             	sar    $0x1f,%edx
80100662:	29 d0                	sub    %edx,%eax
80100664:	6b d0 35             	imul   $0x35,%eax,%edx
80100667:	89 c8                	mov    %ecx,%eax
80100669:	29 d0                	sub    %edx,%eax
8010066b:	ba 35 00 00 00       	mov    $0x35,%edx
80100670:	29 c2                	sub    %eax,%edx
80100672:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100677:	01 d0                	add    %edx,%eax
80100679:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100683:	3d 23 04 00 00       	cmp    $0x423,%eax
80100688:	0f 8e de 00 00 00    	jle    8010076c <graphic_putc+0x12f>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100693:	83 e8 35             	sub    $0x35,%eax
80100696:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069b:	83 ec 0c             	sub    $0xc,%esp
8010069e:	6a 1e                	push   $0x1e
801006a0:	e8 f6 80 00 00       	call   8010879b <graphic_scroll_up>
801006a5:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a8:	e9 bf 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
  }else if(c == BACKSPACE){
801006ad:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b4:	75 1f                	jne    801006d5 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bb:	85 c0                	test   %eax,%eax
801006bd:	0f 8e a9 00 00 00    	jle    8010076c <graphic_putc+0x12f>
801006c3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c8:	83 e8 01             	sub    $0x1,%eax
801006cb:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d0:	e9 97 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d5:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006da:	3d 23 04 00 00       	cmp    $0x423,%eax
801006df:	7e 1a                	jle    801006fb <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e1:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e6:	83 e8 35             	sub    $0x35,%eax
801006e9:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ee:	83 ec 0c             	sub    $0xc,%esp
801006f1:	6a 1e                	push   $0x1e
801006f3:	e8 a3 80 00 00       	call   8010879b <graphic_scroll_up>
801006f8:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fb:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100701:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100706:	89 c8                	mov    %ecx,%eax
80100708:	f7 ea                	imul   %edx
8010070a:	89 d0                	mov    %edx,%eax
8010070c:	c1 f8 04             	sar    $0x4,%eax
8010070f:	89 ca                	mov    %ecx,%edx
80100711:	c1 fa 1f             	sar    $0x1f,%edx
80100714:	29 d0                	sub    %edx,%eax
80100716:	6b d0 35             	imul   $0x35,%eax,%edx
80100719:	89 c8                	mov    %ecx,%eax
8010071b:	29 d0                	sub    %edx,%eax
8010071d:	89 c2                	mov    %eax,%edx
8010071f:	c1 e2 04             	shl    $0x4,%edx
80100722:	29 c2                	sub    %eax,%edx
80100724:	8d 42 02             	lea    0x2(%edx),%eax
80100727:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100730:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100735:	89 c8                	mov    %ecx,%eax
80100737:	f7 ea                	imul   %edx
80100739:	89 d0                	mov    %edx,%eax
8010073b:	c1 f8 04             	sar    $0x4,%eax
8010073e:	c1 f9 1f             	sar    $0x1f,%ecx
80100741:	89 ca                	mov    %ecx,%edx
80100743:	29 d0                	sub    %edx,%eax
80100745:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074b:	83 ec 04             	sub    $0x4,%esp
8010074e:	ff 75 08             	push   0x8(%ebp)
80100751:	ff 75 f0             	push   -0x10(%ebp)
80100754:	ff 75 f4             	push   -0xc(%ebp)
80100757:	e8 aa 80 00 00       	call   80108806 <font_render>
8010075c:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100764:	83 c0 01             	add    $0x1,%eax
80100767:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076c:	90                   	nop
8010076d:	c9                   	leave  
8010076e:	c3                   	ret    

8010076f <consputc>:


void
consputc(int c)
{
8010076f:	55                   	push   %ebp
80100770:	89 e5                	mov    %esp,%ebp
80100772:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100775:	a1 ec 89 30 80       	mov    0x803089ec,%eax
8010077a:	85 c0                	test   %eax,%eax
8010077c:	74 07                	je     80100785 <consputc+0x16>
    cli();
8010077e:	e8 be fb ff ff       	call   80100341 <cli>
    for(;;)
80100783:	eb fe                	jmp    80100783 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 ae 64 00 00       	call   80106c46 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 a1 64 00 00       	call   80106c46 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 94 64 00 00       	call   80106c46 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 84 64 00 00       	call   80106c46 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6d fe ff ff       	call   8010063d <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave  
801007d5:	c3                   	ret    

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 8a 30 80       	push   $0x80308a00
801007eb:	e8 e8 43 00 00       	call   80104bd8 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 50 01 00 00       	jmp    80100948 <consoleintr+0x172>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 10 01 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 89 30 80       	mov    0x803089e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 89 30 80       	mov    %eax,0x803089e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 89 30 80    	mov    0x803089e8,%edx
8010085b:	a1 e4 89 30 80       	mov    0x803089e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 89 30 80       	mov    0x803089e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 89 30 80 	movzbl -0x7fcf76a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 89 30 80    	mov    0x803089e8,%edx
80100889:	a1 e4 89 30 80       	mov    0x803089e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 89 30 80       	mov    0x803089e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 89 30 80       	mov    %eax,0x803089e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 bf fe ff ff       	call   8010076f <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 90 00 00 00       	jmp    80100948 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 85 00 00 00    	je     80100947 <consoleintr+0x171>
801008c2:	a1 e8 89 30 80       	mov    0x803089e8,%eax
801008c7:	8b 15 e0 89 30 80    	mov    0x803089e0,%edx
801008cd:	29 d0                	sub    %edx,%eax
801008cf:	83 f8 7f             	cmp    $0x7f,%eax
801008d2:	77 73                	ja     80100947 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 89 30 80       	mov    0x803089e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 89 30 80    	mov    %edx,0x803089e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 89 30 80    	mov    %dl,-0x7fcf76a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 63 fe ff ff       	call   8010076f <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	a1 e8 89 30 80       	mov    0x803089e8,%eax
80100920:	8b 15 e0 89 30 80    	mov    0x803089e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 89 30 80       	mov    0x803089e8,%eax
80100932:	a3 e4 89 30 80       	mov    %eax,0x803089e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 89 30 80       	push   $0x803089e0
8010093f:	e8 24 3f 00 00       	call   80104868 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	90                   	nop
  while((c = getc()) >= 0){
80100948:	8b 45 08             	mov    0x8(%ebp),%eax
8010094b:	ff d0                	call   *%eax
8010094d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100954:	0f 89 9e fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010095a:	83 ec 0c             	sub    $0xc,%esp
8010095d:	68 00 8a 30 80       	push   $0x80308a00
80100962:	e8 df 42 00 00       	call   80104c46 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 b1 3f 00 00       	call   80104926 <procdump>
  }
}
80100975:	90                   	nop
80100976:	c9                   	leave  
80100977:	c3                   	ret    

80100978 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100978:	55                   	push   %ebp
80100979:	89 e5                	mov    %esp,%ebp
8010097b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010097e:	83 ec 0c             	sub    $0xc,%esp
80100981:	ff 75 08             	push   0x8(%ebp)
80100984:	e8 5c 11 00 00       	call   80101ae5 <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 8a 30 80       	push   $0x80308a00
8010099a:	e8 39 42 00 00       	call   80104bd8 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 6c 30 00 00       	call   80103a18 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 8a 30 80       	push   $0x80308a00
801009bb:	e8 86 42 00 00       	call   80104c46 <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 04 10 00 00       	call   801019d2 <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 8a 30 80       	push   $0x80308a00
801009e3:	68 e0 89 30 80       	push   $0x803089e0
801009e8:	e8 91 3d 00 00       	call   8010477e <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 89 30 80    	mov    0x803089e0,%edx
801009f6:	a1 e4 89 30 80       	mov    0x803089e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 89 30 80       	mov    0x803089e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 89 30 80    	mov    %edx,0x803089e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 89 30 80 	movzbl -0x7fcf76a0(%eax),%eax
80100a17:	0f be c0             	movsbl %al,%eax
80100a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a1d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a21:	75 17                	jne    80100a3a <consoleread+0xc2>
      if(n < target){
80100a23:	8b 45 10             	mov    0x10(%ebp),%eax
80100a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a29:	76 2f                	jbe    80100a5a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a2b:	a1 e0 89 30 80       	mov    0x803089e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 89 30 80       	mov    %eax,0x803089e0
      }
      break;
80100a38:	eb 20                	jmp    80100a5a <consoleread+0xe2>
    }
    *dst++ = c;
80100a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a3d:	8d 50 01             	lea    0x1(%eax),%edx
80100a40:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a46:	88 10                	mov    %dl,(%eax)
    --n;
80100a48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a4c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a50:	74 0b                	je     80100a5d <consoleread+0xe5>
  while(n > 0){
80100a52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a56:	7f 98                	jg     801009f0 <consoleread+0x78>
80100a58:	eb 04                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5a:	90                   	nop
80100a5b:	eb 01                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5d:	90                   	nop
  }
  release(&cons.lock);
80100a5e:	83 ec 0c             	sub    $0xc,%esp
80100a61:	68 00 8a 30 80       	push   $0x80308a00
80100a66:	e8 db 41 00 00       	call   80104c46 <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 59 0f 00 00       	call   801019d2 <ilock>
80100a79:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a7c:	8b 55 10             	mov    0x10(%ebp),%edx
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	29 d0                	sub    %edx,%eax
}
80100a84:	c9                   	leave  
80100a85:	c3                   	ret    

80100a86 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a86:	55                   	push   %ebp
80100a87:	89 e5                	mov    %esp,%ebp
80100a89:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a8c:	83 ec 0c             	sub    $0xc,%esp
80100a8f:	ff 75 08             	push   0x8(%ebp)
80100a92:	e8 4e 10 00 00       	call   80101ae5 <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 8a 30 80       	push   $0x80308a00
80100aa2:	e8 31 41 00 00       	call   80104bd8 <acquire>
80100aa7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ab1:	eb 21                	jmp    80100ad4 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab9:	01 d0                	add    %edx,%eax
80100abb:	0f b6 00             	movzbl (%eax),%eax
80100abe:	0f be c0             	movsbl %al,%eax
80100ac1:	0f b6 c0             	movzbl %al,%eax
80100ac4:	83 ec 0c             	sub    $0xc,%esp
80100ac7:	50                   	push   %eax
80100ac8:	e8 a2 fc ff ff       	call   8010076f <consputc>
80100acd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ad0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ad7:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ada:	7c d7                	jl     80100ab3 <consolewrite+0x2d>
  release(&cons.lock);
80100adc:	83 ec 0c             	sub    $0xc,%esp
80100adf:	68 00 8a 30 80       	push   $0x80308a00
80100ae4:	e8 5d 41 00 00       	call   80104c46 <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 db 0e 00 00       	call   801019d2 <ilock>
80100af7:	83 c4 10             	add    $0x10,%esp

  return n;
80100afa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consoleinit>:

void
consoleinit(void)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b05:	c7 05 ec 89 30 80 00 	movl   $0x0,0x803089ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 97 a9 10 80       	push   $0x8010a997
80100b17:	68 00 8a 30 80       	push   $0x80308a00
80100b1c:	e8 95 40 00 00       	call   80104bb6 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 8a 30 80 86 	movl   $0x80100a86,0x80308a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 8a 30 80 78 	movl   $0x80100978,0x80308a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 9f a9 10 80 	movl   $0x8010a99f,-0xc(%ebp)
80100b3f:	eb 19                	jmp    80100b5a <consoleinit+0x5b>
    graphic_putc(*p);
80100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b44:	0f b6 00             	movzbl (%eax),%eax
80100b47:	0f be c0             	movsbl %al,%eax
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	50                   	push   %eax
80100b4e:	e8 ea fa ff ff       	call   8010063d <graphic_putc>
80100b53:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b5d:	0f b6 00             	movzbl (%eax),%eax
80100b60:	84 c0                	test   %al,%al
80100b62:	75 dd                	jne    80100b41 <consoleinit+0x42>
  
  cons.locking = 1;
80100b64:	c7 05 34 8a 30 80 01 	movl   $0x1,0x80308a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 9c 1a 00 00       	call   80102616 <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#define GUARD_SIZE (8*PGSIZE)
#define USERSTACKTOP (KERNBASE - GUARD_SIZE)

int
exec(char *path, char **argv)
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 8a 2e 00 00       	call   80103a18 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 8e 24 00 00       	call   80103024 <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 64 19 00 00       	call   80102505 <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 fe 24 00 00       	call   801030b0 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 b5 a9 10 80       	push   $0x8010a9b5
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 d9 03 00 00       	jmp    80100fa5 <exec+0x425>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 fb 0d 00 00       	call   801019d2 <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 ca 12 00 00       	call   80101ebe <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 4e 03 00 00    	jne    80100f4e <exec+0x3ce>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 40 03 00 00    	jne    80100f51 <exec+0x3d1>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 2c 70 00 00       	call   80107c42 <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 31 03 00 00    	je     80100f54 <exec+0x3d4>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 6a 12 00 00       	call   80101ebe <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 f7 02 00 00    	jne    80100f57 <exec+0x3d7>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c75:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 d7 02 00 00    	jb     80100f5a <exec+0x3da>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 be 02 00 00    	jb     80100f5d <exec+0x3dd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 7f 73 00 00       	call   8010803b <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 94 02 00 00    	je     80100f60 <exec+0x3e0>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 84 02 00 00    	jne    80100f63 <exec+0x3e3>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100ce5:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ceb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 6c 72 00 00       	call   80107f6e <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 59 02 00 00    	js     80100f66 <exec+0x3e6>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 c8 0e 00 00       	call   80101c03 <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 6d 23 00 00       	call   801030b0 <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  //   goto bad;
  // sp = USERSTACKTOP;
  // if (allocuvm(pgdir, sp - PGSIZE, sp) == 0)
  //   goto bad;

  sz = KERNBASE - 1;
80100d4a:	c7 45 e0 ff ff ff 7f 	movl   $0x7fffffff,-0x20(%ebp)
  if((sz=allocuvm(pgdir, sz - PGSIZE, sz)) == 0)
80100d51:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d54:	2d 00 10 00 00       	sub    $0x1000,%eax
80100d59:	83 ec 04             	sub    $0x4,%esp
80100d5c:	ff 75 e0             	push   -0x20(%ebp)
80100d5f:	50                   	push   %eax
80100d60:	ff 75 d4             	push   -0x2c(%ebp)
80100d63:	e8 d3 72 00 00       	call   8010803b <allocuvm>
80100d68:	83 c4 10             	add    $0x10,%esp
80100d6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d6e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d72:	0f 84 f1 01 00 00    	je     80100f69 <exec+0x3e9>
    goto bad;
  sz = PGROUNDDOWN(0x3000);
80100d78:	c7 45 e0 00 30 00 00 	movl   $0x3000,-0x20(%ebp)
  sp = KERNBASE - 1;
80100d7f:	c7 45 dc ff ff ff 7f 	movl   $0x7fffffff,-0x24(%ebp)
  
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d86:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d8d:	e9 96 00 00 00       	jmp    80100e28 <exec+0x2a8>
    if(argc >= MAXARG)
80100d92:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d96:	0f 87 d0 01 00 00    	ja     80100f6c <exec+0x3ec>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d9f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100da6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100da9:	01 d0                	add    %edx,%eax
80100dab:	8b 00                	mov    (%eax),%eax
80100dad:	83 ec 0c             	sub    $0xc,%esp
80100db0:	50                   	push   %eax
80100db1:	e8 e6 42 00 00       	call   8010509c <strlen>
80100db6:	83 c4 10             	add    $0x10,%esp
80100db9:	89 c2                	mov    %eax,%edx
80100dbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dbe:	29 d0                	sub    %edx,%eax
80100dc0:	83 e8 01             	sub    $0x1,%eax
80100dc3:	83 e0 fc             	and    $0xfffffffc,%eax
80100dc6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100dc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dd6:	01 d0                	add    %edx,%eax
80100dd8:	8b 00                	mov    (%eax),%eax
80100dda:	83 ec 0c             	sub    $0xc,%esp
80100ddd:	50                   	push   %eax
80100dde:	e8 b9 42 00 00       	call   8010509c <strlen>
80100de3:	83 c4 10             	add    $0x10,%esp
80100de6:	83 c0 01             	add    $0x1,%eax
80100de9:	89 c2                	mov    %eax,%edx
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df8:	01 c8                	add    %ecx,%eax
80100dfa:	8b 00                	mov    (%eax),%eax
80100dfc:	52                   	push   %edx
80100dfd:	50                   	push   %eax
80100dfe:	ff 75 dc             	push   -0x24(%ebp)
80100e01:	ff 75 d4             	push   -0x2c(%ebp)
80100e04:	e8 ff 75 00 00       	call   80108408 <copyout>
80100e09:	83 c4 10             	add    $0x10,%esp
80100e0c:	85 c0                	test   %eax,%eax
80100e0e:	0f 88 5b 01 00 00    	js     80100f6f <exec+0x3ef>
      goto bad;
    ustack[3+argc] = sp;
80100e14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e17:	8d 50 03             	lea    0x3(%eax),%edx
80100e1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e1d:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e24:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e32:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e35:	01 d0                	add    %edx,%eax
80100e37:	8b 00                	mov    (%eax),%eax
80100e39:	85 c0                	test   %eax,%eax
80100e3b:	0f 85 51 ff ff ff    	jne    80100d92 <exec+0x212>
  }
  ustack[3+argc] = 0;
80100e41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e44:	83 c0 03             	add    $0x3,%eax
80100e47:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e4e:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e52:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e59:	ff ff ff 
  ustack[1] = argc;
80100e5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5f:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e68:	83 c0 01             	add    $0x1,%eax
80100e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e72:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e75:	29 d0                	sub    %edx,%eax
80100e77:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 04             	add    $0x4,%eax
80100e83:	c1 e0 02             	shl    $0x2,%eax
80100e86:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8c:	83 c0 04             	add    $0x4,%eax
80100e8f:	c1 e0 02             	shl    $0x2,%eax
80100e92:	50                   	push   %eax
80100e93:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100e99:	50                   	push   %eax
80100e9a:	ff 75 dc             	push   -0x24(%ebp)
80100e9d:	ff 75 d4             	push   -0x2c(%ebp)
80100ea0:	e8 63 75 00 00       	call   80108408 <copyout>
80100ea5:	83 c4 10             	add    $0x10,%esp
80100ea8:	85 c0                	test   %eax,%eax
80100eaa:	0f 88 c2 00 00 00    	js     80100f72 <exec+0x3f2>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80100eb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ebc:	eb 17                	jmp    80100ed5 <exec+0x355>
    if(*s == '/')
80100ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ec1:	0f b6 00             	movzbl (%eax),%eax
80100ec4:	3c 2f                	cmp    $0x2f,%al
80100ec6:	75 09                	jne    80100ed1 <exec+0x351>
      last = s+1;
80100ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ecb:	83 c0 01             	add    $0x1,%eax
80100ece:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ed1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed8:	0f b6 00             	movzbl (%eax),%eax
80100edb:	84 c0                	test   %al,%al
80100edd:	75 df                	jne    80100ebe <exec+0x33e>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100edf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ee2:	83 c0 6c             	add    $0x6c,%eax
80100ee5:	83 ec 04             	sub    $0x4,%esp
80100ee8:	6a 10                	push   $0x10
80100eea:	ff 75 f0             	push   -0x10(%ebp)
80100eed:	50                   	push   %eax
80100eee:	e8 5e 41 00 00       	call   80105051 <safestrcpy>
80100ef3:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100ef6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ef9:	8b 40 04             	mov    0x4(%eax),%eax
80100efc:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100eff:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f02:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f05:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f08:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f0b:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f0e:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f10:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f13:	8b 40 18             	mov    0x18(%eax),%eax
80100f16:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f1c:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f1f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f22:	8b 40 18             	mov    0x18(%eax),%eax
80100f25:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f28:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f2b:	83 ec 0c             	sub    $0xc,%esp
80100f2e:	ff 75 d0             	push   -0x30(%ebp)
80100f31:	e8 29 6e 00 00       	call   80107d5f <switchuvm>
80100f36:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f39:	83 ec 0c             	sub    $0xc,%esp
80100f3c:	ff 75 cc             	push   -0x34(%ebp)
80100f3f:	e8 a1 72 00 00       	call   801081e5 <freevm>
80100f44:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f47:	b8 00 00 00 00       	mov    $0x0,%eax
80100f4c:	eb 57                	jmp    80100fa5 <exec+0x425>
    goto bad;
80100f4e:	90                   	nop
80100f4f:	eb 22                	jmp    80100f73 <exec+0x3f3>
    goto bad;
80100f51:	90                   	nop
80100f52:	eb 1f                	jmp    80100f73 <exec+0x3f3>
    goto bad;
80100f54:	90                   	nop
80100f55:	eb 1c                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f57:	90                   	nop
80100f58:	eb 19                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f5a:	90                   	nop
80100f5b:	eb 16                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f5d:	90                   	nop
80100f5e:	eb 13                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f60:	90                   	nop
80100f61:	eb 10                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f63:	90                   	nop
80100f64:	eb 0d                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f66:	90                   	nop
80100f67:	eb 0a                	jmp    80100f73 <exec+0x3f3>
    goto bad;
80100f69:	90                   	nop
80100f6a:	eb 07                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 04                	jmp    80100f73 <exec+0x3f3>
      goto bad;
80100f6f:	90                   	nop
80100f70:	eb 01                	jmp    80100f73 <exec+0x3f3>
    goto bad;
80100f72:	90                   	nop

 bad:
  if(pgdir)
80100f73:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f77:	74 0e                	je     80100f87 <exec+0x407>
    freevm(pgdir);
80100f79:	83 ec 0c             	sub    $0xc,%esp
80100f7c:	ff 75 d4             	push   -0x2c(%ebp)
80100f7f:	e8 61 72 00 00       	call   801081e5 <freevm>
80100f84:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f87:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f8b:	74 13                	je     80100fa0 <exec+0x420>
    iunlockput(ip);
80100f8d:	83 ec 0c             	sub    $0xc,%esp
80100f90:	ff 75 d8             	push   -0x28(%ebp)
80100f93:	e8 6b 0c 00 00       	call   80101c03 <iunlockput>
80100f98:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f9b:	e8 10 21 00 00       	call   801030b0 <end_op>
  }
  return -1;
80100fa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fa5:	c9                   	leave  
80100fa6:	c3                   	ret    

80100fa7 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fa7:	55                   	push   %ebp
80100fa8:	89 e5                	mov    %esp,%ebp
80100faa:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fad:	83 ec 08             	sub    $0x8,%esp
80100fb0:	68 c1 a9 10 80       	push   $0x8010a9c1
80100fb5:	68 a0 8a 30 80       	push   $0x80308aa0
80100fba:	e8 f7 3b 00 00       	call   80104bb6 <initlock>
80100fbf:	83 c4 10             	add    $0x10,%esp
}
80100fc2:	90                   	nop
80100fc3:	c9                   	leave  
80100fc4:	c3                   	ret    

80100fc5 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fc5:	55                   	push   %ebp
80100fc6:	89 e5                	mov    %esp,%ebp
80100fc8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fcb:	83 ec 0c             	sub    $0xc,%esp
80100fce:	68 a0 8a 30 80       	push   $0x80308aa0
80100fd3:	e8 00 3c 00 00       	call   80104bd8 <acquire>
80100fd8:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fdb:	c7 45 f4 d4 8a 30 80 	movl   $0x80308ad4,-0xc(%ebp)
80100fe2:	eb 2d                	jmp    80101011 <filealloc+0x4c>
    if(f->ref == 0){
80100fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe7:	8b 40 04             	mov    0x4(%eax),%eax
80100fea:	85 c0                	test   %eax,%eax
80100fec:	75 1f                	jne    8010100d <filealloc+0x48>
      f->ref = 1;
80100fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ff1:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100ff8:	83 ec 0c             	sub    $0xc,%esp
80100ffb:	68 a0 8a 30 80       	push   $0x80308aa0
80101000:	e8 41 3c 00 00       	call   80104c46 <release>
80101005:	83 c4 10             	add    $0x10,%esp
      return f;
80101008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100b:	eb 23                	jmp    80101030 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010100d:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101011:	b8 34 94 30 80       	mov    $0x80309434,%eax
80101016:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101019:	72 c9                	jb     80100fe4 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010101b:	83 ec 0c             	sub    $0xc,%esp
8010101e:	68 a0 8a 30 80       	push   $0x80308aa0
80101023:	e8 1e 3c 00 00       	call   80104c46 <release>
80101028:	83 c4 10             	add    $0x10,%esp
  return 0;
8010102b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101030:	c9                   	leave  
80101031:	c3                   	ret    

80101032 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101032:	55                   	push   %ebp
80101033:	89 e5                	mov    %esp,%ebp
80101035:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101038:	83 ec 0c             	sub    $0xc,%esp
8010103b:	68 a0 8a 30 80       	push   $0x80308aa0
80101040:	e8 93 3b 00 00       	call   80104bd8 <acquire>
80101045:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101048:	8b 45 08             	mov    0x8(%ebp),%eax
8010104b:	8b 40 04             	mov    0x4(%eax),%eax
8010104e:	85 c0                	test   %eax,%eax
80101050:	7f 0d                	jg     8010105f <filedup+0x2d>
    panic("filedup");
80101052:	83 ec 0c             	sub    $0xc,%esp
80101055:	68 c8 a9 10 80       	push   $0x8010a9c8
8010105a:	e8 4a f5 ff ff       	call   801005a9 <panic>
  f->ref++;
8010105f:	8b 45 08             	mov    0x8(%ebp),%eax
80101062:	8b 40 04             	mov    0x4(%eax),%eax
80101065:	8d 50 01             	lea    0x1(%eax),%edx
80101068:	8b 45 08             	mov    0x8(%ebp),%eax
8010106b:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010106e:	83 ec 0c             	sub    $0xc,%esp
80101071:	68 a0 8a 30 80       	push   $0x80308aa0
80101076:	e8 cb 3b 00 00       	call   80104c46 <release>
8010107b:	83 c4 10             	add    $0x10,%esp
  return f;
8010107e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101081:	c9                   	leave  
80101082:	c3                   	ret    

80101083 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101083:	55                   	push   %ebp
80101084:	89 e5                	mov    %esp,%ebp
80101086:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101089:	83 ec 0c             	sub    $0xc,%esp
8010108c:	68 a0 8a 30 80       	push   $0x80308aa0
80101091:	e8 42 3b 00 00       	call   80104bd8 <acquire>
80101096:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101099:	8b 45 08             	mov    0x8(%ebp),%eax
8010109c:	8b 40 04             	mov    0x4(%eax),%eax
8010109f:	85 c0                	test   %eax,%eax
801010a1:	7f 0d                	jg     801010b0 <fileclose+0x2d>
    panic("fileclose");
801010a3:	83 ec 0c             	sub    $0xc,%esp
801010a6:	68 d0 a9 10 80       	push   $0x8010a9d0
801010ab:	e8 f9 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010b0:	8b 45 08             	mov    0x8(%ebp),%eax
801010b3:	8b 40 04             	mov    0x4(%eax),%eax
801010b6:	8d 50 ff             	lea    -0x1(%eax),%edx
801010b9:	8b 45 08             	mov    0x8(%ebp),%eax
801010bc:	89 50 04             	mov    %edx,0x4(%eax)
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	8b 40 04             	mov    0x4(%eax),%eax
801010c5:	85 c0                	test   %eax,%eax
801010c7:	7e 15                	jle    801010de <fileclose+0x5b>
    release(&ftable.lock);
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	68 a0 8a 30 80       	push   $0x80308aa0
801010d1:	e8 70 3b 00 00       	call   80104c46 <release>
801010d6:	83 c4 10             	add    $0x10,%esp
801010d9:	e9 8b 00 00 00       	jmp    80101169 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010de:	8b 45 08             	mov    0x8(%ebp),%eax
801010e1:	8b 10                	mov    (%eax),%edx
801010e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010e6:	8b 50 04             	mov    0x4(%eax),%edx
801010e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010ec:	8b 50 08             	mov    0x8(%eax),%edx
801010ef:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010f2:	8b 50 0c             	mov    0xc(%eax),%edx
801010f5:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010f8:	8b 50 10             	mov    0x10(%eax),%edx
801010fb:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010fe:	8b 40 14             	mov    0x14(%eax),%eax
80101101:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101104:	8b 45 08             	mov    0x8(%ebp),%eax
80101107:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010110e:	8b 45 08             	mov    0x8(%ebp),%eax
80101111:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101117:	83 ec 0c             	sub    $0xc,%esp
8010111a:	68 a0 8a 30 80       	push   $0x80308aa0
8010111f:	e8 22 3b 00 00       	call   80104c46 <release>
80101124:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101127:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010112a:	83 f8 01             	cmp    $0x1,%eax
8010112d:	75 19                	jne    80101148 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010112f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101133:	0f be d0             	movsbl %al,%edx
80101136:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101139:	83 ec 08             	sub    $0x8,%esp
8010113c:	52                   	push   %edx
8010113d:	50                   	push   %eax
8010113e:	e8 64 25 00 00       	call   801036a7 <pipeclose>
80101143:	83 c4 10             	add    $0x10,%esp
80101146:	eb 21                	jmp    80101169 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101148:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010114b:	83 f8 02             	cmp    $0x2,%eax
8010114e:	75 19                	jne    80101169 <fileclose+0xe6>
    begin_op();
80101150:	e8 cf 1e 00 00       	call   80103024 <begin_op>
    iput(ff.ip);
80101155:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101158:	83 ec 0c             	sub    $0xc,%esp
8010115b:	50                   	push   %eax
8010115c:	e8 d2 09 00 00       	call   80101b33 <iput>
80101161:	83 c4 10             	add    $0x10,%esp
    end_op();
80101164:	e8 47 1f 00 00       	call   801030b0 <end_op>
  }
}
80101169:	c9                   	leave  
8010116a:	c3                   	ret    

8010116b <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010116b:	55                   	push   %ebp
8010116c:	89 e5                	mov    %esp,%ebp
8010116e:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101171:	8b 45 08             	mov    0x8(%ebp),%eax
80101174:	8b 00                	mov    (%eax),%eax
80101176:	83 f8 02             	cmp    $0x2,%eax
80101179:	75 40                	jne    801011bb <filestat+0x50>
    ilock(f->ip);
8010117b:	8b 45 08             	mov    0x8(%ebp),%eax
8010117e:	8b 40 10             	mov    0x10(%eax),%eax
80101181:	83 ec 0c             	sub    $0xc,%esp
80101184:	50                   	push   %eax
80101185:	e8 48 08 00 00       	call   801019d2 <ilock>
8010118a:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010118d:	8b 45 08             	mov    0x8(%ebp),%eax
80101190:	8b 40 10             	mov    0x10(%eax),%eax
80101193:	83 ec 08             	sub    $0x8,%esp
80101196:	ff 75 0c             	push   0xc(%ebp)
80101199:	50                   	push   %eax
8010119a:	e8 d9 0c 00 00       	call   80101e78 <stati>
8010119f:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011a2:	8b 45 08             	mov    0x8(%ebp),%eax
801011a5:	8b 40 10             	mov    0x10(%eax),%eax
801011a8:	83 ec 0c             	sub    $0xc,%esp
801011ab:	50                   	push   %eax
801011ac:	e8 34 09 00 00       	call   80101ae5 <iunlock>
801011b1:	83 c4 10             	add    $0x10,%esp
    return 0;
801011b4:	b8 00 00 00 00       	mov    $0x0,%eax
801011b9:	eb 05                	jmp    801011c0 <filestat+0x55>
  }
  return -1;
801011bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011c0:	c9                   	leave  
801011c1:	c3                   	ret    

801011c2 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011c2:	55                   	push   %ebp
801011c3:	89 e5                	mov    %esp,%ebp
801011c5:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011c8:	8b 45 08             	mov    0x8(%ebp),%eax
801011cb:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011cf:	84 c0                	test   %al,%al
801011d1:	75 0a                	jne    801011dd <fileread+0x1b>
    return -1;
801011d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011d8:	e9 9b 00 00 00       	jmp    80101278 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011dd:	8b 45 08             	mov    0x8(%ebp),%eax
801011e0:	8b 00                	mov    (%eax),%eax
801011e2:	83 f8 01             	cmp    $0x1,%eax
801011e5:	75 1a                	jne    80101201 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011e7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ea:	8b 40 0c             	mov    0xc(%eax),%eax
801011ed:	83 ec 04             	sub    $0x4,%esp
801011f0:	ff 75 10             	push   0x10(%ebp)
801011f3:	ff 75 0c             	push   0xc(%ebp)
801011f6:	50                   	push   %eax
801011f7:	e8 58 26 00 00       	call   80103854 <piperead>
801011fc:	83 c4 10             	add    $0x10,%esp
801011ff:	eb 77                	jmp    80101278 <fileread+0xb6>
  if(f->type == FD_INODE){
80101201:	8b 45 08             	mov    0x8(%ebp),%eax
80101204:	8b 00                	mov    (%eax),%eax
80101206:	83 f8 02             	cmp    $0x2,%eax
80101209:	75 60                	jne    8010126b <fileread+0xa9>
    ilock(f->ip);
8010120b:	8b 45 08             	mov    0x8(%ebp),%eax
8010120e:	8b 40 10             	mov    0x10(%eax),%eax
80101211:	83 ec 0c             	sub    $0xc,%esp
80101214:	50                   	push   %eax
80101215:	e8 b8 07 00 00       	call   801019d2 <ilock>
8010121a:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010121d:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101220:	8b 45 08             	mov    0x8(%ebp),%eax
80101223:	8b 50 14             	mov    0x14(%eax),%edx
80101226:	8b 45 08             	mov    0x8(%ebp),%eax
80101229:	8b 40 10             	mov    0x10(%eax),%eax
8010122c:	51                   	push   %ecx
8010122d:	52                   	push   %edx
8010122e:	ff 75 0c             	push   0xc(%ebp)
80101231:	50                   	push   %eax
80101232:	e8 87 0c 00 00       	call   80101ebe <readi>
80101237:	83 c4 10             	add    $0x10,%esp
8010123a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010123d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101241:	7e 11                	jle    80101254 <fileread+0x92>
      f->off += r;
80101243:	8b 45 08             	mov    0x8(%ebp),%eax
80101246:	8b 50 14             	mov    0x14(%eax),%edx
80101249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010124c:	01 c2                	add    %eax,%edx
8010124e:	8b 45 08             	mov    0x8(%ebp),%eax
80101251:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101254:	8b 45 08             	mov    0x8(%ebp),%eax
80101257:	8b 40 10             	mov    0x10(%eax),%eax
8010125a:	83 ec 0c             	sub    $0xc,%esp
8010125d:	50                   	push   %eax
8010125e:	e8 82 08 00 00       	call   80101ae5 <iunlock>
80101263:	83 c4 10             	add    $0x10,%esp
    return r;
80101266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101269:	eb 0d                	jmp    80101278 <fileread+0xb6>
  }
  panic("fileread");
8010126b:	83 ec 0c             	sub    $0xc,%esp
8010126e:	68 da a9 10 80       	push   $0x8010a9da
80101273:	e8 31 f3 ff ff       	call   801005a9 <panic>
}
80101278:	c9                   	leave  
80101279:	c3                   	ret    

8010127a <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010127a:	55                   	push   %ebp
8010127b:	89 e5                	mov    %esp,%ebp
8010127d:	53                   	push   %ebx
8010127e:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101281:	8b 45 08             	mov    0x8(%ebp),%eax
80101284:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101288:	84 c0                	test   %al,%al
8010128a:	75 0a                	jne    80101296 <filewrite+0x1c>
    return -1;
8010128c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101291:	e9 1b 01 00 00       	jmp    801013b1 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101296:	8b 45 08             	mov    0x8(%ebp),%eax
80101299:	8b 00                	mov    (%eax),%eax
8010129b:	83 f8 01             	cmp    $0x1,%eax
8010129e:	75 1d                	jne    801012bd <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012a0:	8b 45 08             	mov    0x8(%ebp),%eax
801012a3:	8b 40 0c             	mov    0xc(%eax),%eax
801012a6:	83 ec 04             	sub    $0x4,%esp
801012a9:	ff 75 10             	push   0x10(%ebp)
801012ac:	ff 75 0c             	push   0xc(%ebp)
801012af:	50                   	push   %eax
801012b0:	e8 9d 24 00 00       	call   80103752 <pipewrite>
801012b5:	83 c4 10             	add    $0x10,%esp
801012b8:	e9 f4 00 00 00       	jmp    801013b1 <filewrite+0x137>
  if(f->type == FD_INODE){
801012bd:	8b 45 08             	mov    0x8(%ebp),%eax
801012c0:	8b 00                	mov    (%eax),%eax
801012c2:	83 f8 02             	cmp    $0x2,%eax
801012c5:	0f 85 d9 00 00 00    	jne    801013a4 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012cb:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012d9:	e9 a3 00 00 00       	jmp    80101381 <filewrite+0x107>
      int n1 = n - i;
801012de:	8b 45 10             	mov    0x10(%ebp),%eax
801012e1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012ea:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012ed:	7e 06                	jle    801012f5 <filewrite+0x7b>
        n1 = max;
801012ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012f2:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012f5:	e8 2a 1d 00 00       	call   80103024 <begin_op>
      ilock(f->ip);
801012fa:	8b 45 08             	mov    0x8(%ebp),%eax
801012fd:	8b 40 10             	mov    0x10(%eax),%eax
80101300:	83 ec 0c             	sub    $0xc,%esp
80101303:	50                   	push   %eax
80101304:	e8 c9 06 00 00       	call   801019d2 <ilock>
80101309:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010130c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010130f:	8b 45 08             	mov    0x8(%ebp),%eax
80101312:	8b 50 14             	mov    0x14(%eax),%edx
80101315:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101318:	8b 45 0c             	mov    0xc(%ebp),%eax
8010131b:	01 c3                	add    %eax,%ebx
8010131d:	8b 45 08             	mov    0x8(%ebp),%eax
80101320:	8b 40 10             	mov    0x10(%eax),%eax
80101323:	51                   	push   %ecx
80101324:	52                   	push   %edx
80101325:	53                   	push   %ebx
80101326:	50                   	push   %eax
80101327:	e8 e7 0c 00 00       	call   80102013 <writei>
8010132c:	83 c4 10             	add    $0x10,%esp
8010132f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101332:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101336:	7e 11                	jle    80101349 <filewrite+0xcf>
        f->off += r;
80101338:	8b 45 08             	mov    0x8(%ebp),%eax
8010133b:	8b 50 14             	mov    0x14(%eax),%edx
8010133e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101341:	01 c2                	add    %eax,%edx
80101343:	8b 45 08             	mov    0x8(%ebp),%eax
80101346:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101349:	8b 45 08             	mov    0x8(%ebp),%eax
8010134c:	8b 40 10             	mov    0x10(%eax),%eax
8010134f:	83 ec 0c             	sub    $0xc,%esp
80101352:	50                   	push   %eax
80101353:	e8 8d 07 00 00       	call   80101ae5 <iunlock>
80101358:	83 c4 10             	add    $0x10,%esp
      end_op();
8010135b:	e8 50 1d 00 00       	call   801030b0 <end_op>

      if(r < 0)
80101360:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101364:	78 29                	js     8010138f <filewrite+0x115>
        break;
      if(r != n1)
80101366:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101369:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010136c:	74 0d                	je     8010137b <filewrite+0x101>
        panic("short filewrite");
8010136e:	83 ec 0c             	sub    $0xc,%esp
80101371:	68 e3 a9 10 80       	push   $0x8010a9e3
80101376:	e8 2e f2 ff ff       	call   801005a9 <panic>
      i += r;
8010137b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010137e:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101384:	3b 45 10             	cmp    0x10(%ebp),%eax
80101387:	0f 8c 51 ff ff ff    	jl     801012de <filewrite+0x64>
8010138d:	eb 01                	jmp    80101390 <filewrite+0x116>
        break;
8010138f:	90                   	nop
    }
    return i == n ? n : -1;
80101390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101393:	3b 45 10             	cmp    0x10(%ebp),%eax
80101396:	75 05                	jne    8010139d <filewrite+0x123>
80101398:	8b 45 10             	mov    0x10(%ebp),%eax
8010139b:	eb 14                	jmp    801013b1 <filewrite+0x137>
8010139d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013a2:	eb 0d                	jmp    801013b1 <filewrite+0x137>
  }
  panic("filewrite");
801013a4:	83 ec 0c             	sub    $0xc,%esp
801013a7:	68 f3 a9 10 80       	push   $0x8010a9f3
801013ac:	e8 f8 f1 ff ff       	call   801005a9 <panic>
}
801013b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013b4:	c9                   	leave  
801013b5:	c3                   	ret    

801013b6 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013b6:	55                   	push   %ebp
801013b7:	89 e5                	mov    %esp,%ebp
801013b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013bc:	8b 45 08             	mov    0x8(%ebp),%eax
801013bf:	83 ec 08             	sub    $0x8,%esp
801013c2:	6a 01                	push   $0x1
801013c4:	50                   	push   %eax
801013c5:	e8 37 ee ff ff       	call   80100201 <bread>
801013ca:	83 c4 10             	add    $0x10,%esp
801013cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d3:	83 c0 5c             	add    $0x5c,%eax
801013d6:	83 ec 04             	sub    $0x4,%esp
801013d9:	6a 1c                	push   $0x1c
801013db:	50                   	push   %eax
801013dc:	ff 75 0c             	push   0xc(%ebp)
801013df:	e8 29 3b 00 00       	call   80104f0d <memmove>
801013e4:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013e7:	83 ec 0c             	sub    $0xc,%esp
801013ea:	ff 75 f4             	push   -0xc(%ebp)
801013ed:	e8 91 ee ff ff       	call   80100283 <brelse>
801013f2:	83 c4 10             	add    $0x10,%esp
}
801013f5:	90                   	nop
801013f6:	c9                   	leave  
801013f7:	c3                   	ret    

801013f8 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013f8:	55                   	push   %ebp
801013f9:	89 e5                	mov    %esp,%ebp
801013fb:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
801013fe:	8b 55 0c             	mov    0xc(%ebp),%edx
80101401:	8b 45 08             	mov    0x8(%ebp),%eax
80101404:	83 ec 08             	sub    $0x8,%esp
80101407:	52                   	push   %edx
80101408:	50                   	push   %eax
80101409:	e8 f3 ed ff ff       	call   80100201 <bread>
8010140e:	83 c4 10             	add    $0x10,%esp
80101411:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101417:	83 c0 5c             	add    $0x5c,%eax
8010141a:	83 ec 04             	sub    $0x4,%esp
8010141d:	68 00 02 00 00       	push   $0x200
80101422:	6a 00                	push   $0x0
80101424:	50                   	push   %eax
80101425:	e8 24 3a 00 00       	call   80104e4e <memset>
8010142a:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010142d:	83 ec 0c             	sub    $0xc,%esp
80101430:	ff 75 f4             	push   -0xc(%ebp)
80101433:	e8 25 1e 00 00       	call   8010325d <log_write>
80101438:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010143b:	83 ec 0c             	sub    $0xc,%esp
8010143e:	ff 75 f4             	push   -0xc(%ebp)
80101441:	e8 3d ee ff ff       	call   80100283 <brelse>
80101446:	83 c4 10             	add    $0x10,%esp
}
80101449:	90                   	nop
8010144a:	c9                   	leave  
8010144b:	c3                   	ret    

8010144c <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010144c:	55                   	push   %ebp
8010144d:	89 e5                	mov    %esp,%ebp
8010144f:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101452:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101459:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101460:	e9 0b 01 00 00       	jmp    80101570 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101468:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010146e:	85 c0                	test   %eax,%eax
80101470:	0f 48 c2             	cmovs  %edx,%eax
80101473:	c1 f8 0c             	sar    $0xc,%eax
80101476:	89 c2                	mov    %eax,%edx
80101478:	a1 58 94 30 80       	mov    0x80309458,%eax
8010147d:	01 d0                	add    %edx,%eax
8010147f:	83 ec 08             	sub    $0x8,%esp
80101482:	50                   	push   %eax
80101483:	ff 75 08             	push   0x8(%ebp)
80101486:	e8 76 ed ff ff       	call   80100201 <bread>
8010148b:	83 c4 10             	add    $0x10,%esp
8010148e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101491:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101498:	e9 9e 00 00 00       	jmp    8010153b <balloc+0xef>
      m = 1 << (bi % 8);
8010149d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a0:	83 e0 07             	and    $0x7,%eax
801014a3:	ba 01 00 00 00       	mov    $0x1,%edx
801014a8:	89 c1                	mov    %eax,%ecx
801014aa:	d3 e2                	shl    %cl,%edx
801014ac:	89 d0                	mov    %edx,%eax
801014ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b4:	8d 50 07             	lea    0x7(%eax),%edx
801014b7:	85 c0                	test   %eax,%eax
801014b9:	0f 48 c2             	cmovs  %edx,%eax
801014bc:	c1 f8 03             	sar    $0x3,%eax
801014bf:	89 c2                	mov    %eax,%edx
801014c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014c4:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014c9:	0f b6 c0             	movzbl %al,%eax
801014cc:	23 45 e8             	and    -0x18(%ebp),%eax
801014cf:	85 c0                	test   %eax,%eax
801014d1:	75 64                	jne    80101537 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d6:	8d 50 07             	lea    0x7(%eax),%edx
801014d9:	85 c0                	test   %eax,%eax
801014db:	0f 48 c2             	cmovs  %edx,%eax
801014de:	c1 f8 03             	sar    $0x3,%eax
801014e1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014e4:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801014e9:	89 d1                	mov    %edx,%ecx
801014eb:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014ee:	09 ca                	or     %ecx,%edx
801014f0:	89 d1                	mov    %edx,%ecx
801014f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014f5:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
801014f9:	83 ec 0c             	sub    $0xc,%esp
801014fc:	ff 75 ec             	push   -0x14(%ebp)
801014ff:	e8 59 1d 00 00       	call   8010325d <log_write>
80101504:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101507:	83 ec 0c             	sub    $0xc,%esp
8010150a:	ff 75 ec             	push   -0x14(%ebp)
8010150d:	e8 71 ed ff ff       	call   80100283 <brelse>
80101512:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101515:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010151b:	01 c2                	add    %eax,%edx
8010151d:	8b 45 08             	mov    0x8(%ebp),%eax
80101520:	83 ec 08             	sub    $0x8,%esp
80101523:	52                   	push   %edx
80101524:	50                   	push   %eax
80101525:	e8 ce fe ff ff       	call   801013f8 <bzero>
8010152a:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	01 d0                	add    %edx,%eax
80101535:	eb 57                	jmp    8010158e <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101537:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010153b:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101542:	7f 17                	jg     8010155b <balloc+0x10f>
80101544:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101547:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154a:	01 d0                	add    %edx,%eax
8010154c:	89 c2                	mov    %eax,%edx
8010154e:	a1 40 94 30 80       	mov    0x80309440,%eax
80101553:	39 c2                	cmp    %eax,%edx
80101555:	0f 82 42 ff ff ff    	jb     8010149d <balloc+0x51>
      }
    }
    brelse(bp);
8010155b:	83 ec 0c             	sub    $0xc,%esp
8010155e:	ff 75 ec             	push   -0x14(%ebp)
80101561:	e8 1d ed ff ff       	call   80100283 <brelse>
80101566:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101569:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101570:	8b 15 40 94 30 80    	mov    0x80309440,%edx
80101576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101579:	39 c2                	cmp    %eax,%edx
8010157b:	0f 87 e4 fe ff ff    	ja     80101465 <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101581:	83 ec 0c             	sub    $0xc,%esp
80101584:	68 00 aa 10 80       	push   $0x8010aa00
80101589:	e8 1b f0 ff ff       	call   801005a9 <panic>
}
8010158e:	c9                   	leave  
8010158f:	c3                   	ret    

80101590 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101590:	55                   	push   %ebp
80101591:	89 e5                	mov    %esp,%ebp
80101593:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101596:	83 ec 08             	sub    $0x8,%esp
80101599:	68 40 94 30 80       	push   $0x80309440
8010159e:	ff 75 08             	push   0x8(%ebp)
801015a1:	e8 10 fe ff ff       	call   801013b6 <readsb>
801015a6:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ac:	c1 e8 0c             	shr    $0xc,%eax
801015af:	89 c2                	mov    %eax,%edx
801015b1:	a1 58 94 30 80       	mov    0x80309458,%eax
801015b6:	01 c2                	add    %eax,%edx
801015b8:	8b 45 08             	mov    0x8(%ebp),%eax
801015bb:	83 ec 08             	sub    $0x8,%esp
801015be:	52                   	push   %edx
801015bf:	50                   	push   %eax
801015c0:	e8 3c ec ff ff       	call   80100201 <bread>
801015c5:	83 c4 10             	add    $0x10,%esp
801015c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ce:	25 ff 0f 00 00       	and    $0xfff,%eax
801015d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d9:	83 e0 07             	and    $0x7,%eax
801015dc:	ba 01 00 00 00       	mov    $0x1,%edx
801015e1:	89 c1                	mov    %eax,%ecx
801015e3:	d3 e2                	shl    %cl,%edx
801015e5:	89 d0                	mov    %edx,%eax
801015e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ed:	8d 50 07             	lea    0x7(%eax),%edx
801015f0:	85 c0                	test   %eax,%eax
801015f2:	0f 48 c2             	cmovs  %edx,%eax
801015f5:	c1 f8 03             	sar    $0x3,%eax
801015f8:	89 c2                	mov    %eax,%edx
801015fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015fd:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101602:	0f b6 c0             	movzbl %al,%eax
80101605:	23 45 ec             	and    -0x14(%ebp),%eax
80101608:	85 c0                	test   %eax,%eax
8010160a:	75 0d                	jne    80101619 <bfree+0x89>
    panic("freeing free block");
8010160c:	83 ec 0c             	sub    $0xc,%esp
8010160f:	68 16 aa 10 80       	push   $0x8010aa16
80101614:	e8 90 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101619:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010161c:	8d 50 07             	lea    0x7(%eax),%edx
8010161f:	85 c0                	test   %eax,%eax
80101621:	0f 48 c2             	cmovs  %edx,%eax
80101624:	c1 f8 03             	sar    $0x3,%eax
80101627:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010162a:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010162f:	89 d1                	mov    %edx,%ecx
80101631:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101634:	f7 d2                	not    %edx
80101636:	21 ca                	and    %ecx,%edx
80101638:	89 d1                	mov    %edx,%ecx
8010163a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163d:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101641:	83 ec 0c             	sub    $0xc,%esp
80101644:	ff 75 f4             	push   -0xc(%ebp)
80101647:	e8 11 1c 00 00       	call   8010325d <log_write>
8010164c:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010164f:	83 ec 0c             	sub    $0xc,%esp
80101652:	ff 75 f4             	push   -0xc(%ebp)
80101655:	e8 29 ec ff ff       	call   80100283 <brelse>
8010165a:	83 c4 10             	add    $0x10,%esp
}
8010165d:	90                   	nop
8010165e:	c9                   	leave  
8010165f:	c3                   	ret    

80101660 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101660:	55                   	push   %ebp
80101661:	89 e5                	mov    %esp,%ebp
80101663:	57                   	push   %edi
80101664:	56                   	push   %esi
80101665:	53                   	push   %ebx
80101666:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101669:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101670:	83 ec 08             	sub    $0x8,%esp
80101673:	68 29 aa 10 80       	push   $0x8010aa29
80101678:	68 60 94 30 80       	push   $0x80309460
8010167d:	e8 34 35 00 00       	call   80104bb6 <initlock>
80101682:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101685:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010168c:	eb 2d                	jmp    801016bb <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
8010168e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101691:	89 d0                	mov    %edx,%eax
80101693:	c1 e0 03             	shl    $0x3,%eax
80101696:	01 d0                	add    %edx,%eax
80101698:	c1 e0 04             	shl    $0x4,%eax
8010169b:	83 c0 30             	add    $0x30,%eax
8010169e:	05 60 94 30 80       	add    $0x80309460,%eax
801016a3:	83 c0 10             	add    $0x10,%eax
801016a6:	83 ec 08             	sub    $0x8,%esp
801016a9:	68 30 aa 10 80       	push   $0x8010aa30
801016ae:	50                   	push   %eax
801016af:	e8 a5 33 00 00       	call   80104a59 <initsleeplock>
801016b4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016b7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016bb:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016bf:	7e cd                	jle    8010168e <iinit+0x2e>
  }

  readsb(dev, &sb);
801016c1:	83 ec 08             	sub    $0x8,%esp
801016c4:	68 40 94 30 80       	push   $0x80309440
801016c9:	ff 75 08             	push   0x8(%ebp)
801016cc:	e8 e5 fc ff ff       	call   801013b6 <readsb>
801016d1:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016d4:	a1 58 94 30 80       	mov    0x80309458,%eax
801016d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016dc:	8b 3d 54 94 30 80    	mov    0x80309454,%edi
801016e2:	8b 35 50 94 30 80    	mov    0x80309450,%esi
801016e8:	8b 1d 4c 94 30 80    	mov    0x8030944c,%ebx
801016ee:	8b 0d 48 94 30 80    	mov    0x80309448,%ecx
801016f4:	8b 15 44 94 30 80    	mov    0x80309444,%edx
801016fa:	a1 40 94 30 80       	mov    0x80309440,%eax
801016ff:	ff 75 d4             	push   -0x2c(%ebp)
80101702:	57                   	push   %edi
80101703:	56                   	push   %esi
80101704:	53                   	push   %ebx
80101705:	51                   	push   %ecx
80101706:	52                   	push   %edx
80101707:	50                   	push   %eax
80101708:	68 38 aa 10 80       	push   $0x8010aa38
8010170d:	e8 e2 ec ff ff       	call   801003f4 <cprintf>
80101712:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101715:	90                   	nop
80101716:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101719:	5b                   	pop    %ebx
8010171a:	5e                   	pop    %esi
8010171b:	5f                   	pop    %edi
8010171c:	5d                   	pop    %ebp
8010171d:	c3                   	ret    

8010171e <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010171e:	55                   	push   %ebp
8010171f:	89 e5                	mov    %esp,%ebp
80101721:	83 ec 28             	sub    $0x28,%esp
80101724:	8b 45 0c             	mov    0xc(%ebp),%eax
80101727:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010172b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101732:	e9 9e 00 00 00       	jmp    801017d5 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010173a:	c1 e8 03             	shr    $0x3,%eax
8010173d:	89 c2                	mov    %eax,%edx
8010173f:	a1 54 94 30 80       	mov    0x80309454,%eax
80101744:	01 d0                	add    %edx,%eax
80101746:	83 ec 08             	sub    $0x8,%esp
80101749:	50                   	push   %eax
8010174a:	ff 75 08             	push   0x8(%ebp)
8010174d:	e8 af ea ff ff       	call   80100201 <bread>
80101752:	83 c4 10             	add    $0x10,%esp
80101755:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101758:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010175e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101761:	83 e0 07             	and    $0x7,%eax
80101764:	c1 e0 06             	shl    $0x6,%eax
80101767:	01 d0                	add    %edx,%eax
80101769:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010176c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010176f:	0f b7 00             	movzwl (%eax),%eax
80101772:	66 85 c0             	test   %ax,%ax
80101775:	75 4c                	jne    801017c3 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101777:	83 ec 04             	sub    $0x4,%esp
8010177a:	6a 40                	push   $0x40
8010177c:	6a 00                	push   $0x0
8010177e:	ff 75 ec             	push   -0x14(%ebp)
80101781:	e8 c8 36 00 00       	call   80104e4e <memset>
80101786:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101789:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010178c:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101790:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101793:	83 ec 0c             	sub    $0xc,%esp
80101796:	ff 75 f0             	push   -0x10(%ebp)
80101799:	e8 bf 1a 00 00       	call   8010325d <log_write>
8010179e:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017a1:	83 ec 0c             	sub    $0xc,%esp
801017a4:	ff 75 f0             	push   -0x10(%ebp)
801017a7:	e8 d7 ea ff ff       	call   80100283 <brelse>
801017ac:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b2:	83 ec 08             	sub    $0x8,%esp
801017b5:	50                   	push   %eax
801017b6:	ff 75 08             	push   0x8(%ebp)
801017b9:	e8 f8 00 00 00       	call   801018b6 <iget>
801017be:	83 c4 10             	add    $0x10,%esp
801017c1:	eb 30                	jmp    801017f3 <ialloc+0xd5>
    }
    brelse(bp);
801017c3:	83 ec 0c             	sub    $0xc,%esp
801017c6:	ff 75 f0             	push   -0x10(%ebp)
801017c9:	e8 b5 ea ff ff       	call   80100283 <brelse>
801017ce:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017d5:	8b 15 48 94 30 80    	mov    0x80309448,%edx
801017db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017de:	39 c2                	cmp    %eax,%edx
801017e0:	0f 87 51 ff ff ff    	ja     80101737 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017e6:	83 ec 0c             	sub    $0xc,%esp
801017e9:	68 8b aa 10 80       	push   $0x8010aa8b
801017ee:	e8 b6 ed ff ff       	call   801005a9 <panic>
}
801017f3:	c9                   	leave  
801017f4:	c3                   	ret    

801017f5 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801017f5:	55                   	push   %ebp
801017f6:	89 e5                	mov    %esp,%ebp
801017f8:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017fb:	8b 45 08             	mov    0x8(%ebp),%eax
801017fe:	8b 40 04             	mov    0x4(%eax),%eax
80101801:	c1 e8 03             	shr    $0x3,%eax
80101804:	89 c2                	mov    %eax,%edx
80101806:	a1 54 94 30 80       	mov    0x80309454,%eax
8010180b:	01 c2                	add    %eax,%edx
8010180d:	8b 45 08             	mov    0x8(%ebp),%eax
80101810:	8b 00                	mov    (%eax),%eax
80101812:	83 ec 08             	sub    $0x8,%esp
80101815:	52                   	push   %edx
80101816:	50                   	push   %eax
80101817:	e8 e5 e9 ff ff       	call   80100201 <bread>
8010181c:	83 c4 10             	add    $0x10,%esp
8010181f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101825:	8d 50 5c             	lea    0x5c(%eax),%edx
80101828:	8b 45 08             	mov    0x8(%ebp),%eax
8010182b:	8b 40 04             	mov    0x4(%eax),%eax
8010182e:	83 e0 07             	and    $0x7,%eax
80101831:	c1 e0 06             	shl    $0x6,%eax
80101834:	01 d0                	add    %edx,%eax
80101836:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101839:	8b 45 08             	mov    0x8(%ebp),%eax
8010183c:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101840:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101843:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101846:	8b 45 08             	mov    0x8(%ebp),%eax
80101849:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010184d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101850:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101854:	8b 45 08             	mov    0x8(%ebp),%eax
80101857:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010185b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101862:	8b 45 08             	mov    0x8(%ebp),%eax
80101865:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101869:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010186c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101870:	8b 45 08             	mov    0x8(%ebp),%eax
80101873:	8b 50 58             	mov    0x58(%eax),%edx
80101876:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101879:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010187c:	8b 45 08             	mov    0x8(%ebp),%eax
8010187f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101885:	83 c0 0c             	add    $0xc,%eax
80101888:	83 ec 04             	sub    $0x4,%esp
8010188b:	6a 34                	push   $0x34
8010188d:	52                   	push   %edx
8010188e:	50                   	push   %eax
8010188f:	e8 79 36 00 00       	call   80104f0d <memmove>
80101894:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101897:	83 ec 0c             	sub    $0xc,%esp
8010189a:	ff 75 f4             	push   -0xc(%ebp)
8010189d:	e8 bb 19 00 00       	call   8010325d <log_write>
801018a2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018a5:	83 ec 0c             	sub    $0xc,%esp
801018a8:	ff 75 f4             	push   -0xc(%ebp)
801018ab:	e8 d3 e9 ff ff       	call   80100283 <brelse>
801018b0:	83 c4 10             	add    $0x10,%esp
}
801018b3:	90                   	nop
801018b4:	c9                   	leave  
801018b5:	c3                   	ret    

801018b6 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018b6:	55                   	push   %ebp
801018b7:	89 e5                	mov    %esp,%ebp
801018b9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018bc:	83 ec 0c             	sub    $0xc,%esp
801018bf:	68 60 94 30 80       	push   $0x80309460
801018c4:	e8 0f 33 00 00       	call   80104bd8 <acquire>
801018c9:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018cc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018d3:	c7 45 f4 94 94 30 80 	movl   $0x80309494,-0xc(%ebp)
801018da:	eb 60                	jmp    8010193c <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018df:	8b 40 08             	mov    0x8(%eax),%eax
801018e2:	85 c0                	test   %eax,%eax
801018e4:	7e 39                	jle    8010191f <iget+0x69>
801018e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e9:	8b 00                	mov    (%eax),%eax
801018eb:	39 45 08             	cmp    %eax,0x8(%ebp)
801018ee:	75 2f                	jne    8010191f <iget+0x69>
801018f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f3:	8b 40 04             	mov    0x4(%eax),%eax
801018f6:	39 45 0c             	cmp    %eax,0xc(%ebp)
801018f9:	75 24                	jne    8010191f <iget+0x69>
      ip->ref++;
801018fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fe:	8b 40 08             	mov    0x8(%eax),%eax
80101901:	8d 50 01             	lea    0x1(%eax),%edx
80101904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101907:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010190a:	83 ec 0c             	sub    $0xc,%esp
8010190d:	68 60 94 30 80       	push   $0x80309460
80101912:	e8 2f 33 00 00       	call   80104c46 <release>
80101917:	83 c4 10             	add    $0x10,%esp
      return ip;
8010191a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191d:	eb 77                	jmp    80101996 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010191f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101923:	75 10                	jne    80101935 <iget+0x7f>
80101925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101928:	8b 40 08             	mov    0x8(%eax),%eax
8010192b:	85 c0                	test   %eax,%eax
8010192d:	75 06                	jne    80101935 <iget+0x7f>
      empty = ip;
8010192f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101932:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101935:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010193c:	81 7d f4 b4 b0 30 80 	cmpl   $0x8030b0b4,-0xc(%ebp)
80101943:	72 97                	jb     801018dc <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101945:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101949:	75 0d                	jne    80101958 <iget+0xa2>
    panic("iget: no inodes");
8010194b:	83 ec 0c             	sub    $0xc,%esp
8010194e:	68 9d aa 10 80       	push   $0x8010aa9d
80101953:	e8 51 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010195b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010195e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101961:	8b 55 08             	mov    0x8(%ebp),%edx
80101964:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101969:	8b 55 0c             	mov    0xc(%ebp),%edx
8010196c:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010196f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101972:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197c:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101983:	83 ec 0c             	sub    $0xc,%esp
80101986:	68 60 94 30 80       	push   $0x80309460
8010198b:	e8 b6 32 00 00       	call   80104c46 <release>
80101990:	83 c4 10             	add    $0x10,%esp

  return ip;
80101993:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101996:	c9                   	leave  
80101997:	c3                   	ret    

80101998 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101998:	55                   	push   %ebp
80101999:	89 e5                	mov    %esp,%ebp
8010199b:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
8010199e:	83 ec 0c             	sub    $0xc,%esp
801019a1:	68 60 94 30 80       	push   $0x80309460
801019a6:	e8 2d 32 00 00       	call   80104bd8 <acquire>
801019ab:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019ae:	8b 45 08             	mov    0x8(%ebp),%eax
801019b1:	8b 40 08             	mov    0x8(%eax),%eax
801019b4:	8d 50 01             	lea    0x1(%eax),%edx
801019b7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ba:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019bd:	83 ec 0c             	sub    $0xc,%esp
801019c0:	68 60 94 30 80       	push   $0x80309460
801019c5:	e8 7c 32 00 00       	call   80104c46 <release>
801019ca:	83 c4 10             	add    $0x10,%esp
  return ip;
801019cd:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019d0:	c9                   	leave  
801019d1:	c3                   	ret    

801019d2 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019d2:	55                   	push   %ebp
801019d3:	89 e5                	mov    %esp,%ebp
801019d5:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019d8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019dc:	74 0a                	je     801019e8 <ilock+0x16>
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	8b 40 08             	mov    0x8(%eax),%eax
801019e4:	85 c0                	test   %eax,%eax
801019e6:	7f 0d                	jg     801019f5 <ilock+0x23>
    panic("ilock");
801019e8:	83 ec 0c             	sub    $0xc,%esp
801019eb:	68 ad aa 10 80       	push   $0x8010aaad
801019f0:	e8 b4 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
801019f5:	8b 45 08             	mov    0x8(%ebp),%eax
801019f8:	83 c0 0c             	add    $0xc,%eax
801019fb:	83 ec 0c             	sub    $0xc,%esp
801019fe:	50                   	push   %eax
801019ff:	e8 91 30 00 00       	call   80104a95 <acquiresleep>
80101a04:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a07:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a0d:	85 c0                	test   %eax,%eax
80101a0f:	0f 85 cd 00 00 00    	jne    80101ae2 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	8b 40 04             	mov    0x4(%eax),%eax
80101a1b:	c1 e8 03             	shr    $0x3,%eax
80101a1e:	89 c2                	mov    %eax,%edx
80101a20:	a1 54 94 30 80       	mov    0x80309454,%eax
80101a25:	01 c2                	add    %eax,%edx
80101a27:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2a:	8b 00                	mov    (%eax),%eax
80101a2c:	83 ec 08             	sub    $0x8,%esp
80101a2f:	52                   	push   %edx
80101a30:	50                   	push   %eax
80101a31:	e8 cb e7 ff ff       	call   80100201 <bread>
80101a36:	83 c4 10             	add    $0x10,%esp
80101a39:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a42:	8b 45 08             	mov    0x8(%ebp),%eax
80101a45:	8b 40 04             	mov    0x4(%eax),%eax
80101a48:	83 e0 07             	and    $0x7,%eax
80101a4b:	c1 e0 06             	shl    $0x6,%eax
80101a4e:	01 d0                	add    %edx,%eax
80101a50:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a56:	0f b7 10             	movzwl (%eax),%edx
80101a59:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5c:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a63:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a67:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6a:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a71:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a75:	8b 45 08             	mov    0x8(%ebp),%eax
80101a78:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7f:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a83:	8b 45 08             	mov    0x8(%ebp),%eax
80101a86:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8d:	8b 50 08             	mov    0x8(%eax),%edx
80101a90:	8b 45 08             	mov    0x8(%ebp),%eax
80101a93:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a99:	8d 50 0c             	lea    0xc(%eax),%edx
80101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9f:	83 c0 5c             	add    $0x5c,%eax
80101aa2:	83 ec 04             	sub    $0x4,%esp
80101aa5:	6a 34                	push   $0x34
80101aa7:	52                   	push   %edx
80101aa8:	50                   	push   %eax
80101aa9:	e8 5f 34 00 00       	call   80104f0d <memmove>
80101aae:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ab1:	83 ec 0c             	sub    $0xc,%esp
80101ab4:	ff 75 f4             	push   -0xc(%ebp)
80101ab7:	e8 c7 e7 ff ff       	call   80100283 <brelse>
80101abc:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101abf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80101acc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ad0:	66 85 c0             	test   %ax,%ax
80101ad3:	75 0d                	jne    80101ae2 <ilock+0x110>
      panic("ilock: no type");
80101ad5:	83 ec 0c             	sub    $0xc,%esp
80101ad8:	68 b3 aa 10 80       	push   $0x8010aab3
80101add:	e8 c7 ea ff ff       	call   801005a9 <panic>
  }
}
80101ae2:	90                   	nop
80101ae3:	c9                   	leave  
80101ae4:	c3                   	ret    

80101ae5 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ae5:	55                   	push   %ebp
80101ae6:	89 e5                	mov    %esp,%ebp
80101ae8:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101aeb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101aef:	74 20                	je     80101b11 <iunlock+0x2c>
80101af1:	8b 45 08             	mov    0x8(%ebp),%eax
80101af4:	83 c0 0c             	add    $0xc,%eax
80101af7:	83 ec 0c             	sub    $0xc,%esp
80101afa:	50                   	push   %eax
80101afb:	e8 47 30 00 00       	call   80104b47 <holdingsleep>
80101b00:	83 c4 10             	add    $0x10,%esp
80101b03:	85 c0                	test   %eax,%eax
80101b05:	74 0a                	je     80101b11 <iunlock+0x2c>
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	8b 40 08             	mov    0x8(%eax),%eax
80101b0d:	85 c0                	test   %eax,%eax
80101b0f:	7f 0d                	jg     80101b1e <iunlock+0x39>
    panic("iunlock");
80101b11:	83 ec 0c             	sub    $0xc,%esp
80101b14:	68 c2 aa 10 80       	push   $0x8010aac2
80101b19:	e8 8b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b21:	83 c0 0c             	add    $0xc,%eax
80101b24:	83 ec 0c             	sub    $0xc,%esp
80101b27:	50                   	push   %eax
80101b28:	e8 cc 2f 00 00       	call   80104af9 <releasesleep>
80101b2d:	83 c4 10             	add    $0x10,%esp
}
80101b30:	90                   	nop
80101b31:	c9                   	leave  
80101b32:	c3                   	ret    

80101b33 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b33:	55                   	push   %ebp
80101b34:	89 e5                	mov    %esp,%ebp
80101b36:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b39:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3c:	83 c0 0c             	add    $0xc,%eax
80101b3f:	83 ec 0c             	sub    $0xc,%esp
80101b42:	50                   	push   %eax
80101b43:	e8 4d 2f 00 00       	call   80104a95 <acquiresleep>
80101b48:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b51:	85 c0                	test   %eax,%eax
80101b53:	74 6a                	je     80101bbf <iput+0x8c>
80101b55:	8b 45 08             	mov    0x8(%ebp),%eax
80101b58:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b5c:	66 85 c0             	test   %ax,%ax
80101b5f:	75 5e                	jne    80101bbf <iput+0x8c>
    acquire(&icache.lock);
80101b61:	83 ec 0c             	sub    $0xc,%esp
80101b64:	68 60 94 30 80       	push   $0x80309460
80101b69:	e8 6a 30 00 00       	call   80104bd8 <acquire>
80101b6e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b71:	8b 45 08             	mov    0x8(%ebp),%eax
80101b74:	8b 40 08             	mov    0x8(%eax),%eax
80101b77:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b7a:	83 ec 0c             	sub    $0xc,%esp
80101b7d:	68 60 94 30 80       	push   $0x80309460
80101b82:	e8 bf 30 00 00       	call   80104c46 <release>
80101b87:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101b8a:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101b8e:	75 2f                	jne    80101bbf <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101b90:	83 ec 0c             	sub    $0xc,%esp
80101b93:	ff 75 08             	push   0x8(%ebp)
80101b96:	e8 ad 01 00 00       	call   80101d48 <itrunc>
80101b9b:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101b9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba1:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101ba7:	83 ec 0c             	sub    $0xc,%esp
80101baa:	ff 75 08             	push   0x8(%ebp)
80101bad:	e8 43 fc ff ff       	call   801017f5 <iupdate>
80101bb2:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc2:	83 c0 0c             	add    $0xc,%eax
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	50                   	push   %eax
80101bc9:	e8 2b 2f 00 00       	call   80104af9 <releasesleep>
80101bce:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bd1:	83 ec 0c             	sub    $0xc,%esp
80101bd4:	68 60 94 30 80       	push   $0x80309460
80101bd9:	e8 fa 2f 00 00       	call   80104bd8 <acquire>
80101bde:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101be1:	8b 45 08             	mov    0x8(%ebp),%eax
80101be4:	8b 40 08             	mov    0x8(%eax),%eax
80101be7:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bf0:	83 ec 0c             	sub    $0xc,%esp
80101bf3:	68 60 94 30 80       	push   $0x80309460
80101bf8:	e8 49 30 00 00       	call   80104c46 <release>
80101bfd:	83 c4 10             	add    $0x10,%esp
}
80101c00:	90                   	nop
80101c01:	c9                   	leave  
80101c02:	c3                   	ret    

80101c03 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c03:	55                   	push   %ebp
80101c04:	89 e5                	mov    %esp,%ebp
80101c06:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c09:	83 ec 0c             	sub    $0xc,%esp
80101c0c:	ff 75 08             	push   0x8(%ebp)
80101c0f:	e8 d1 fe ff ff       	call   80101ae5 <iunlock>
80101c14:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	ff 75 08             	push   0x8(%ebp)
80101c1d:	e8 11 ff ff ff       	call   80101b33 <iput>
80101c22:	83 c4 10             	add    $0x10,%esp
}
80101c25:	90                   	nop
80101c26:	c9                   	leave  
80101c27:	c3                   	ret    

80101c28 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c28:	55                   	push   %ebp
80101c29:	89 e5                	mov    %esp,%ebp
80101c2b:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c2e:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c32:	77 42                	ja     80101c76 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c34:	8b 45 08             	mov    0x8(%ebp),%eax
80101c37:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c3a:	83 c2 14             	add    $0x14,%edx
80101c3d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c48:	75 24                	jne    80101c6e <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4d:	8b 00                	mov    (%eax),%eax
80101c4f:	83 ec 0c             	sub    $0xc,%esp
80101c52:	50                   	push   %eax
80101c53:	e8 f4 f7 ff ff       	call   8010144c <balloc>
80101c58:	83 c4 10             	add    $0x10,%esp
80101c5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c61:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c64:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c6a:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c71:	e9 d0 00 00 00       	jmp    80101d46 <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c76:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c7a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c7e:	0f 87 b5 00 00 00    	ja     80101d39 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c84:	8b 45 08             	mov    0x8(%ebp),%eax
80101c87:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101c8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c94:	75 20                	jne    80101cb6 <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c96:	8b 45 08             	mov    0x8(%ebp),%eax
80101c99:	8b 00                	mov    (%eax),%eax
80101c9b:	83 ec 0c             	sub    $0xc,%esp
80101c9e:	50                   	push   %eax
80101c9f:	e8 a8 f7 ff ff       	call   8010144c <balloc>
80101ca4:	83 c4 10             	add    $0x10,%esp
80101ca7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101caa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb0:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb9:	8b 00                	mov    (%eax),%eax
80101cbb:	83 ec 08             	sub    $0x8,%esp
80101cbe:	ff 75 f4             	push   -0xc(%ebp)
80101cc1:	50                   	push   %eax
80101cc2:	e8 3a e5 ff ff       	call   80100201 <bread>
80101cc7:	83 c4 10             	add    $0x10,%esp
80101cca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ccd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd0:	83 c0 5c             	add    $0x5c,%eax
80101cd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cd9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ce0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ce3:	01 d0                	add    %edx,%eax
80101ce5:	8b 00                	mov    (%eax),%eax
80101ce7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cee:	75 36                	jne    80101d26 <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf3:	8b 00                	mov    (%eax),%eax
80101cf5:	83 ec 0c             	sub    $0xc,%esp
80101cf8:	50                   	push   %eax
80101cf9:	e8 4e f7 ff ff       	call   8010144c <balloc>
80101cfe:	83 c4 10             	add    $0x10,%esp
80101d01:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d04:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d11:	01 c2                	add    %eax,%edx
80101d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d16:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d18:	83 ec 0c             	sub    $0xc,%esp
80101d1b:	ff 75 f0             	push   -0x10(%ebp)
80101d1e:	e8 3a 15 00 00       	call   8010325d <log_write>
80101d23:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d26:	83 ec 0c             	sub    $0xc,%esp
80101d29:	ff 75 f0             	push   -0x10(%ebp)
80101d2c:	e8 52 e5 ff ff       	call   80100283 <brelse>
80101d31:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d37:	eb 0d                	jmp    80101d46 <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d39:	83 ec 0c             	sub    $0xc,%esp
80101d3c:	68 ca aa 10 80       	push   $0x8010aaca
80101d41:	e8 63 e8 ff ff       	call   801005a9 <panic>
}
80101d46:	c9                   	leave  
80101d47:	c3                   	ret    

80101d48 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d48:	55                   	push   %ebp
80101d49:	89 e5                	mov    %esp,%ebp
80101d4b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d4e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d55:	eb 45                	jmp    80101d9c <itrunc+0x54>
    if(ip->addrs[i]){
80101d57:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d5d:	83 c2 14             	add    $0x14,%edx
80101d60:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d64:	85 c0                	test   %eax,%eax
80101d66:	74 30                	je     80101d98 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d68:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6e:	83 c2 14             	add    $0x14,%edx
80101d71:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d75:	8b 55 08             	mov    0x8(%ebp),%edx
80101d78:	8b 12                	mov    (%edx),%edx
80101d7a:	83 ec 08             	sub    $0x8,%esp
80101d7d:	50                   	push   %eax
80101d7e:	52                   	push   %edx
80101d7f:	e8 0c f8 ff ff       	call   80101590 <bfree>
80101d84:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d87:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d8d:	83 c2 14             	add    $0x14,%edx
80101d90:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d97:	00 
  for(i = 0; i < NDIRECT; i++){
80101d98:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d9c:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101da0:	7e b5                	jle    80101d57 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101da2:	8b 45 08             	mov    0x8(%ebp),%eax
80101da5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dab:	85 c0                	test   %eax,%eax
80101dad:	0f 84 aa 00 00 00    	je     80101e5d <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101db3:	8b 45 08             	mov    0x8(%ebp),%eax
80101db6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbf:	8b 00                	mov    (%eax),%eax
80101dc1:	83 ec 08             	sub    $0x8,%esp
80101dc4:	52                   	push   %edx
80101dc5:	50                   	push   %eax
80101dc6:	e8 36 e4 ff ff       	call   80100201 <bread>
80101dcb:	83 c4 10             	add    $0x10,%esp
80101dce:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101dd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dd4:	83 c0 5c             	add    $0x5c,%eax
80101dd7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dda:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101de1:	eb 3c                	jmp    80101e1f <itrunc+0xd7>
      if(a[j])
80101de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101de6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ded:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101df0:	01 d0                	add    %edx,%eax
80101df2:	8b 00                	mov    (%eax),%eax
80101df4:	85 c0                	test   %eax,%eax
80101df6:	74 23                	je     80101e1b <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e02:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e05:	01 d0                	add    %edx,%eax
80101e07:	8b 00                	mov    (%eax),%eax
80101e09:	8b 55 08             	mov    0x8(%ebp),%edx
80101e0c:	8b 12                	mov    (%edx),%edx
80101e0e:	83 ec 08             	sub    $0x8,%esp
80101e11:	50                   	push   %eax
80101e12:	52                   	push   %edx
80101e13:	e8 78 f7 ff ff       	call   80101590 <bfree>
80101e18:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e1b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e22:	83 f8 7f             	cmp    $0x7f,%eax
80101e25:	76 bc                	jbe    80101de3 <itrunc+0x9b>
    }
    brelse(bp);
80101e27:	83 ec 0c             	sub    $0xc,%esp
80101e2a:	ff 75 ec             	push   -0x14(%ebp)
80101e2d:	e8 51 e4 ff ff       	call   80100283 <brelse>
80101e32:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e35:	8b 45 08             	mov    0x8(%ebp),%eax
80101e38:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e3e:	8b 55 08             	mov    0x8(%ebp),%edx
80101e41:	8b 12                	mov    (%edx),%edx
80101e43:	83 ec 08             	sub    $0x8,%esp
80101e46:	50                   	push   %eax
80101e47:	52                   	push   %edx
80101e48:	e8 43 f7 ff ff       	call   80101590 <bfree>
80101e4d:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e50:	8b 45 08             	mov    0x8(%ebp),%eax
80101e53:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e5a:	00 00 00 
  }

  ip->size = 0;
80101e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e60:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e67:	83 ec 0c             	sub    $0xc,%esp
80101e6a:	ff 75 08             	push   0x8(%ebp)
80101e6d:	e8 83 f9 ff ff       	call   801017f5 <iupdate>
80101e72:	83 c4 10             	add    $0x10,%esp
}
80101e75:	90                   	nop
80101e76:	c9                   	leave  
80101e77:	c3                   	ret    

80101e78 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e78:	55                   	push   %ebp
80101e79:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7e:	8b 00                	mov    (%eax),%eax
80101e80:	89 c2                	mov    %eax,%edx
80101e82:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e85:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e88:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8b:	8b 50 04             	mov    0x4(%eax),%edx
80101e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e91:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e94:	8b 45 08             	mov    0x8(%ebp),%eax
80101e97:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9e:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea4:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eab:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	8b 50 58             	mov    0x58(%eax),%edx
80101eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb8:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ebb:	90                   	nop
80101ebc:	5d                   	pop    %ebp
80101ebd:	c3                   	ret    

80101ebe <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ebe:	55                   	push   %ebp
80101ebf:	89 e5                	mov    %esp,%ebp
80101ec1:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ecb:	66 83 f8 03          	cmp    $0x3,%ax
80101ecf:	75 5c                	jne    80101f2d <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ed8:	66 85 c0             	test   %ax,%ax
80101edb:	78 20                	js     80101efd <readi+0x3f>
80101edd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee0:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ee4:	66 83 f8 09          	cmp    $0x9,%ax
80101ee8:	7f 13                	jg     80101efd <readi+0x3f>
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef1:	98                   	cwtl   
80101ef2:	8b 04 c5 40 8a 30 80 	mov    -0x7fcf75c0(,%eax,8),%eax
80101ef9:	85 c0                	test   %eax,%eax
80101efb:	75 0a                	jne    80101f07 <readi+0x49>
      return -1;
80101efd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f02:	e9 0a 01 00 00       	jmp    80102011 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f07:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f0e:	98                   	cwtl   
80101f0f:	8b 04 c5 40 8a 30 80 	mov    -0x7fcf75c0(,%eax,8),%eax
80101f16:	8b 55 14             	mov    0x14(%ebp),%edx
80101f19:	83 ec 04             	sub    $0x4,%esp
80101f1c:	52                   	push   %edx
80101f1d:	ff 75 0c             	push   0xc(%ebp)
80101f20:	ff 75 08             	push   0x8(%ebp)
80101f23:	ff d0                	call   *%eax
80101f25:	83 c4 10             	add    $0x10,%esp
80101f28:	e9 e4 00 00 00       	jmp    80102011 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f30:	8b 40 58             	mov    0x58(%eax),%eax
80101f33:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f36:	77 0d                	ja     80101f45 <readi+0x87>
80101f38:	8b 55 10             	mov    0x10(%ebp),%edx
80101f3b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f3e:	01 d0                	add    %edx,%eax
80101f40:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f43:	76 0a                	jbe    80101f4f <readi+0x91>
    return -1;
80101f45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f4a:	e9 c2 00 00 00       	jmp    80102011 <readi+0x153>
  if(off + n > ip->size)
80101f4f:	8b 55 10             	mov    0x10(%ebp),%edx
80101f52:	8b 45 14             	mov    0x14(%ebp),%eax
80101f55:	01 c2                	add    %eax,%edx
80101f57:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5a:	8b 40 58             	mov    0x58(%eax),%eax
80101f5d:	39 c2                	cmp    %eax,%edx
80101f5f:	76 0c                	jbe    80101f6d <readi+0xaf>
    n = ip->size - off;
80101f61:	8b 45 08             	mov    0x8(%ebp),%eax
80101f64:	8b 40 58             	mov    0x58(%eax),%eax
80101f67:	2b 45 10             	sub    0x10(%ebp),%eax
80101f6a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f6d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f74:	e9 89 00 00 00       	jmp    80102002 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f79:	8b 45 10             	mov    0x10(%ebp),%eax
80101f7c:	c1 e8 09             	shr    $0x9,%eax
80101f7f:	83 ec 08             	sub    $0x8,%esp
80101f82:	50                   	push   %eax
80101f83:	ff 75 08             	push   0x8(%ebp)
80101f86:	e8 9d fc ff ff       	call   80101c28 <bmap>
80101f8b:	83 c4 10             	add    $0x10,%esp
80101f8e:	8b 55 08             	mov    0x8(%ebp),%edx
80101f91:	8b 12                	mov    (%edx),%edx
80101f93:	83 ec 08             	sub    $0x8,%esp
80101f96:	50                   	push   %eax
80101f97:	52                   	push   %edx
80101f98:	e8 64 e2 ff ff       	call   80100201 <bread>
80101f9d:	83 c4 10             	add    $0x10,%esp
80101fa0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fa3:	8b 45 10             	mov    0x10(%ebp),%eax
80101fa6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fab:	ba 00 02 00 00       	mov    $0x200,%edx
80101fb0:	29 c2                	sub    %eax,%edx
80101fb2:	8b 45 14             	mov    0x14(%ebp),%eax
80101fb5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fb8:	39 c2                	cmp    %eax,%edx
80101fba:	0f 46 c2             	cmovbe %edx,%eax
80101fbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fc3:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fc6:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc9:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fce:	01 d0                	add    %edx,%eax
80101fd0:	83 ec 04             	sub    $0x4,%esp
80101fd3:	ff 75 ec             	push   -0x14(%ebp)
80101fd6:	50                   	push   %eax
80101fd7:	ff 75 0c             	push   0xc(%ebp)
80101fda:	e8 2e 2f 00 00       	call   80104f0d <memmove>
80101fdf:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101fe2:	83 ec 0c             	sub    $0xc,%esp
80101fe5:	ff 75 f0             	push   -0x10(%ebp)
80101fe8:	e8 96 e2 ff ff       	call   80100283 <brelse>
80101fed:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ff0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff3:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ff6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff9:	01 45 10             	add    %eax,0x10(%ebp)
80101ffc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fff:	01 45 0c             	add    %eax,0xc(%ebp)
80102002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102005:	3b 45 14             	cmp    0x14(%ebp),%eax
80102008:	0f 82 6b ff ff ff    	jb     80101f79 <readi+0xbb>
  }
  return n;
8010200e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102011:	c9                   	leave  
80102012:	c3                   	ret    

80102013 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102013:	55                   	push   %ebp
80102014:	89 e5                	mov    %esp,%ebp
80102016:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102019:	8b 45 08             	mov    0x8(%ebp),%eax
8010201c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102020:	66 83 f8 03          	cmp    $0x3,%ax
80102024:	75 5c                	jne    80102082 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102026:	8b 45 08             	mov    0x8(%ebp),%eax
80102029:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010202d:	66 85 c0             	test   %ax,%ax
80102030:	78 20                	js     80102052 <writei+0x3f>
80102032:	8b 45 08             	mov    0x8(%ebp),%eax
80102035:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102039:	66 83 f8 09          	cmp    $0x9,%ax
8010203d:	7f 13                	jg     80102052 <writei+0x3f>
8010203f:	8b 45 08             	mov    0x8(%ebp),%eax
80102042:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102046:	98                   	cwtl   
80102047:	8b 04 c5 44 8a 30 80 	mov    -0x7fcf75bc(,%eax,8),%eax
8010204e:	85 c0                	test   %eax,%eax
80102050:	75 0a                	jne    8010205c <writei+0x49>
      return -1;
80102052:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102057:	e9 3b 01 00 00       	jmp    80102197 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010205c:	8b 45 08             	mov    0x8(%ebp),%eax
8010205f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102063:	98                   	cwtl   
80102064:	8b 04 c5 44 8a 30 80 	mov    -0x7fcf75bc(,%eax,8),%eax
8010206b:	8b 55 14             	mov    0x14(%ebp),%edx
8010206e:	83 ec 04             	sub    $0x4,%esp
80102071:	52                   	push   %edx
80102072:	ff 75 0c             	push   0xc(%ebp)
80102075:	ff 75 08             	push   0x8(%ebp)
80102078:	ff d0                	call   *%eax
8010207a:	83 c4 10             	add    $0x10,%esp
8010207d:	e9 15 01 00 00       	jmp    80102197 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
80102082:	8b 45 08             	mov    0x8(%ebp),%eax
80102085:	8b 40 58             	mov    0x58(%eax),%eax
80102088:	39 45 10             	cmp    %eax,0x10(%ebp)
8010208b:	77 0d                	ja     8010209a <writei+0x87>
8010208d:	8b 55 10             	mov    0x10(%ebp),%edx
80102090:	8b 45 14             	mov    0x14(%ebp),%eax
80102093:	01 d0                	add    %edx,%eax
80102095:	39 45 10             	cmp    %eax,0x10(%ebp)
80102098:	76 0a                	jbe    801020a4 <writei+0x91>
    return -1;
8010209a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010209f:	e9 f3 00 00 00       	jmp    80102197 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020a4:	8b 55 10             	mov    0x10(%ebp),%edx
801020a7:	8b 45 14             	mov    0x14(%ebp),%eax
801020aa:	01 d0                	add    %edx,%eax
801020ac:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020b1:	76 0a                	jbe    801020bd <writei+0xaa>
    return -1;
801020b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b8:	e9 da 00 00 00       	jmp    80102197 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020c4:	e9 97 00 00 00       	jmp    80102160 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020c9:	8b 45 10             	mov    0x10(%ebp),%eax
801020cc:	c1 e8 09             	shr    $0x9,%eax
801020cf:	83 ec 08             	sub    $0x8,%esp
801020d2:	50                   	push   %eax
801020d3:	ff 75 08             	push   0x8(%ebp)
801020d6:	e8 4d fb ff ff       	call   80101c28 <bmap>
801020db:	83 c4 10             	add    $0x10,%esp
801020de:	8b 55 08             	mov    0x8(%ebp),%edx
801020e1:	8b 12                	mov    (%edx),%edx
801020e3:	83 ec 08             	sub    $0x8,%esp
801020e6:	50                   	push   %eax
801020e7:	52                   	push   %edx
801020e8:	e8 14 e1 ff ff       	call   80100201 <bread>
801020ed:	83 c4 10             	add    $0x10,%esp
801020f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020f3:	8b 45 10             	mov    0x10(%ebp),%eax
801020f6:	25 ff 01 00 00       	and    $0x1ff,%eax
801020fb:	ba 00 02 00 00       	mov    $0x200,%edx
80102100:	29 c2                	sub    %eax,%edx
80102102:	8b 45 14             	mov    0x14(%ebp),%eax
80102105:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102108:	39 c2                	cmp    %eax,%edx
8010210a:	0f 46 c2             	cmovbe %edx,%eax
8010210d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102110:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102113:	8d 50 5c             	lea    0x5c(%eax),%edx
80102116:	8b 45 10             	mov    0x10(%ebp),%eax
80102119:	25 ff 01 00 00       	and    $0x1ff,%eax
8010211e:	01 d0                	add    %edx,%eax
80102120:	83 ec 04             	sub    $0x4,%esp
80102123:	ff 75 ec             	push   -0x14(%ebp)
80102126:	ff 75 0c             	push   0xc(%ebp)
80102129:	50                   	push   %eax
8010212a:	e8 de 2d 00 00       	call   80104f0d <memmove>
8010212f:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102132:	83 ec 0c             	sub    $0xc,%esp
80102135:	ff 75 f0             	push   -0x10(%ebp)
80102138:	e8 20 11 00 00       	call   8010325d <log_write>
8010213d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102140:	83 ec 0c             	sub    $0xc,%esp
80102143:	ff 75 f0             	push   -0x10(%ebp)
80102146:	e8 38 e1 ff ff       	call   80100283 <brelse>
8010214b:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010214e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102151:	01 45 f4             	add    %eax,-0xc(%ebp)
80102154:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102157:	01 45 10             	add    %eax,0x10(%ebp)
8010215a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010215d:	01 45 0c             	add    %eax,0xc(%ebp)
80102160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102163:	3b 45 14             	cmp    0x14(%ebp),%eax
80102166:	0f 82 5d ff ff ff    	jb     801020c9 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
8010216c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102170:	74 22                	je     80102194 <writei+0x181>
80102172:	8b 45 08             	mov    0x8(%ebp),%eax
80102175:	8b 40 58             	mov    0x58(%eax),%eax
80102178:	39 45 10             	cmp    %eax,0x10(%ebp)
8010217b:	76 17                	jbe    80102194 <writei+0x181>
    ip->size = off;
8010217d:	8b 45 08             	mov    0x8(%ebp),%eax
80102180:	8b 55 10             	mov    0x10(%ebp),%edx
80102183:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102186:	83 ec 0c             	sub    $0xc,%esp
80102189:	ff 75 08             	push   0x8(%ebp)
8010218c:	e8 64 f6 ff ff       	call   801017f5 <iupdate>
80102191:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102194:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102197:	c9                   	leave  
80102198:	c3                   	ret    

80102199 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102199:	55                   	push   %ebp
8010219a:	89 e5                	mov    %esp,%ebp
8010219c:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010219f:	83 ec 04             	sub    $0x4,%esp
801021a2:	6a 0e                	push   $0xe
801021a4:	ff 75 0c             	push   0xc(%ebp)
801021a7:	ff 75 08             	push   0x8(%ebp)
801021aa:	e8 f4 2d 00 00       	call   80104fa3 <strncmp>
801021af:	83 c4 10             	add    $0x10,%esp
}
801021b2:	c9                   	leave  
801021b3:	c3                   	ret    

801021b4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021b4:	55                   	push   %ebp
801021b5:	89 e5                	mov    %esp,%ebp
801021b7:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021ba:	8b 45 08             	mov    0x8(%ebp),%eax
801021bd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021c1:	66 83 f8 01          	cmp    $0x1,%ax
801021c5:	74 0d                	je     801021d4 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021c7:	83 ec 0c             	sub    $0xc,%esp
801021ca:	68 dd aa 10 80       	push   $0x8010aadd
801021cf:	e8 d5 e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021db:	eb 7b                	jmp    80102258 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021dd:	6a 10                	push   $0x10
801021df:	ff 75 f4             	push   -0xc(%ebp)
801021e2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021e5:	50                   	push   %eax
801021e6:	ff 75 08             	push   0x8(%ebp)
801021e9:	e8 d0 fc ff ff       	call   80101ebe <readi>
801021ee:	83 c4 10             	add    $0x10,%esp
801021f1:	83 f8 10             	cmp    $0x10,%eax
801021f4:	74 0d                	je     80102203 <dirlookup+0x4f>
      panic("dirlookup read");
801021f6:	83 ec 0c             	sub    $0xc,%esp
801021f9:	68 ef aa 10 80       	push   $0x8010aaef
801021fe:	e8 a6 e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
80102203:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102207:	66 85 c0             	test   %ax,%ax
8010220a:	74 47                	je     80102253 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010220c:	83 ec 08             	sub    $0x8,%esp
8010220f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102212:	83 c0 02             	add    $0x2,%eax
80102215:	50                   	push   %eax
80102216:	ff 75 0c             	push   0xc(%ebp)
80102219:	e8 7b ff ff ff       	call   80102199 <namecmp>
8010221e:	83 c4 10             	add    $0x10,%esp
80102221:	85 c0                	test   %eax,%eax
80102223:	75 2f                	jne    80102254 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102225:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102229:	74 08                	je     80102233 <dirlookup+0x7f>
        *poff = off;
8010222b:	8b 45 10             	mov    0x10(%ebp),%eax
8010222e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102231:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102233:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102237:	0f b7 c0             	movzwl %ax,%eax
8010223a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010223d:	8b 45 08             	mov    0x8(%ebp),%eax
80102240:	8b 00                	mov    (%eax),%eax
80102242:	83 ec 08             	sub    $0x8,%esp
80102245:	ff 75 f0             	push   -0x10(%ebp)
80102248:	50                   	push   %eax
80102249:	e8 68 f6 ff ff       	call   801018b6 <iget>
8010224e:	83 c4 10             	add    $0x10,%esp
80102251:	eb 19                	jmp    8010226c <dirlookup+0xb8>
      continue;
80102253:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102254:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102258:	8b 45 08             	mov    0x8(%ebp),%eax
8010225b:	8b 40 58             	mov    0x58(%eax),%eax
8010225e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102261:	0f 82 76 ff ff ff    	jb     801021dd <dirlookup+0x29>
    }
  }

  return 0;
80102267:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010226c:	c9                   	leave  
8010226d:	c3                   	ret    

8010226e <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010226e:	55                   	push   %ebp
8010226f:	89 e5                	mov    %esp,%ebp
80102271:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102274:	83 ec 04             	sub    $0x4,%esp
80102277:	6a 00                	push   $0x0
80102279:	ff 75 0c             	push   0xc(%ebp)
8010227c:	ff 75 08             	push   0x8(%ebp)
8010227f:	e8 30 ff ff ff       	call   801021b4 <dirlookup>
80102284:	83 c4 10             	add    $0x10,%esp
80102287:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010228a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010228e:	74 18                	je     801022a8 <dirlink+0x3a>
    iput(ip);
80102290:	83 ec 0c             	sub    $0xc,%esp
80102293:	ff 75 f0             	push   -0x10(%ebp)
80102296:	e8 98 f8 ff ff       	call   80101b33 <iput>
8010229b:	83 c4 10             	add    $0x10,%esp
    return -1;
8010229e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022a3:	e9 9c 00 00 00       	jmp    80102344 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022af:	eb 39                	jmp    801022ea <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b4:	6a 10                	push   $0x10
801022b6:	50                   	push   %eax
801022b7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ba:	50                   	push   %eax
801022bb:	ff 75 08             	push   0x8(%ebp)
801022be:	e8 fb fb ff ff       	call   80101ebe <readi>
801022c3:	83 c4 10             	add    $0x10,%esp
801022c6:	83 f8 10             	cmp    $0x10,%eax
801022c9:	74 0d                	je     801022d8 <dirlink+0x6a>
      panic("dirlink read");
801022cb:	83 ec 0c             	sub    $0xc,%esp
801022ce:	68 fe aa 10 80       	push   $0x8010aafe
801022d3:	e8 d1 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022d8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022dc:	66 85 c0             	test   %ax,%ax
801022df:	74 18                	je     801022f9 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e4:	83 c0 10             	add    $0x10,%eax
801022e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022ea:	8b 45 08             	mov    0x8(%ebp),%eax
801022ed:	8b 50 58             	mov    0x58(%eax),%edx
801022f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f3:	39 c2                	cmp    %eax,%edx
801022f5:	77 ba                	ja     801022b1 <dirlink+0x43>
801022f7:	eb 01                	jmp    801022fa <dirlink+0x8c>
      break;
801022f9:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801022fa:	83 ec 04             	sub    $0x4,%esp
801022fd:	6a 0e                	push   $0xe
801022ff:	ff 75 0c             	push   0xc(%ebp)
80102302:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102305:	83 c0 02             	add    $0x2,%eax
80102308:	50                   	push   %eax
80102309:	e8 eb 2c 00 00       	call   80104ff9 <strncpy>
8010230e:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102311:	8b 45 10             	mov    0x10(%ebp),%eax
80102314:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231b:	6a 10                	push   $0x10
8010231d:	50                   	push   %eax
8010231e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102321:	50                   	push   %eax
80102322:	ff 75 08             	push   0x8(%ebp)
80102325:	e8 e9 fc ff ff       	call   80102013 <writei>
8010232a:	83 c4 10             	add    $0x10,%esp
8010232d:	83 f8 10             	cmp    $0x10,%eax
80102330:	74 0d                	je     8010233f <dirlink+0xd1>
    panic("dirlink");
80102332:	83 ec 0c             	sub    $0xc,%esp
80102335:	68 0b ab 10 80       	push   $0x8010ab0b
8010233a:	e8 6a e2 ff ff       	call   801005a9 <panic>

  return 0;
8010233f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102344:	c9                   	leave  
80102345:	c3                   	ret    

80102346 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102346:	55                   	push   %ebp
80102347:	89 e5                	mov    %esp,%ebp
80102349:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010234c:	eb 04                	jmp    80102352 <skipelem+0xc>
    path++;
8010234e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102352:	8b 45 08             	mov    0x8(%ebp),%eax
80102355:	0f b6 00             	movzbl (%eax),%eax
80102358:	3c 2f                	cmp    $0x2f,%al
8010235a:	74 f2                	je     8010234e <skipelem+0x8>
  if(*path == 0)
8010235c:	8b 45 08             	mov    0x8(%ebp),%eax
8010235f:	0f b6 00             	movzbl (%eax),%eax
80102362:	84 c0                	test   %al,%al
80102364:	75 07                	jne    8010236d <skipelem+0x27>
    return 0;
80102366:	b8 00 00 00 00       	mov    $0x0,%eax
8010236b:	eb 77                	jmp    801023e4 <skipelem+0x9e>
  s = path;
8010236d:	8b 45 08             	mov    0x8(%ebp),%eax
80102370:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102373:	eb 04                	jmp    80102379 <skipelem+0x33>
    path++;
80102375:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102379:	8b 45 08             	mov    0x8(%ebp),%eax
8010237c:	0f b6 00             	movzbl (%eax),%eax
8010237f:	3c 2f                	cmp    $0x2f,%al
80102381:	74 0a                	je     8010238d <skipelem+0x47>
80102383:	8b 45 08             	mov    0x8(%ebp),%eax
80102386:	0f b6 00             	movzbl (%eax),%eax
80102389:	84 c0                	test   %al,%al
8010238b:	75 e8                	jne    80102375 <skipelem+0x2f>
  len = path - s;
8010238d:	8b 45 08             	mov    0x8(%ebp),%eax
80102390:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102393:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102396:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010239a:	7e 15                	jle    801023b1 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
8010239c:	83 ec 04             	sub    $0x4,%esp
8010239f:	6a 0e                	push   $0xe
801023a1:	ff 75 f4             	push   -0xc(%ebp)
801023a4:	ff 75 0c             	push   0xc(%ebp)
801023a7:	e8 61 2b 00 00       	call   80104f0d <memmove>
801023ac:	83 c4 10             	add    $0x10,%esp
801023af:	eb 26                	jmp    801023d7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023b4:	83 ec 04             	sub    $0x4,%esp
801023b7:	50                   	push   %eax
801023b8:	ff 75 f4             	push   -0xc(%ebp)
801023bb:	ff 75 0c             	push   0xc(%ebp)
801023be:	e8 4a 2b 00 00       	call   80104f0d <memmove>
801023c3:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801023cc:	01 d0                	add    %edx,%eax
801023ce:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023d1:	eb 04                	jmp    801023d7 <skipelem+0x91>
    path++;
801023d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023d7:	8b 45 08             	mov    0x8(%ebp),%eax
801023da:	0f b6 00             	movzbl (%eax),%eax
801023dd:	3c 2f                	cmp    $0x2f,%al
801023df:	74 f2                	je     801023d3 <skipelem+0x8d>
  return path;
801023e1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023e4:	c9                   	leave  
801023e5:	c3                   	ret    

801023e6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023e6:	55                   	push   %ebp
801023e7:	89 e5                	mov    %esp,%ebp
801023e9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023ec:	8b 45 08             	mov    0x8(%ebp),%eax
801023ef:	0f b6 00             	movzbl (%eax),%eax
801023f2:	3c 2f                	cmp    $0x2f,%al
801023f4:	75 17                	jne    8010240d <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801023f6:	83 ec 08             	sub    $0x8,%esp
801023f9:	6a 01                	push   $0x1
801023fb:	6a 01                	push   $0x1
801023fd:	e8 b4 f4 ff ff       	call   801018b6 <iget>
80102402:	83 c4 10             	add    $0x10,%esp
80102405:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102408:	e9 ba 00 00 00       	jmp    801024c7 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
8010240d:	e8 06 16 00 00       	call   80103a18 <myproc>
80102412:	8b 40 68             	mov    0x68(%eax),%eax
80102415:	83 ec 0c             	sub    $0xc,%esp
80102418:	50                   	push   %eax
80102419:	e8 7a f5 ff ff       	call   80101998 <idup>
8010241e:	83 c4 10             	add    $0x10,%esp
80102421:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102424:	e9 9e 00 00 00       	jmp    801024c7 <namex+0xe1>
    ilock(ip);
80102429:	83 ec 0c             	sub    $0xc,%esp
8010242c:	ff 75 f4             	push   -0xc(%ebp)
8010242f:	e8 9e f5 ff ff       	call   801019d2 <ilock>
80102434:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010243a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010243e:	66 83 f8 01          	cmp    $0x1,%ax
80102442:	74 18                	je     8010245c <namex+0x76>
      iunlockput(ip);
80102444:	83 ec 0c             	sub    $0xc,%esp
80102447:	ff 75 f4             	push   -0xc(%ebp)
8010244a:	e8 b4 f7 ff ff       	call   80101c03 <iunlockput>
8010244f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102452:	b8 00 00 00 00       	mov    $0x0,%eax
80102457:	e9 a7 00 00 00       	jmp    80102503 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010245c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102460:	74 20                	je     80102482 <namex+0x9c>
80102462:	8b 45 08             	mov    0x8(%ebp),%eax
80102465:	0f b6 00             	movzbl (%eax),%eax
80102468:	84 c0                	test   %al,%al
8010246a:	75 16                	jne    80102482 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
8010246c:	83 ec 0c             	sub    $0xc,%esp
8010246f:	ff 75 f4             	push   -0xc(%ebp)
80102472:	e8 6e f6 ff ff       	call   80101ae5 <iunlock>
80102477:	83 c4 10             	add    $0x10,%esp
      return ip;
8010247a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010247d:	e9 81 00 00 00       	jmp    80102503 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102482:	83 ec 04             	sub    $0x4,%esp
80102485:	6a 00                	push   $0x0
80102487:	ff 75 10             	push   0x10(%ebp)
8010248a:	ff 75 f4             	push   -0xc(%ebp)
8010248d:	e8 22 fd ff ff       	call   801021b4 <dirlookup>
80102492:	83 c4 10             	add    $0x10,%esp
80102495:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102498:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010249c:	75 15                	jne    801024b3 <namex+0xcd>
      iunlockput(ip);
8010249e:	83 ec 0c             	sub    $0xc,%esp
801024a1:	ff 75 f4             	push   -0xc(%ebp)
801024a4:	e8 5a f7 ff ff       	call   80101c03 <iunlockput>
801024a9:	83 c4 10             	add    $0x10,%esp
      return 0;
801024ac:	b8 00 00 00 00       	mov    $0x0,%eax
801024b1:	eb 50                	jmp    80102503 <namex+0x11d>
    }
    iunlockput(ip);
801024b3:	83 ec 0c             	sub    $0xc,%esp
801024b6:	ff 75 f4             	push   -0xc(%ebp)
801024b9:	e8 45 f7 ff ff       	call   80101c03 <iunlockput>
801024be:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024c7:	83 ec 08             	sub    $0x8,%esp
801024ca:	ff 75 10             	push   0x10(%ebp)
801024cd:	ff 75 08             	push   0x8(%ebp)
801024d0:	e8 71 fe ff ff       	call   80102346 <skipelem>
801024d5:	83 c4 10             	add    $0x10,%esp
801024d8:	89 45 08             	mov    %eax,0x8(%ebp)
801024db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024df:	0f 85 44 ff ff ff    	jne    80102429 <namex+0x43>
  }
  if(nameiparent){
801024e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024e9:	74 15                	je     80102500 <namex+0x11a>
    iput(ip);
801024eb:	83 ec 0c             	sub    $0xc,%esp
801024ee:	ff 75 f4             	push   -0xc(%ebp)
801024f1:	e8 3d f6 ff ff       	call   80101b33 <iput>
801024f6:	83 c4 10             	add    $0x10,%esp
    return 0;
801024f9:	b8 00 00 00 00       	mov    $0x0,%eax
801024fe:	eb 03                	jmp    80102503 <namex+0x11d>
  }
  return ip;
80102500:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102503:	c9                   	leave  
80102504:	c3                   	ret    

80102505 <namei>:

struct inode*
namei(char *path)
{
80102505:	55                   	push   %ebp
80102506:	89 e5                	mov    %esp,%ebp
80102508:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010250b:	83 ec 04             	sub    $0x4,%esp
8010250e:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102511:	50                   	push   %eax
80102512:	6a 00                	push   $0x0
80102514:	ff 75 08             	push   0x8(%ebp)
80102517:	e8 ca fe ff ff       	call   801023e6 <namex>
8010251c:	83 c4 10             	add    $0x10,%esp
}
8010251f:	c9                   	leave  
80102520:	c3                   	ret    

80102521 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102521:	55                   	push   %ebp
80102522:	89 e5                	mov    %esp,%ebp
80102524:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102527:	83 ec 04             	sub    $0x4,%esp
8010252a:	ff 75 0c             	push   0xc(%ebp)
8010252d:	6a 01                	push   $0x1
8010252f:	ff 75 08             	push   0x8(%ebp)
80102532:	e8 af fe ff ff       	call   801023e6 <namex>
80102537:	83 c4 10             	add    $0x10,%esp
}
8010253a:	c9                   	leave  
8010253b:	c3                   	ret    

8010253c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010253c:	55                   	push   %ebp
8010253d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010253f:	a1 b4 b0 30 80       	mov    0x8030b0b4,%eax
80102544:	8b 55 08             	mov    0x8(%ebp),%edx
80102547:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102549:	a1 b4 b0 30 80       	mov    0x8030b0b4,%eax
8010254e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102551:	5d                   	pop    %ebp
80102552:	c3                   	ret    

80102553 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102553:	55                   	push   %ebp
80102554:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102556:	a1 b4 b0 30 80       	mov    0x8030b0b4,%eax
8010255b:	8b 55 08             	mov    0x8(%ebp),%edx
8010255e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102560:	a1 b4 b0 30 80       	mov    0x8030b0b4,%eax
80102565:	8b 55 0c             	mov    0xc(%ebp),%edx
80102568:	89 50 10             	mov    %edx,0x10(%eax)
}
8010256b:	90                   	nop
8010256c:	5d                   	pop    %ebp
8010256d:	c3                   	ret    

8010256e <ioapicinit>:

void
ioapicinit(void)
{
8010256e:	55                   	push   %ebp
8010256f:	89 e5                	mov    %esp,%ebp
80102571:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102574:	c7 05 b4 b0 30 80 00 	movl   $0xfec00000,0x8030b0b4
8010257b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010257e:	6a 01                	push   $0x1
80102580:	e8 b7 ff ff ff       	call   8010253c <ioapicread>
80102585:	83 c4 04             	add    $0x4,%esp
80102588:	c1 e8 10             	shr    $0x10,%eax
8010258b:	25 ff 00 00 00       	and    $0xff,%eax
80102590:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102593:	6a 00                	push   $0x0
80102595:	e8 a2 ff ff ff       	call   8010253c <ioapicread>
8010259a:	83 c4 04             	add    $0x4,%esp
8010259d:	c1 e8 18             	shr    $0x18,%eax
801025a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025a3:	0f b6 05 54 e7 30 80 	movzbl 0x8030e754,%eax
801025aa:	0f b6 c0             	movzbl %al,%eax
801025ad:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025b0:	74 10                	je     801025c2 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025b2:	83 ec 0c             	sub    $0xc,%esp
801025b5:	68 14 ab 10 80       	push   $0x8010ab14
801025ba:	e8 35 de ff ff       	call   801003f4 <cprintf>
801025bf:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025c9:	eb 3f                	jmp    8010260a <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ce:	83 c0 20             	add    $0x20,%eax
801025d1:	0d 00 00 01 00       	or     $0x10000,%eax
801025d6:	89 c2                	mov    %eax,%edx
801025d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025db:	83 c0 08             	add    $0x8,%eax
801025de:	01 c0                	add    %eax,%eax
801025e0:	83 ec 08             	sub    $0x8,%esp
801025e3:	52                   	push   %edx
801025e4:	50                   	push   %eax
801025e5:	e8 69 ff ff ff       	call   80102553 <ioapicwrite>
801025ea:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801025ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f0:	83 c0 08             	add    $0x8,%eax
801025f3:	01 c0                	add    %eax,%eax
801025f5:	83 c0 01             	add    $0x1,%eax
801025f8:	83 ec 08             	sub    $0x8,%esp
801025fb:	6a 00                	push   $0x0
801025fd:	50                   	push   %eax
801025fe:	e8 50 ff ff ff       	call   80102553 <ioapicwrite>
80102603:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102606:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010260a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010260d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102610:	7e b9                	jle    801025cb <ioapicinit+0x5d>
  }
}
80102612:	90                   	nop
80102613:	90                   	nop
80102614:	c9                   	leave  
80102615:	c3                   	ret    

80102616 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102616:	55                   	push   %ebp
80102617:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102619:	8b 45 08             	mov    0x8(%ebp),%eax
8010261c:	83 c0 20             	add    $0x20,%eax
8010261f:	89 c2                	mov    %eax,%edx
80102621:	8b 45 08             	mov    0x8(%ebp),%eax
80102624:	83 c0 08             	add    $0x8,%eax
80102627:	01 c0                	add    %eax,%eax
80102629:	52                   	push   %edx
8010262a:	50                   	push   %eax
8010262b:	e8 23 ff ff ff       	call   80102553 <ioapicwrite>
80102630:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102633:	8b 45 0c             	mov    0xc(%ebp),%eax
80102636:	c1 e0 18             	shl    $0x18,%eax
80102639:	89 c2                	mov    %eax,%edx
8010263b:	8b 45 08             	mov    0x8(%ebp),%eax
8010263e:	83 c0 08             	add    $0x8,%eax
80102641:	01 c0                	add    %eax,%eax
80102643:	83 c0 01             	add    $0x1,%eax
80102646:	52                   	push   %edx
80102647:	50                   	push   %eax
80102648:	e8 06 ff ff ff       	call   80102553 <ioapicwrite>
8010264d:	83 c4 08             	add    $0x8,%esp
}
80102650:	90                   	nop
80102651:	c9                   	leave  
80102652:	c3                   	ret    

80102653 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102653:	55                   	push   %ebp
80102654:	89 e5                	mov    %esp,%ebp
80102656:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102659:	83 ec 08             	sub    $0x8,%esp
8010265c:	68 46 ab 10 80       	push   $0x8010ab46
80102661:	68 c0 b0 30 80       	push   $0x8030b0c0
80102666:	e8 4b 25 00 00       	call   80104bb6 <initlock>
8010266b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010266e:	c7 05 f4 b0 30 80 00 	movl   $0x0,0x8030b0f4
80102675:	00 00 00 
  freerange(vstart, vend);
80102678:	83 ec 08             	sub    $0x8,%esp
8010267b:	ff 75 0c             	push   0xc(%ebp)
8010267e:	ff 75 08             	push   0x8(%ebp)
80102681:	e8 2a 00 00 00       	call   801026b0 <freerange>
80102686:	83 c4 10             	add    $0x10,%esp
}
80102689:	90                   	nop
8010268a:	c9                   	leave  
8010268b:	c3                   	ret    

8010268c <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010268c:	55                   	push   %ebp
8010268d:	89 e5                	mov    %esp,%ebp
8010268f:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102692:	83 ec 08             	sub    $0x8,%esp
80102695:	ff 75 0c             	push   0xc(%ebp)
80102698:	ff 75 08             	push   0x8(%ebp)
8010269b:	e8 10 00 00 00       	call   801026b0 <freerange>
801026a0:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026a3:	c7 05 f4 b0 30 80 01 	movl   $0x1,0x8030b0f4
801026aa:	00 00 00 
}
801026ad:	90                   	nop
801026ae:	c9                   	leave  
801026af:	c3                   	ret    

801026b0 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026b0:	55                   	push   %ebp
801026b1:	89 e5                	mov    %esp,%ebp
801026b3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026b6:	8b 45 08             	mov    0x8(%ebp),%eax
801026b9:	05 ff 0f 00 00       	add    $0xfff,%eax
801026be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026c6:	eb 15                	jmp    801026dd <freerange+0x2d>
    kfree(p);
801026c8:	83 ec 0c             	sub    $0xc,%esp
801026cb:	ff 75 f4             	push   -0xc(%ebp)
801026ce:	e8 1b 00 00 00       	call   801026ee <kfree>
801026d3:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026d6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e0:	05 00 10 00 00       	add    $0x1000,%eax
801026e5:	39 45 0c             	cmp    %eax,0xc(%ebp)
801026e8:	73 de                	jae    801026c8 <freerange+0x18>
}
801026ea:	90                   	nop
801026eb:	90                   	nop
801026ec:	c9                   	leave  
801026ed:	c3                   	ret    

801026ee <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801026ee:	55                   	push   %ebp
801026ef:	89 e5                	mov    %esp,%ebp
801026f1:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801026f4:	8b 45 08             	mov    0x8(%ebp),%eax
801026f7:	25 ff 0f 00 00       	and    $0xfff,%eax
801026fc:	85 c0                	test   %eax,%eax
801026fe:	75 18                	jne    80102718 <kfree+0x2a>
80102700:	81 7d 08 00 00 31 80 	cmpl   $0x80310000,0x8(%ebp)
80102707:	72 0f                	jb     80102718 <kfree+0x2a>
80102709:	8b 45 08             	mov    0x8(%ebp),%eax
8010270c:	05 00 00 00 80       	add    $0x80000000,%eax
80102711:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102716:	76 0d                	jbe    80102725 <kfree+0x37>
    panic("kfree");
80102718:	83 ec 0c             	sub    $0xc,%esp
8010271b:	68 4b ab 10 80       	push   $0x8010ab4b
80102720:	e8 84 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102725:	83 ec 04             	sub    $0x4,%esp
80102728:	68 00 10 00 00       	push   $0x1000
8010272d:	6a 01                	push   $0x1
8010272f:	ff 75 08             	push   0x8(%ebp)
80102732:	e8 17 27 00 00       	call   80104e4e <memset>
80102737:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010273a:	a1 f4 b0 30 80       	mov    0x8030b0f4,%eax
8010273f:	85 c0                	test   %eax,%eax
80102741:	74 10                	je     80102753 <kfree+0x65>
    acquire(&kmem.lock);
80102743:	83 ec 0c             	sub    $0xc,%esp
80102746:	68 c0 b0 30 80       	push   $0x8030b0c0
8010274b:	e8 88 24 00 00       	call   80104bd8 <acquire>
80102750:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102753:	8b 45 08             	mov    0x8(%ebp),%eax
80102756:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102759:	8b 15 f8 b0 30 80    	mov    0x8030b0f8,%edx
8010275f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102762:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102767:	a3 f8 b0 30 80       	mov    %eax,0x8030b0f8
  if(kmem.use_lock)
8010276c:	a1 f4 b0 30 80       	mov    0x8030b0f4,%eax
80102771:	85 c0                	test   %eax,%eax
80102773:	74 10                	je     80102785 <kfree+0x97>
    release(&kmem.lock);
80102775:	83 ec 0c             	sub    $0xc,%esp
80102778:	68 c0 b0 30 80       	push   $0x8030b0c0
8010277d:	e8 c4 24 00 00       	call   80104c46 <release>
80102782:	83 c4 10             	add    $0x10,%esp
}
80102785:	90                   	nop
80102786:	c9                   	leave  
80102787:	c3                   	ret    

80102788 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102788:	55                   	push   %ebp
80102789:	89 e5                	mov    %esp,%ebp
8010278b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
8010278e:	a1 f4 b0 30 80       	mov    0x8030b0f4,%eax
80102793:	85 c0                	test   %eax,%eax
80102795:	74 10                	je     801027a7 <kalloc+0x1f>
    acquire(&kmem.lock);
80102797:	83 ec 0c             	sub    $0xc,%esp
8010279a:	68 c0 b0 30 80       	push   $0x8030b0c0
8010279f:	e8 34 24 00 00       	call   80104bd8 <acquire>
801027a4:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027a7:	a1 f8 b0 30 80       	mov    0x8030b0f8,%eax
801027ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027b3:	74 0a                	je     801027bf <kalloc+0x37>
    kmem.freelist = r->next;
801027b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027b8:	8b 00                	mov    (%eax),%eax
801027ba:	a3 f8 b0 30 80       	mov    %eax,0x8030b0f8
  if(kmem.use_lock)
801027bf:	a1 f4 b0 30 80       	mov    0x8030b0f4,%eax
801027c4:	85 c0                	test   %eax,%eax
801027c6:	74 10                	je     801027d8 <kalloc+0x50>
    release(&kmem.lock);
801027c8:	83 ec 0c             	sub    $0xc,%esp
801027cb:	68 c0 b0 30 80       	push   $0x8030b0c0
801027d0:	e8 71 24 00 00       	call   80104c46 <release>
801027d5:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027db:	c9                   	leave  
801027dc:	c3                   	ret    

801027dd <inb>:
{
801027dd:	55                   	push   %ebp
801027de:	89 e5                	mov    %esp,%ebp
801027e0:	83 ec 14             	sub    $0x14,%esp
801027e3:	8b 45 08             	mov    0x8(%ebp),%eax
801027e6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027ea:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801027ee:	89 c2                	mov    %eax,%edx
801027f0:	ec                   	in     (%dx),%al
801027f1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801027f4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801027f8:	c9                   	leave  
801027f9:	c3                   	ret    

801027fa <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801027fa:	55                   	push   %ebp
801027fb:	89 e5                	mov    %esp,%ebp
801027fd:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102800:	6a 64                	push   $0x64
80102802:	e8 d6 ff ff ff       	call   801027dd <inb>
80102807:	83 c4 04             	add    $0x4,%esp
8010280a:	0f b6 c0             	movzbl %al,%eax
8010280d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102813:	83 e0 01             	and    $0x1,%eax
80102816:	85 c0                	test   %eax,%eax
80102818:	75 0a                	jne    80102824 <kbdgetc+0x2a>
    return -1;
8010281a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010281f:	e9 23 01 00 00       	jmp    80102947 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102824:	6a 60                	push   $0x60
80102826:	e8 b2 ff ff ff       	call   801027dd <inb>
8010282b:	83 c4 04             	add    $0x4,%esp
8010282e:	0f b6 c0             	movzbl %al,%eax
80102831:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102834:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010283b:	75 17                	jne    80102854 <kbdgetc+0x5a>
    shift |= E0ESC;
8010283d:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
80102842:	83 c8 40             	or     $0x40,%eax
80102845:	a3 fc b0 30 80       	mov    %eax,0x8030b0fc
    return 0;
8010284a:	b8 00 00 00 00       	mov    $0x0,%eax
8010284f:	e9 f3 00 00 00       	jmp    80102947 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102854:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102857:	25 80 00 00 00       	and    $0x80,%eax
8010285c:	85 c0                	test   %eax,%eax
8010285e:	74 45                	je     801028a5 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102860:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
80102865:	83 e0 40             	and    $0x40,%eax
80102868:	85 c0                	test   %eax,%eax
8010286a:	75 08                	jne    80102874 <kbdgetc+0x7a>
8010286c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010286f:	83 e0 7f             	and    $0x7f,%eax
80102872:	eb 03                	jmp    80102877 <kbdgetc+0x7d>
80102874:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102877:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010287a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010287d:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102882:	0f b6 00             	movzbl (%eax),%eax
80102885:	83 c8 40             	or     $0x40,%eax
80102888:	0f b6 c0             	movzbl %al,%eax
8010288b:	f7 d0                	not    %eax
8010288d:	89 c2                	mov    %eax,%edx
8010288f:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
80102894:	21 d0                	and    %edx,%eax
80102896:	a3 fc b0 30 80       	mov    %eax,0x8030b0fc
    return 0;
8010289b:	b8 00 00 00 00       	mov    $0x0,%eax
801028a0:	e9 a2 00 00 00       	jmp    80102947 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028a5:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
801028aa:	83 e0 40             	and    $0x40,%eax
801028ad:	85 c0                	test   %eax,%eax
801028af:	74 14                	je     801028c5 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028b1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028b8:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
801028bd:	83 e0 bf             	and    $0xffffffbf,%eax
801028c0:	a3 fc b0 30 80       	mov    %eax,0x8030b0fc
  }

  shift |= shiftcode[data];
801028c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028c8:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028cd:	0f b6 00             	movzbl (%eax),%eax
801028d0:	0f b6 d0             	movzbl %al,%edx
801028d3:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
801028d8:	09 d0                	or     %edx,%eax
801028da:	a3 fc b0 30 80       	mov    %eax,0x8030b0fc
  shift ^= togglecode[data];
801028df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e2:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028e7:	0f b6 00             	movzbl (%eax),%eax
801028ea:	0f b6 d0             	movzbl %al,%edx
801028ed:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
801028f2:	31 d0                	xor    %edx,%eax
801028f4:	a3 fc b0 30 80       	mov    %eax,0x8030b0fc
  c = charcode[shift & (CTL | SHIFT)][data];
801028f9:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
801028fe:	83 e0 03             	and    $0x3,%eax
80102901:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102908:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010290b:	01 d0                	add    %edx,%eax
8010290d:	0f b6 00             	movzbl (%eax),%eax
80102910:	0f b6 c0             	movzbl %al,%eax
80102913:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102916:	a1 fc b0 30 80       	mov    0x8030b0fc,%eax
8010291b:	83 e0 08             	and    $0x8,%eax
8010291e:	85 c0                	test   %eax,%eax
80102920:	74 22                	je     80102944 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102922:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102926:	76 0c                	jbe    80102934 <kbdgetc+0x13a>
80102928:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010292c:	77 06                	ja     80102934 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010292e:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102932:	eb 10                	jmp    80102944 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102934:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102938:	76 0a                	jbe    80102944 <kbdgetc+0x14a>
8010293a:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010293e:	77 04                	ja     80102944 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102940:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102944:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102947:	c9                   	leave  
80102948:	c3                   	ret    

80102949 <kbdintr>:

void
kbdintr(void)
{
80102949:	55                   	push   %ebp
8010294a:	89 e5                	mov    %esp,%ebp
8010294c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
8010294f:	83 ec 0c             	sub    $0xc,%esp
80102952:	68 fa 27 10 80       	push   $0x801027fa
80102957:	e8 7a de ff ff       	call   801007d6 <consoleintr>
8010295c:	83 c4 10             	add    $0x10,%esp
}
8010295f:	90                   	nop
80102960:	c9                   	leave  
80102961:	c3                   	ret    

80102962 <inb>:
{
80102962:	55                   	push   %ebp
80102963:	89 e5                	mov    %esp,%ebp
80102965:	83 ec 14             	sub    $0x14,%esp
80102968:	8b 45 08             	mov    0x8(%ebp),%eax
8010296b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010296f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102973:	89 c2                	mov    %eax,%edx
80102975:	ec                   	in     (%dx),%al
80102976:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102979:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010297d:	c9                   	leave  
8010297e:	c3                   	ret    

8010297f <outb>:
{
8010297f:	55                   	push   %ebp
80102980:	89 e5                	mov    %esp,%ebp
80102982:	83 ec 08             	sub    $0x8,%esp
80102985:	8b 45 08             	mov    0x8(%ebp),%eax
80102988:	8b 55 0c             	mov    0xc(%ebp),%edx
8010298b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010298f:	89 d0                	mov    %edx,%eax
80102991:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102994:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102998:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010299c:	ee                   	out    %al,(%dx)
}
8010299d:	90                   	nop
8010299e:	c9                   	leave  
8010299f:	c3                   	ret    

801029a0 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029a0:	55                   	push   %ebp
801029a1:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029a3:	8b 15 00 b1 30 80    	mov    0x8030b100,%edx
801029a9:	8b 45 08             	mov    0x8(%ebp),%eax
801029ac:	c1 e0 02             	shl    $0x2,%eax
801029af:	01 c2                	add    %eax,%edx
801029b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801029b4:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029b6:	a1 00 b1 30 80       	mov    0x8030b100,%eax
801029bb:	83 c0 20             	add    $0x20,%eax
801029be:	8b 00                	mov    (%eax),%eax
}
801029c0:	90                   	nop
801029c1:	5d                   	pop    %ebp
801029c2:	c3                   	ret    

801029c3 <lapicinit>:

void
lapicinit(void)
{
801029c3:	55                   	push   %ebp
801029c4:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029c6:	a1 00 b1 30 80       	mov    0x8030b100,%eax
801029cb:	85 c0                	test   %eax,%eax
801029cd:	0f 84 0c 01 00 00    	je     80102adf <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029d3:	68 3f 01 00 00       	push   $0x13f
801029d8:	6a 3c                	push   $0x3c
801029da:	e8 c1 ff ff ff       	call   801029a0 <lapicw>
801029df:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029e2:	6a 0b                	push   $0xb
801029e4:	68 f8 00 00 00       	push   $0xf8
801029e9:	e8 b2 ff ff ff       	call   801029a0 <lapicw>
801029ee:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801029f1:	68 20 00 02 00       	push   $0x20020
801029f6:	68 c8 00 00 00       	push   $0xc8
801029fb:	e8 a0 ff ff ff       	call   801029a0 <lapicw>
80102a00:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a03:	68 80 96 98 00       	push   $0x989680
80102a08:	68 e0 00 00 00       	push   $0xe0
80102a0d:	e8 8e ff ff ff       	call   801029a0 <lapicw>
80102a12:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a15:	68 00 00 01 00       	push   $0x10000
80102a1a:	68 d4 00 00 00       	push   $0xd4
80102a1f:	e8 7c ff ff ff       	call   801029a0 <lapicw>
80102a24:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a27:	68 00 00 01 00       	push   $0x10000
80102a2c:	68 d8 00 00 00       	push   $0xd8
80102a31:	e8 6a ff ff ff       	call   801029a0 <lapicw>
80102a36:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a39:	a1 00 b1 30 80       	mov    0x8030b100,%eax
80102a3e:	83 c0 30             	add    $0x30,%eax
80102a41:	8b 00                	mov    (%eax),%eax
80102a43:	c1 e8 10             	shr    $0x10,%eax
80102a46:	25 fc 00 00 00       	and    $0xfc,%eax
80102a4b:	85 c0                	test   %eax,%eax
80102a4d:	74 12                	je     80102a61 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a4f:	68 00 00 01 00       	push   $0x10000
80102a54:	68 d0 00 00 00       	push   $0xd0
80102a59:	e8 42 ff ff ff       	call   801029a0 <lapicw>
80102a5e:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a61:	6a 33                	push   $0x33
80102a63:	68 dc 00 00 00       	push   $0xdc
80102a68:	e8 33 ff ff ff       	call   801029a0 <lapicw>
80102a6d:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a70:	6a 00                	push   $0x0
80102a72:	68 a0 00 00 00       	push   $0xa0
80102a77:	e8 24 ff ff ff       	call   801029a0 <lapicw>
80102a7c:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a7f:	6a 00                	push   $0x0
80102a81:	68 a0 00 00 00       	push   $0xa0
80102a86:	e8 15 ff ff ff       	call   801029a0 <lapicw>
80102a8b:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102a8e:	6a 00                	push   $0x0
80102a90:	6a 2c                	push   $0x2c
80102a92:	e8 09 ff ff ff       	call   801029a0 <lapicw>
80102a97:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102a9a:	6a 00                	push   $0x0
80102a9c:	68 c4 00 00 00       	push   $0xc4
80102aa1:	e8 fa fe ff ff       	call   801029a0 <lapicw>
80102aa6:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102aa9:	68 00 85 08 00       	push   $0x88500
80102aae:	68 c0 00 00 00       	push   $0xc0
80102ab3:	e8 e8 fe ff ff       	call   801029a0 <lapicw>
80102ab8:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102abb:	90                   	nop
80102abc:	a1 00 b1 30 80       	mov    0x8030b100,%eax
80102ac1:	05 00 03 00 00       	add    $0x300,%eax
80102ac6:	8b 00                	mov    (%eax),%eax
80102ac8:	25 00 10 00 00       	and    $0x1000,%eax
80102acd:	85 c0                	test   %eax,%eax
80102acf:	75 eb                	jne    80102abc <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ad1:	6a 00                	push   $0x0
80102ad3:	6a 20                	push   $0x20
80102ad5:	e8 c6 fe ff ff       	call   801029a0 <lapicw>
80102ada:	83 c4 08             	add    $0x8,%esp
80102add:	eb 01                	jmp    80102ae0 <lapicinit+0x11d>
    return;
80102adf:	90                   	nop
}
80102ae0:	c9                   	leave  
80102ae1:	c3                   	ret    

80102ae2 <lapicid>:

int
lapicid(void)
{
80102ae2:	55                   	push   %ebp
80102ae3:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102ae5:	a1 00 b1 30 80       	mov    0x8030b100,%eax
80102aea:	85 c0                	test   %eax,%eax
80102aec:	75 07                	jne    80102af5 <lapicid+0x13>
    return 0;
80102aee:	b8 00 00 00 00       	mov    $0x0,%eax
80102af3:	eb 0d                	jmp    80102b02 <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102af5:	a1 00 b1 30 80       	mov    0x8030b100,%eax
80102afa:	83 c0 20             	add    $0x20,%eax
80102afd:	8b 00                	mov    (%eax),%eax
80102aff:	c1 e8 18             	shr    $0x18,%eax
}
80102b02:	5d                   	pop    %ebp
80102b03:	c3                   	ret    

80102b04 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b04:	55                   	push   %ebp
80102b05:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b07:	a1 00 b1 30 80       	mov    0x8030b100,%eax
80102b0c:	85 c0                	test   %eax,%eax
80102b0e:	74 0c                	je     80102b1c <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b10:	6a 00                	push   $0x0
80102b12:	6a 2c                	push   $0x2c
80102b14:	e8 87 fe ff ff       	call   801029a0 <lapicw>
80102b19:	83 c4 08             	add    $0x8,%esp
}
80102b1c:	90                   	nop
80102b1d:	c9                   	leave  
80102b1e:	c3                   	ret    

80102b1f <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b1f:	55                   	push   %ebp
80102b20:	89 e5                	mov    %esp,%ebp
}
80102b22:	90                   	nop
80102b23:	5d                   	pop    %ebp
80102b24:	c3                   	ret    

80102b25 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b25:	55                   	push   %ebp
80102b26:	89 e5                	mov    %esp,%ebp
80102b28:	83 ec 14             	sub    $0x14,%esp
80102b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2e:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b31:	6a 0f                	push   $0xf
80102b33:	6a 70                	push   $0x70
80102b35:	e8 45 fe ff ff       	call   8010297f <outb>
80102b3a:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b3d:	6a 0a                	push   $0xa
80102b3f:	6a 71                	push   $0x71
80102b41:	e8 39 fe ff ff       	call   8010297f <outb>
80102b46:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b49:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b50:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b53:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b58:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b5b:	c1 e8 04             	shr    $0x4,%eax
80102b5e:	89 c2                	mov    %eax,%edx
80102b60:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b63:	83 c0 02             	add    $0x2,%eax
80102b66:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b69:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b6d:	c1 e0 18             	shl    $0x18,%eax
80102b70:	50                   	push   %eax
80102b71:	68 c4 00 00 00       	push   $0xc4
80102b76:	e8 25 fe ff ff       	call   801029a0 <lapicw>
80102b7b:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b7e:	68 00 c5 00 00       	push   $0xc500
80102b83:	68 c0 00 00 00       	push   $0xc0
80102b88:	e8 13 fe ff ff       	call   801029a0 <lapicw>
80102b8d:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102b90:	68 c8 00 00 00       	push   $0xc8
80102b95:	e8 85 ff ff ff       	call   80102b1f <microdelay>
80102b9a:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102b9d:	68 00 85 00 00       	push   $0x8500
80102ba2:	68 c0 00 00 00       	push   $0xc0
80102ba7:	e8 f4 fd ff ff       	call   801029a0 <lapicw>
80102bac:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102baf:	6a 64                	push   $0x64
80102bb1:	e8 69 ff ff ff       	call   80102b1f <microdelay>
80102bb6:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bb9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bc0:	eb 3d                	jmp    80102bff <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bc2:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bc6:	c1 e0 18             	shl    $0x18,%eax
80102bc9:	50                   	push   %eax
80102bca:	68 c4 00 00 00       	push   $0xc4
80102bcf:	e8 cc fd ff ff       	call   801029a0 <lapicw>
80102bd4:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bda:	c1 e8 0c             	shr    $0xc,%eax
80102bdd:	80 cc 06             	or     $0x6,%ah
80102be0:	50                   	push   %eax
80102be1:	68 c0 00 00 00       	push   $0xc0
80102be6:	e8 b5 fd ff ff       	call   801029a0 <lapicw>
80102beb:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102bee:	68 c8 00 00 00       	push   $0xc8
80102bf3:	e8 27 ff ff ff       	call   80102b1f <microdelay>
80102bf8:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102bfb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102bff:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c03:	7e bd                	jle    80102bc2 <lapicstartap+0x9d>
  }
}
80102c05:	90                   	nop
80102c06:	90                   	nop
80102c07:	c9                   	leave  
80102c08:	c3                   	ret    

80102c09 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c09:	55                   	push   %ebp
80102c0a:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0f:	0f b6 c0             	movzbl %al,%eax
80102c12:	50                   	push   %eax
80102c13:	6a 70                	push   $0x70
80102c15:	e8 65 fd ff ff       	call   8010297f <outb>
80102c1a:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c1d:	68 c8 00 00 00       	push   $0xc8
80102c22:	e8 f8 fe ff ff       	call   80102b1f <microdelay>
80102c27:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c2a:	6a 71                	push   $0x71
80102c2c:	e8 31 fd ff ff       	call   80102962 <inb>
80102c31:	83 c4 04             	add    $0x4,%esp
80102c34:	0f b6 c0             	movzbl %al,%eax
}
80102c37:	c9                   	leave  
80102c38:	c3                   	ret    

80102c39 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c39:	55                   	push   %ebp
80102c3a:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c3c:	6a 00                	push   $0x0
80102c3e:	e8 c6 ff ff ff       	call   80102c09 <cmos_read>
80102c43:	83 c4 04             	add    $0x4,%esp
80102c46:	8b 55 08             	mov    0x8(%ebp),%edx
80102c49:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c4b:	6a 02                	push   $0x2
80102c4d:	e8 b7 ff ff ff       	call   80102c09 <cmos_read>
80102c52:	83 c4 04             	add    $0x4,%esp
80102c55:	8b 55 08             	mov    0x8(%ebp),%edx
80102c58:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c5b:	6a 04                	push   $0x4
80102c5d:	e8 a7 ff ff ff       	call   80102c09 <cmos_read>
80102c62:	83 c4 04             	add    $0x4,%esp
80102c65:	8b 55 08             	mov    0x8(%ebp),%edx
80102c68:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c6b:	6a 07                	push   $0x7
80102c6d:	e8 97 ff ff ff       	call   80102c09 <cmos_read>
80102c72:	83 c4 04             	add    $0x4,%esp
80102c75:	8b 55 08             	mov    0x8(%ebp),%edx
80102c78:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c7b:	6a 08                	push   $0x8
80102c7d:	e8 87 ff ff ff       	call   80102c09 <cmos_read>
80102c82:	83 c4 04             	add    $0x4,%esp
80102c85:	8b 55 08             	mov    0x8(%ebp),%edx
80102c88:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102c8b:	6a 09                	push   $0x9
80102c8d:	e8 77 ff ff ff       	call   80102c09 <cmos_read>
80102c92:	83 c4 04             	add    $0x4,%esp
80102c95:	8b 55 08             	mov    0x8(%ebp),%edx
80102c98:	89 42 14             	mov    %eax,0x14(%edx)
}
80102c9b:	90                   	nop
80102c9c:	c9                   	leave  
80102c9d:	c3                   	ret    

80102c9e <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102c9e:	55                   	push   %ebp
80102c9f:	89 e5                	mov    %esp,%ebp
80102ca1:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102ca4:	6a 0b                	push   $0xb
80102ca6:	e8 5e ff ff ff       	call   80102c09 <cmos_read>
80102cab:	83 c4 04             	add    $0x4,%esp
80102cae:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb4:	83 e0 04             	and    $0x4,%eax
80102cb7:	85 c0                	test   %eax,%eax
80102cb9:	0f 94 c0             	sete   %al
80102cbc:	0f b6 c0             	movzbl %al,%eax
80102cbf:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cc2:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cc5:	50                   	push   %eax
80102cc6:	e8 6e ff ff ff       	call   80102c39 <fill_rtcdate>
80102ccb:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102cce:	6a 0a                	push   $0xa
80102cd0:	e8 34 ff ff ff       	call   80102c09 <cmos_read>
80102cd5:	83 c4 04             	add    $0x4,%esp
80102cd8:	25 80 00 00 00       	and    $0x80,%eax
80102cdd:	85 c0                	test   %eax,%eax
80102cdf:	75 27                	jne    80102d08 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102ce1:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102ce4:	50                   	push   %eax
80102ce5:	e8 4f ff ff ff       	call   80102c39 <fill_rtcdate>
80102cea:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102ced:	83 ec 04             	sub    $0x4,%esp
80102cf0:	6a 18                	push   $0x18
80102cf2:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cf5:	50                   	push   %eax
80102cf6:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cf9:	50                   	push   %eax
80102cfa:	e8 b6 21 00 00       	call   80104eb5 <memcmp>
80102cff:	83 c4 10             	add    $0x10,%esp
80102d02:	85 c0                	test   %eax,%eax
80102d04:	74 05                	je     80102d0b <cmostime+0x6d>
80102d06:	eb ba                	jmp    80102cc2 <cmostime+0x24>
        continue;
80102d08:	90                   	nop
    fill_rtcdate(&t1);
80102d09:	eb b7                	jmp    80102cc2 <cmostime+0x24>
      break;
80102d0b:	90                   	nop
  }

  // convert
  if(bcd) {
80102d0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d10:	0f 84 b4 00 00 00    	je     80102dca <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d16:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d19:	c1 e8 04             	shr    $0x4,%eax
80102d1c:	89 c2                	mov    %eax,%edx
80102d1e:	89 d0                	mov    %edx,%eax
80102d20:	c1 e0 02             	shl    $0x2,%eax
80102d23:	01 d0                	add    %edx,%eax
80102d25:	01 c0                	add    %eax,%eax
80102d27:	89 c2                	mov    %eax,%edx
80102d29:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d2c:	83 e0 0f             	and    $0xf,%eax
80102d2f:	01 d0                	add    %edx,%eax
80102d31:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d34:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d37:	c1 e8 04             	shr    $0x4,%eax
80102d3a:	89 c2                	mov    %eax,%edx
80102d3c:	89 d0                	mov    %edx,%eax
80102d3e:	c1 e0 02             	shl    $0x2,%eax
80102d41:	01 d0                	add    %edx,%eax
80102d43:	01 c0                	add    %eax,%eax
80102d45:	89 c2                	mov    %eax,%edx
80102d47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d4a:	83 e0 0f             	and    $0xf,%eax
80102d4d:	01 d0                	add    %edx,%eax
80102d4f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d55:	c1 e8 04             	shr    $0x4,%eax
80102d58:	89 c2                	mov    %eax,%edx
80102d5a:	89 d0                	mov    %edx,%eax
80102d5c:	c1 e0 02             	shl    $0x2,%eax
80102d5f:	01 d0                	add    %edx,%eax
80102d61:	01 c0                	add    %eax,%eax
80102d63:	89 c2                	mov    %eax,%edx
80102d65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d68:	83 e0 0f             	and    $0xf,%eax
80102d6b:	01 d0                	add    %edx,%eax
80102d6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d73:	c1 e8 04             	shr    $0x4,%eax
80102d76:	89 c2                	mov    %eax,%edx
80102d78:	89 d0                	mov    %edx,%eax
80102d7a:	c1 e0 02             	shl    $0x2,%eax
80102d7d:	01 d0                	add    %edx,%eax
80102d7f:	01 c0                	add    %eax,%eax
80102d81:	89 c2                	mov    %eax,%edx
80102d83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d86:	83 e0 0f             	and    $0xf,%eax
80102d89:	01 d0                	add    %edx,%eax
80102d8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102d8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102d91:	c1 e8 04             	shr    $0x4,%eax
80102d94:	89 c2                	mov    %eax,%edx
80102d96:	89 d0                	mov    %edx,%eax
80102d98:	c1 e0 02             	shl    $0x2,%eax
80102d9b:	01 d0                	add    %edx,%eax
80102d9d:	01 c0                	add    %eax,%eax
80102d9f:	89 c2                	mov    %eax,%edx
80102da1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102da4:	83 e0 0f             	and    $0xf,%eax
80102da7:	01 d0                	add    %edx,%eax
80102da9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102daf:	c1 e8 04             	shr    $0x4,%eax
80102db2:	89 c2                	mov    %eax,%edx
80102db4:	89 d0                	mov    %edx,%eax
80102db6:	c1 e0 02             	shl    $0x2,%eax
80102db9:	01 d0                	add    %edx,%eax
80102dbb:	01 c0                	add    %eax,%eax
80102dbd:	89 c2                	mov    %eax,%edx
80102dbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc2:	83 e0 0f             	and    $0xf,%eax
80102dc5:	01 d0                	add    %edx,%eax
80102dc7:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102dca:	8b 45 08             	mov    0x8(%ebp),%eax
80102dcd:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102dd0:	89 10                	mov    %edx,(%eax)
80102dd2:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102dd5:	89 50 04             	mov    %edx,0x4(%eax)
80102dd8:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102ddb:	89 50 08             	mov    %edx,0x8(%eax)
80102dde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102de1:	89 50 0c             	mov    %edx,0xc(%eax)
80102de4:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102de7:	89 50 10             	mov    %edx,0x10(%eax)
80102dea:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102ded:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102df0:	8b 45 08             	mov    0x8(%ebp),%eax
80102df3:	8b 40 14             	mov    0x14(%eax),%eax
80102df6:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80102dff:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e02:	90                   	nop
80102e03:	c9                   	leave  
80102e04:	c3                   	ret    

80102e05 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e05:	55                   	push   %ebp
80102e06:	89 e5                	mov    %esp,%ebp
80102e08:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e0b:	83 ec 08             	sub    $0x8,%esp
80102e0e:	68 51 ab 10 80       	push   $0x8010ab51
80102e13:	68 20 b1 30 80       	push   $0x8030b120
80102e18:	e8 99 1d 00 00       	call   80104bb6 <initlock>
80102e1d:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e20:	83 ec 08             	sub    $0x8,%esp
80102e23:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e26:	50                   	push   %eax
80102e27:	ff 75 08             	push   0x8(%ebp)
80102e2a:	e8 87 e5 ff ff       	call   801013b6 <readsb>
80102e2f:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e35:	a3 54 b1 30 80       	mov    %eax,0x8030b154
  log.size = sb.nlog;
80102e3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e3d:	a3 58 b1 30 80       	mov    %eax,0x8030b158
  log.dev = dev;
80102e42:	8b 45 08             	mov    0x8(%ebp),%eax
80102e45:	a3 64 b1 30 80       	mov    %eax,0x8030b164
  recover_from_log();
80102e4a:	e8 b3 01 00 00       	call   80103002 <recover_from_log>
}
80102e4f:	90                   	nop
80102e50:	c9                   	leave  
80102e51:	c3                   	ret    

80102e52 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e52:	55                   	push   %ebp
80102e53:	89 e5                	mov    %esp,%ebp
80102e55:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e5f:	e9 95 00 00 00       	jmp    80102ef9 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e64:	8b 15 54 b1 30 80    	mov    0x8030b154,%edx
80102e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e6d:	01 d0                	add    %edx,%eax
80102e6f:	83 c0 01             	add    $0x1,%eax
80102e72:	89 c2                	mov    %eax,%edx
80102e74:	a1 64 b1 30 80       	mov    0x8030b164,%eax
80102e79:	83 ec 08             	sub    $0x8,%esp
80102e7c:	52                   	push   %edx
80102e7d:	50                   	push   %eax
80102e7e:	e8 7e d3 ff ff       	call   80100201 <bread>
80102e83:	83 c4 10             	add    $0x10,%esp
80102e86:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e8c:	83 c0 10             	add    $0x10,%eax
80102e8f:	8b 04 85 2c b1 30 80 	mov    -0x7fcf4ed4(,%eax,4),%eax
80102e96:	89 c2                	mov    %eax,%edx
80102e98:	a1 64 b1 30 80       	mov    0x8030b164,%eax
80102e9d:	83 ec 08             	sub    $0x8,%esp
80102ea0:	52                   	push   %edx
80102ea1:	50                   	push   %eax
80102ea2:	e8 5a d3 ff ff       	call   80100201 <bread>
80102ea7:	83 c4 10             	add    $0x10,%esp
80102eaa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102eb0:	8d 50 5c             	lea    0x5c(%eax),%edx
80102eb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102eb6:	83 c0 5c             	add    $0x5c,%eax
80102eb9:	83 ec 04             	sub    $0x4,%esp
80102ebc:	68 00 02 00 00       	push   $0x200
80102ec1:	52                   	push   %edx
80102ec2:	50                   	push   %eax
80102ec3:	e8 45 20 00 00       	call   80104f0d <memmove>
80102ec8:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ecb:	83 ec 0c             	sub    $0xc,%esp
80102ece:	ff 75 ec             	push   -0x14(%ebp)
80102ed1:	e8 64 d3 ff ff       	call   8010023a <bwrite>
80102ed6:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ed9:	83 ec 0c             	sub    $0xc,%esp
80102edc:	ff 75 f0             	push   -0x10(%ebp)
80102edf:	e8 9f d3 ff ff       	call   80100283 <brelse>
80102ee4:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102ee7:	83 ec 0c             	sub    $0xc,%esp
80102eea:	ff 75 ec             	push   -0x14(%ebp)
80102eed:	e8 91 d3 ff ff       	call   80100283 <brelse>
80102ef2:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102ef5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ef9:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80102efe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f01:	0f 8c 5d ff ff ff    	jl     80102e64 <install_trans+0x12>
  }
}
80102f07:	90                   	nop
80102f08:	90                   	nop
80102f09:	c9                   	leave  
80102f0a:	c3                   	ret    

80102f0b <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f0b:	55                   	push   %ebp
80102f0c:	89 e5                	mov    %esp,%ebp
80102f0e:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f11:	a1 54 b1 30 80       	mov    0x8030b154,%eax
80102f16:	89 c2                	mov    %eax,%edx
80102f18:	a1 64 b1 30 80       	mov    0x8030b164,%eax
80102f1d:	83 ec 08             	sub    $0x8,%esp
80102f20:	52                   	push   %edx
80102f21:	50                   	push   %eax
80102f22:	e8 da d2 ff ff       	call   80100201 <bread>
80102f27:	83 c4 10             	add    $0x10,%esp
80102f2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f30:	83 c0 5c             	add    $0x5c,%eax
80102f33:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f39:	8b 00                	mov    (%eax),%eax
80102f3b:	a3 68 b1 30 80       	mov    %eax,0x8030b168
  for (i = 0; i < log.lh.n; i++) {
80102f40:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f47:	eb 1b                	jmp    80102f64 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f4f:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f56:	83 c2 10             	add    $0x10,%edx
80102f59:	89 04 95 2c b1 30 80 	mov    %eax,-0x7fcf4ed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f60:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f64:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80102f69:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f6c:	7c db                	jl     80102f49 <read_head+0x3e>
  }
  brelse(buf);
80102f6e:	83 ec 0c             	sub    $0xc,%esp
80102f71:	ff 75 f0             	push   -0x10(%ebp)
80102f74:	e8 0a d3 ff ff       	call   80100283 <brelse>
80102f79:	83 c4 10             	add    $0x10,%esp
}
80102f7c:	90                   	nop
80102f7d:	c9                   	leave  
80102f7e:	c3                   	ret    

80102f7f <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f7f:	55                   	push   %ebp
80102f80:	89 e5                	mov    %esp,%ebp
80102f82:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f85:	a1 54 b1 30 80       	mov    0x8030b154,%eax
80102f8a:	89 c2                	mov    %eax,%edx
80102f8c:	a1 64 b1 30 80       	mov    0x8030b164,%eax
80102f91:	83 ec 08             	sub    $0x8,%esp
80102f94:	52                   	push   %edx
80102f95:	50                   	push   %eax
80102f96:	e8 66 d2 ff ff       	call   80100201 <bread>
80102f9b:	83 c4 10             	add    $0x10,%esp
80102f9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fa4:	83 c0 5c             	add    $0x5c,%eax
80102fa7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102faa:	8b 15 68 b1 30 80    	mov    0x8030b168,%edx
80102fb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fb3:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fb5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fbc:	eb 1b                	jmp    80102fd9 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fc1:	83 c0 10             	add    $0x10,%eax
80102fc4:	8b 0c 85 2c b1 30 80 	mov    -0x7fcf4ed4(,%eax,4),%ecx
80102fcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fce:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fd1:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fd5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102fd9:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80102fde:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102fe1:	7c db                	jl     80102fbe <write_head+0x3f>
  }
  bwrite(buf);
80102fe3:	83 ec 0c             	sub    $0xc,%esp
80102fe6:	ff 75 f0             	push   -0x10(%ebp)
80102fe9:	e8 4c d2 ff ff       	call   8010023a <bwrite>
80102fee:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80102ff1:	83 ec 0c             	sub    $0xc,%esp
80102ff4:	ff 75 f0             	push   -0x10(%ebp)
80102ff7:	e8 87 d2 ff ff       	call   80100283 <brelse>
80102ffc:	83 c4 10             	add    $0x10,%esp
}
80102fff:	90                   	nop
80103000:	c9                   	leave  
80103001:	c3                   	ret    

80103002 <recover_from_log>:

static void
recover_from_log(void)
{
80103002:	55                   	push   %ebp
80103003:	89 e5                	mov    %esp,%ebp
80103005:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103008:	e8 fe fe ff ff       	call   80102f0b <read_head>
  install_trans(); // if committed, copy from log to disk
8010300d:	e8 40 fe ff ff       	call   80102e52 <install_trans>
  log.lh.n = 0;
80103012:	c7 05 68 b1 30 80 00 	movl   $0x0,0x8030b168
80103019:	00 00 00 
  write_head(); // clear the log
8010301c:	e8 5e ff ff ff       	call   80102f7f <write_head>
}
80103021:	90                   	nop
80103022:	c9                   	leave  
80103023:	c3                   	ret    

80103024 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103024:	55                   	push   %ebp
80103025:	89 e5                	mov    %esp,%ebp
80103027:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010302a:	83 ec 0c             	sub    $0xc,%esp
8010302d:	68 20 b1 30 80       	push   $0x8030b120
80103032:	e8 a1 1b 00 00       	call   80104bd8 <acquire>
80103037:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010303a:	a1 60 b1 30 80       	mov    0x8030b160,%eax
8010303f:	85 c0                	test   %eax,%eax
80103041:	74 17                	je     8010305a <begin_op+0x36>
      sleep(&log, &log.lock);
80103043:	83 ec 08             	sub    $0x8,%esp
80103046:	68 20 b1 30 80       	push   $0x8030b120
8010304b:	68 20 b1 30 80       	push   $0x8030b120
80103050:	e8 29 17 00 00       	call   8010477e <sleep>
80103055:	83 c4 10             	add    $0x10,%esp
80103058:	eb e0                	jmp    8010303a <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010305a:	8b 0d 68 b1 30 80    	mov    0x8030b168,%ecx
80103060:	a1 5c b1 30 80       	mov    0x8030b15c,%eax
80103065:	8d 50 01             	lea    0x1(%eax),%edx
80103068:	89 d0                	mov    %edx,%eax
8010306a:	c1 e0 02             	shl    $0x2,%eax
8010306d:	01 d0                	add    %edx,%eax
8010306f:	01 c0                	add    %eax,%eax
80103071:	01 c8                	add    %ecx,%eax
80103073:	83 f8 1e             	cmp    $0x1e,%eax
80103076:	7e 17                	jle    8010308f <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103078:	83 ec 08             	sub    $0x8,%esp
8010307b:	68 20 b1 30 80       	push   $0x8030b120
80103080:	68 20 b1 30 80       	push   $0x8030b120
80103085:	e8 f4 16 00 00       	call   8010477e <sleep>
8010308a:	83 c4 10             	add    $0x10,%esp
8010308d:	eb ab                	jmp    8010303a <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010308f:	a1 5c b1 30 80       	mov    0x8030b15c,%eax
80103094:	83 c0 01             	add    $0x1,%eax
80103097:	a3 5c b1 30 80       	mov    %eax,0x8030b15c
      release(&log.lock);
8010309c:	83 ec 0c             	sub    $0xc,%esp
8010309f:	68 20 b1 30 80       	push   $0x8030b120
801030a4:	e8 9d 1b 00 00       	call   80104c46 <release>
801030a9:	83 c4 10             	add    $0x10,%esp
      break;
801030ac:	90                   	nop
    }
  }
}
801030ad:	90                   	nop
801030ae:	c9                   	leave  
801030af:	c3                   	ret    

801030b0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030b0:	55                   	push   %ebp
801030b1:	89 e5                	mov    %esp,%ebp
801030b3:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030bd:	83 ec 0c             	sub    $0xc,%esp
801030c0:	68 20 b1 30 80       	push   $0x8030b120
801030c5:	e8 0e 1b 00 00       	call   80104bd8 <acquire>
801030ca:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030cd:	a1 5c b1 30 80       	mov    0x8030b15c,%eax
801030d2:	83 e8 01             	sub    $0x1,%eax
801030d5:	a3 5c b1 30 80       	mov    %eax,0x8030b15c
  if(log.committing)
801030da:	a1 60 b1 30 80       	mov    0x8030b160,%eax
801030df:	85 c0                	test   %eax,%eax
801030e1:	74 0d                	je     801030f0 <end_op+0x40>
    panic("log.committing");
801030e3:	83 ec 0c             	sub    $0xc,%esp
801030e6:	68 55 ab 10 80       	push   $0x8010ab55
801030eb:	e8 b9 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801030f0:	a1 5c b1 30 80       	mov    0x8030b15c,%eax
801030f5:	85 c0                	test   %eax,%eax
801030f7:	75 13                	jne    8010310c <end_op+0x5c>
    do_commit = 1;
801030f9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103100:	c7 05 60 b1 30 80 01 	movl   $0x1,0x8030b160
80103107:	00 00 00 
8010310a:	eb 10                	jmp    8010311c <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010310c:	83 ec 0c             	sub    $0xc,%esp
8010310f:	68 20 b1 30 80       	push   $0x8030b120
80103114:	e8 4f 17 00 00       	call   80104868 <wakeup>
80103119:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010311c:	83 ec 0c             	sub    $0xc,%esp
8010311f:	68 20 b1 30 80       	push   $0x8030b120
80103124:	e8 1d 1b 00 00       	call   80104c46 <release>
80103129:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010312c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103130:	74 3f                	je     80103171 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103132:	e8 f6 00 00 00       	call   8010322d <commit>
    acquire(&log.lock);
80103137:	83 ec 0c             	sub    $0xc,%esp
8010313a:	68 20 b1 30 80       	push   $0x8030b120
8010313f:	e8 94 1a 00 00       	call   80104bd8 <acquire>
80103144:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103147:	c7 05 60 b1 30 80 00 	movl   $0x0,0x8030b160
8010314e:	00 00 00 
    wakeup(&log);
80103151:	83 ec 0c             	sub    $0xc,%esp
80103154:	68 20 b1 30 80       	push   $0x8030b120
80103159:	e8 0a 17 00 00       	call   80104868 <wakeup>
8010315e:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103161:	83 ec 0c             	sub    $0xc,%esp
80103164:	68 20 b1 30 80       	push   $0x8030b120
80103169:	e8 d8 1a 00 00       	call   80104c46 <release>
8010316e:	83 c4 10             	add    $0x10,%esp
  }
}
80103171:	90                   	nop
80103172:	c9                   	leave  
80103173:	c3                   	ret    

80103174 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103174:	55                   	push   %ebp
80103175:	89 e5                	mov    %esp,%ebp
80103177:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010317a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103181:	e9 95 00 00 00       	jmp    8010321b <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103186:	8b 15 54 b1 30 80    	mov    0x8030b154,%edx
8010318c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010318f:	01 d0                	add    %edx,%eax
80103191:	83 c0 01             	add    $0x1,%eax
80103194:	89 c2                	mov    %eax,%edx
80103196:	a1 64 b1 30 80       	mov    0x8030b164,%eax
8010319b:	83 ec 08             	sub    $0x8,%esp
8010319e:	52                   	push   %edx
8010319f:	50                   	push   %eax
801031a0:	e8 5c d0 ff ff       	call   80100201 <bread>
801031a5:	83 c4 10             	add    $0x10,%esp
801031a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031ae:	83 c0 10             	add    $0x10,%eax
801031b1:	8b 04 85 2c b1 30 80 	mov    -0x7fcf4ed4(,%eax,4),%eax
801031b8:	89 c2                	mov    %eax,%edx
801031ba:	a1 64 b1 30 80       	mov    0x8030b164,%eax
801031bf:	83 ec 08             	sub    $0x8,%esp
801031c2:	52                   	push   %edx
801031c3:	50                   	push   %eax
801031c4:	e8 38 d0 ff ff       	call   80100201 <bread>
801031c9:	83 c4 10             	add    $0x10,%esp
801031cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031d2:	8d 50 5c             	lea    0x5c(%eax),%edx
801031d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031d8:	83 c0 5c             	add    $0x5c,%eax
801031db:	83 ec 04             	sub    $0x4,%esp
801031de:	68 00 02 00 00       	push   $0x200
801031e3:	52                   	push   %edx
801031e4:	50                   	push   %eax
801031e5:	e8 23 1d 00 00       	call   80104f0d <memmove>
801031ea:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801031ed:	83 ec 0c             	sub    $0xc,%esp
801031f0:	ff 75 f0             	push   -0x10(%ebp)
801031f3:	e8 42 d0 ff ff       	call   8010023a <bwrite>
801031f8:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801031fb:	83 ec 0c             	sub    $0xc,%esp
801031fe:	ff 75 ec             	push   -0x14(%ebp)
80103201:	e8 7d d0 ff ff       	call   80100283 <brelse>
80103206:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103209:	83 ec 0c             	sub    $0xc,%esp
8010320c:	ff 75 f0             	push   -0x10(%ebp)
8010320f:	e8 6f d0 ff ff       	call   80100283 <brelse>
80103214:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103217:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010321b:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80103220:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103223:	0f 8c 5d ff ff ff    	jl     80103186 <write_log+0x12>
  }
}
80103229:	90                   	nop
8010322a:	90                   	nop
8010322b:	c9                   	leave  
8010322c:	c3                   	ret    

8010322d <commit>:

static void
commit()
{
8010322d:	55                   	push   %ebp
8010322e:	89 e5                	mov    %esp,%ebp
80103230:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103233:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80103238:	85 c0                	test   %eax,%eax
8010323a:	7e 1e                	jle    8010325a <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010323c:	e8 33 ff ff ff       	call   80103174 <write_log>
    write_head();    // Write header to disk -- the real commit
80103241:	e8 39 fd ff ff       	call   80102f7f <write_head>
    install_trans(); // Now install writes to home locations
80103246:	e8 07 fc ff ff       	call   80102e52 <install_trans>
    log.lh.n = 0;
8010324b:	c7 05 68 b1 30 80 00 	movl   $0x0,0x8030b168
80103252:	00 00 00 
    write_head();    // Erase the transaction from the log
80103255:	e8 25 fd ff ff       	call   80102f7f <write_head>
  }
}
8010325a:	90                   	nop
8010325b:	c9                   	leave  
8010325c:	c3                   	ret    

8010325d <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010325d:	55                   	push   %ebp
8010325e:	89 e5                	mov    %esp,%ebp
80103260:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103263:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80103268:	83 f8 1d             	cmp    $0x1d,%eax
8010326b:	7f 12                	jg     8010327f <log_write+0x22>
8010326d:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80103272:	8b 15 58 b1 30 80    	mov    0x8030b158,%edx
80103278:	83 ea 01             	sub    $0x1,%edx
8010327b:	39 d0                	cmp    %edx,%eax
8010327d:	7c 0d                	jl     8010328c <log_write+0x2f>
    panic("too big a transaction");
8010327f:	83 ec 0c             	sub    $0xc,%esp
80103282:	68 64 ab 10 80       	push   $0x8010ab64
80103287:	e8 1d d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
8010328c:	a1 5c b1 30 80       	mov    0x8030b15c,%eax
80103291:	85 c0                	test   %eax,%eax
80103293:	7f 0d                	jg     801032a2 <log_write+0x45>
    panic("log_write outside of trans");
80103295:	83 ec 0c             	sub    $0xc,%esp
80103298:	68 7a ab 10 80       	push   $0x8010ab7a
8010329d:	e8 07 d3 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032a2:	83 ec 0c             	sub    $0xc,%esp
801032a5:	68 20 b1 30 80       	push   $0x8030b120
801032aa:	e8 29 19 00 00       	call   80104bd8 <acquire>
801032af:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032b9:	eb 1d                	jmp    801032d8 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032be:	83 c0 10             	add    $0x10,%eax
801032c1:	8b 04 85 2c b1 30 80 	mov    -0x7fcf4ed4(,%eax,4),%eax
801032c8:	89 c2                	mov    %eax,%edx
801032ca:	8b 45 08             	mov    0x8(%ebp),%eax
801032cd:	8b 40 08             	mov    0x8(%eax),%eax
801032d0:	39 c2                	cmp    %eax,%edx
801032d2:	74 10                	je     801032e4 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032d8:	a1 68 b1 30 80       	mov    0x8030b168,%eax
801032dd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032e0:	7c d9                	jl     801032bb <log_write+0x5e>
801032e2:	eb 01                	jmp    801032e5 <log_write+0x88>
      break;
801032e4:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032e5:	8b 45 08             	mov    0x8(%ebp),%eax
801032e8:	8b 40 08             	mov    0x8(%eax),%eax
801032eb:	89 c2                	mov    %eax,%edx
801032ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032f0:	83 c0 10             	add    $0x10,%eax
801032f3:	89 14 85 2c b1 30 80 	mov    %edx,-0x7fcf4ed4(,%eax,4)
  if (i == log.lh.n)
801032fa:	a1 68 b1 30 80       	mov    0x8030b168,%eax
801032ff:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103302:	75 0d                	jne    80103311 <log_write+0xb4>
    log.lh.n++;
80103304:	a1 68 b1 30 80       	mov    0x8030b168,%eax
80103309:	83 c0 01             	add    $0x1,%eax
8010330c:	a3 68 b1 30 80       	mov    %eax,0x8030b168
  b->flags |= B_DIRTY; // prevent eviction
80103311:	8b 45 08             	mov    0x8(%ebp),%eax
80103314:	8b 00                	mov    (%eax),%eax
80103316:	83 c8 04             	or     $0x4,%eax
80103319:	89 c2                	mov    %eax,%edx
8010331b:	8b 45 08             	mov    0x8(%ebp),%eax
8010331e:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103320:	83 ec 0c             	sub    $0xc,%esp
80103323:	68 20 b1 30 80       	push   $0x8030b120
80103328:	e8 19 19 00 00       	call   80104c46 <release>
8010332d:	83 c4 10             	add    $0x10,%esp
}
80103330:	90                   	nop
80103331:	c9                   	leave  
80103332:	c3                   	ret    

80103333 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103333:	55                   	push   %ebp
80103334:	89 e5                	mov    %esp,%ebp
80103336:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103339:	8b 55 08             	mov    0x8(%ebp),%edx
8010333c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010333f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103342:	f0 87 02             	lock xchg %eax,(%edx)
80103345:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103348:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010334b:	c9                   	leave  
8010334c:	c3                   	ret    

8010334d <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010334d:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103351:	83 e4 f0             	and    $0xfffffff0,%esp
80103354:	ff 71 fc             	push   -0x4(%ecx)
80103357:	55                   	push   %ebp
80103358:	89 e5                	mov    %esp,%ebp
8010335a:	51                   	push   %ecx
8010335b:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
8010335e:	e8 7d 53 00 00       	call   801086e0 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103363:	83 ec 08             	sub    $0x8,%esp
80103366:	68 00 00 40 80       	push   $0x80400000
8010336b:	68 00 00 31 80       	push   $0x80310000
80103370:	e8 de f2 ff ff       	call   80102653 <kinit1>
80103375:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103378:	e8 b1 49 00 00       	call   80107d2e <kvmalloc>
  mpinit_uefi();
8010337d:	e8 24 51 00 00       	call   801084a6 <mpinit_uefi>
  lapicinit();     // interrupt controller
80103382:	e8 3c f6 ff ff       	call   801029c3 <lapicinit>
  seginit();       // segment descriptors
80103387:	e8 3a 44 00 00       	call   801077c6 <seginit>
  picinit();    // disable pic
8010338c:	e8 9d 01 00 00       	call   8010352e <picinit>
  ioapicinit();    // another interrupt controller
80103391:	e8 d8 f1 ff ff       	call   8010256e <ioapicinit>
  consoleinit();   // console hardware
80103396:	e8 64 d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
8010339b:	e8 bf 37 00 00       	call   80106b5f <uartinit>
  pinit();         // process table
801033a0:	e8 c2 05 00 00       	call   80103967 <pinit>
  tvinit();        // trap vectors
801033a5:	e8 09 32 00 00       	call   801065b3 <tvinit>
  binit();         // buffer cache
801033aa:	e8 b7 cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033af:	e8 f3 db ff ff       	call   80100fa7 <fileinit>
  ideinit();       // disk 
801033b4:	e8 68 74 00 00       	call   8010a821 <ideinit>
  startothers();   // start other processors
801033b9:	e8 8a 00 00 00       	call   80103448 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033be:	83 ec 08             	sub    $0x8,%esp
801033c1:	68 00 00 00 a0       	push   $0xa0000000
801033c6:	68 00 00 40 80       	push   $0x80400000
801033cb:	e8 bc f2 ff ff       	call   8010268c <kinit2>
801033d0:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033d3:	e8 61 55 00 00       	call   80108939 <pci_init>
  arp_scan();
801033d8:	e8 98 62 00 00       	call   80109675 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033dd:	e8 be 07 00 00       	call   80103ba0 <userinit>

  mpmain();        // finish this processor's setup
801033e2:	e8 1a 00 00 00       	call   80103401 <mpmain>

801033e7 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033e7:	55                   	push   %ebp
801033e8:	89 e5                	mov    %esp,%ebp
801033ea:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801033ed:	e8 54 49 00 00       	call   80107d46 <switchkvm>
  seginit();
801033f2:	e8 cf 43 00 00       	call   801077c6 <seginit>
  lapicinit();
801033f7:	e8 c7 f5 ff ff       	call   801029c3 <lapicinit>
  mpmain();
801033fc:	e8 00 00 00 00       	call   80103401 <mpmain>

80103401 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103401:	55                   	push   %ebp
80103402:	89 e5                	mov    %esp,%ebp
80103404:	53                   	push   %ebx
80103405:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103408:	e8 78 05 00 00       	call   80103985 <cpuid>
8010340d:	89 c3                	mov    %eax,%ebx
8010340f:	e8 71 05 00 00       	call   80103985 <cpuid>
80103414:	83 ec 04             	sub    $0x4,%esp
80103417:	53                   	push   %ebx
80103418:	50                   	push   %eax
80103419:	68 95 ab 10 80       	push   $0x8010ab95
8010341e:	e8 d1 cf ff ff       	call   801003f4 <cprintf>
80103423:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103426:	e8 fe 32 00 00       	call   80106729 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
8010342b:	e8 70 05 00 00       	call   801039a0 <mycpu>
80103430:	05 a0 00 00 00       	add    $0xa0,%eax
80103435:	83 ec 08             	sub    $0x8,%esp
80103438:	6a 01                	push   $0x1
8010343a:	50                   	push   %eax
8010343b:	e8 f3 fe ff ff       	call   80103333 <xchg>
80103440:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103443:	e8 f5 0d 00 00       	call   8010423d <scheduler>

80103448 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103448:	55                   	push   %ebp
80103449:	89 e5                	mov    %esp,%ebp
8010344b:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010344e:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103455:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010345a:	83 ec 04             	sub    $0x4,%esp
8010345d:	50                   	push   %eax
8010345e:	68 38 f5 10 80       	push   $0x8010f538
80103463:	ff 75 f0             	push   -0x10(%ebp)
80103466:	e8 a2 1a 00 00       	call   80104f0d <memmove>
8010346b:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010346e:	c7 45 f4 80 e4 30 80 	movl   $0x8030e480,-0xc(%ebp)
80103475:	eb 79                	jmp    801034f0 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103477:	e8 24 05 00 00       	call   801039a0 <mycpu>
8010347c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010347f:	74 67                	je     801034e8 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103481:	e8 02 f3 ff ff       	call   80102788 <kalloc>
80103486:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103489:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010348c:	83 e8 04             	sub    $0x4,%eax
8010348f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103492:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103498:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010349a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010349d:	83 e8 08             	sub    $0x8,%eax
801034a0:	c7 00 e7 33 10 80    	movl   $0x801033e7,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034a6:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034ab:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b4:	83 e8 0c             	sub    $0xc,%eax
801034b7:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034bc:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034c5:	0f b6 00             	movzbl (%eax),%eax
801034c8:	0f b6 c0             	movzbl %al,%eax
801034cb:	83 ec 08             	sub    $0x8,%esp
801034ce:	52                   	push   %edx
801034cf:	50                   	push   %eax
801034d0:	e8 50 f6 ff ff       	call   80102b25 <lapicstartap>
801034d5:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034d8:	90                   	nop
801034d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034dc:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034e2:	85 c0                	test   %eax,%eax
801034e4:	74 f3                	je     801034d9 <startothers+0x91>
801034e6:	eb 01                	jmp    801034e9 <startothers+0xa1>
      continue;
801034e8:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801034e9:	81 45 f4 b4 00 00 00 	addl   $0xb4,-0xc(%ebp)
801034f0:	a1 50 e7 30 80       	mov    0x8030e750,%eax
801034f5:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801034fb:	05 80 e4 30 80       	add    $0x8030e480,%eax
80103500:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103503:	0f 82 6e ff ff ff    	jb     80103477 <startothers+0x2f>
      ;
  }
}
80103509:	90                   	nop
8010350a:	90                   	nop
8010350b:	c9                   	leave  
8010350c:	c3                   	ret    

8010350d <outb>:
{
8010350d:	55                   	push   %ebp
8010350e:	89 e5                	mov    %esp,%ebp
80103510:	83 ec 08             	sub    $0x8,%esp
80103513:	8b 45 08             	mov    0x8(%ebp),%eax
80103516:	8b 55 0c             	mov    0xc(%ebp),%edx
80103519:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010351d:	89 d0                	mov    %edx,%eax
8010351f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103522:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103526:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010352a:	ee                   	out    %al,(%dx)
}
8010352b:	90                   	nop
8010352c:	c9                   	leave  
8010352d:	c3                   	ret    

8010352e <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
8010352e:	55                   	push   %ebp
8010352f:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103531:	68 ff 00 00 00       	push   $0xff
80103536:	6a 21                	push   $0x21
80103538:	e8 d0 ff ff ff       	call   8010350d <outb>
8010353d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103540:	68 ff 00 00 00       	push   $0xff
80103545:	68 a1 00 00 00       	push   $0xa1
8010354a:	e8 be ff ff ff       	call   8010350d <outb>
8010354f:	83 c4 08             	add    $0x8,%esp
}
80103552:	90                   	nop
80103553:	c9                   	leave  
80103554:	c3                   	ret    

80103555 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103555:	55                   	push   %ebp
80103556:	89 e5                	mov    %esp,%ebp
80103558:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010355b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103562:	8b 45 0c             	mov    0xc(%ebp),%eax
80103565:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010356b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010356e:	8b 10                	mov    (%eax),%edx
80103570:	8b 45 08             	mov    0x8(%ebp),%eax
80103573:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103575:	e8 4b da ff ff       	call   80100fc5 <filealloc>
8010357a:	8b 55 08             	mov    0x8(%ebp),%edx
8010357d:	89 02                	mov    %eax,(%edx)
8010357f:	8b 45 08             	mov    0x8(%ebp),%eax
80103582:	8b 00                	mov    (%eax),%eax
80103584:	85 c0                	test   %eax,%eax
80103586:	0f 84 c8 00 00 00    	je     80103654 <pipealloc+0xff>
8010358c:	e8 34 da ff ff       	call   80100fc5 <filealloc>
80103591:	8b 55 0c             	mov    0xc(%ebp),%edx
80103594:	89 02                	mov    %eax,(%edx)
80103596:	8b 45 0c             	mov    0xc(%ebp),%eax
80103599:	8b 00                	mov    (%eax),%eax
8010359b:	85 c0                	test   %eax,%eax
8010359d:	0f 84 b1 00 00 00    	je     80103654 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035a3:	e8 e0 f1 ff ff       	call   80102788 <kalloc>
801035a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035af:	0f 84 a2 00 00 00    	je     80103657 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035b8:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035bf:	00 00 00 
  p->writeopen = 1;
801035c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035c5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035cc:	00 00 00 
  p->nwrite = 0;
801035cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d2:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035d9:	00 00 00 
  p->nread = 0;
801035dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035df:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035e6:	00 00 00 
  initlock(&p->lock, "pipe");
801035e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ec:	83 ec 08             	sub    $0x8,%esp
801035ef:	68 a9 ab 10 80       	push   $0x8010aba9
801035f4:	50                   	push   %eax
801035f5:	e8 bc 15 00 00       	call   80104bb6 <initlock>
801035fa:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801035fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103600:	8b 00                	mov    (%eax),%eax
80103602:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103608:	8b 45 08             	mov    0x8(%ebp),%eax
8010360b:	8b 00                	mov    (%eax),%eax
8010360d:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103611:	8b 45 08             	mov    0x8(%ebp),%eax
80103614:	8b 00                	mov    (%eax),%eax
80103616:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010361a:	8b 45 08             	mov    0x8(%ebp),%eax
8010361d:	8b 00                	mov    (%eax),%eax
8010361f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103622:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103625:	8b 45 0c             	mov    0xc(%ebp),%eax
80103628:	8b 00                	mov    (%eax),%eax
8010362a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103630:	8b 45 0c             	mov    0xc(%ebp),%eax
80103633:	8b 00                	mov    (%eax),%eax
80103635:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103639:	8b 45 0c             	mov    0xc(%ebp),%eax
8010363c:	8b 00                	mov    (%eax),%eax
8010363e:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103642:	8b 45 0c             	mov    0xc(%ebp),%eax
80103645:	8b 00                	mov    (%eax),%eax
80103647:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010364a:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010364d:	b8 00 00 00 00       	mov    $0x0,%eax
80103652:	eb 51                	jmp    801036a5 <pipealloc+0x150>
    goto bad;
80103654:	90                   	nop
80103655:	eb 01                	jmp    80103658 <pipealloc+0x103>
    goto bad;
80103657:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103658:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010365c:	74 0e                	je     8010366c <pipealloc+0x117>
    kfree((char*)p);
8010365e:	83 ec 0c             	sub    $0xc,%esp
80103661:	ff 75 f4             	push   -0xc(%ebp)
80103664:	e8 85 f0 ff ff       	call   801026ee <kfree>
80103669:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010366c:	8b 45 08             	mov    0x8(%ebp),%eax
8010366f:	8b 00                	mov    (%eax),%eax
80103671:	85 c0                	test   %eax,%eax
80103673:	74 11                	je     80103686 <pipealloc+0x131>
    fileclose(*f0);
80103675:	8b 45 08             	mov    0x8(%ebp),%eax
80103678:	8b 00                	mov    (%eax),%eax
8010367a:	83 ec 0c             	sub    $0xc,%esp
8010367d:	50                   	push   %eax
8010367e:	e8 00 da ff ff       	call   80101083 <fileclose>
80103683:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103686:	8b 45 0c             	mov    0xc(%ebp),%eax
80103689:	8b 00                	mov    (%eax),%eax
8010368b:	85 c0                	test   %eax,%eax
8010368d:	74 11                	je     801036a0 <pipealloc+0x14b>
    fileclose(*f1);
8010368f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103692:	8b 00                	mov    (%eax),%eax
80103694:	83 ec 0c             	sub    $0xc,%esp
80103697:	50                   	push   %eax
80103698:	e8 e6 d9 ff ff       	call   80101083 <fileclose>
8010369d:	83 c4 10             	add    $0x10,%esp
  return -1;
801036a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036a5:	c9                   	leave  
801036a6:	c3                   	ret    

801036a7 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036a7:	55                   	push   %ebp
801036a8:	89 e5                	mov    %esp,%ebp
801036aa:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036ad:	8b 45 08             	mov    0x8(%ebp),%eax
801036b0:	83 ec 0c             	sub    $0xc,%esp
801036b3:	50                   	push   %eax
801036b4:	e8 1f 15 00 00       	call   80104bd8 <acquire>
801036b9:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036bc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036c0:	74 23                	je     801036e5 <pipeclose+0x3e>
    p->writeopen = 0;
801036c2:	8b 45 08             	mov    0x8(%ebp),%eax
801036c5:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036cc:	00 00 00 
    wakeup(&p->nread);
801036cf:	8b 45 08             	mov    0x8(%ebp),%eax
801036d2:	05 34 02 00 00       	add    $0x234,%eax
801036d7:	83 ec 0c             	sub    $0xc,%esp
801036da:	50                   	push   %eax
801036db:	e8 88 11 00 00       	call   80104868 <wakeup>
801036e0:	83 c4 10             	add    $0x10,%esp
801036e3:	eb 21                	jmp    80103706 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036e5:	8b 45 08             	mov    0x8(%ebp),%eax
801036e8:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801036ef:	00 00 00 
    wakeup(&p->nwrite);
801036f2:	8b 45 08             	mov    0x8(%ebp),%eax
801036f5:	05 38 02 00 00       	add    $0x238,%eax
801036fa:	83 ec 0c             	sub    $0xc,%esp
801036fd:	50                   	push   %eax
801036fe:	e8 65 11 00 00       	call   80104868 <wakeup>
80103703:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103706:	8b 45 08             	mov    0x8(%ebp),%eax
80103709:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010370f:	85 c0                	test   %eax,%eax
80103711:	75 2c                	jne    8010373f <pipeclose+0x98>
80103713:	8b 45 08             	mov    0x8(%ebp),%eax
80103716:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010371c:	85 c0                	test   %eax,%eax
8010371e:	75 1f                	jne    8010373f <pipeclose+0x98>
    release(&p->lock);
80103720:	8b 45 08             	mov    0x8(%ebp),%eax
80103723:	83 ec 0c             	sub    $0xc,%esp
80103726:	50                   	push   %eax
80103727:	e8 1a 15 00 00       	call   80104c46 <release>
8010372c:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010372f:	83 ec 0c             	sub    $0xc,%esp
80103732:	ff 75 08             	push   0x8(%ebp)
80103735:	e8 b4 ef ff ff       	call   801026ee <kfree>
8010373a:	83 c4 10             	add    $0x10,%esp
8010373d:	eb 10                	jmp    8010374f <pipeclose+0xa8>
  } else
    release(&p->lock);
8010373f:	8b 45 08             	mov    0x8(%ebp),%eax
80103742:	83 ec 0c             	sub    $0xc,%esp
80103745:	50                   	push   %eax
80103746:	e8 fb 14 00 00       	call   80104c46 <release>
8010374b:	83 c4 10             	add    $0x10,%esp
}
8010374e:	90                   	nop
8010374f:	90                   	nop
80103750:	c9                   	leave  
80103751:	c3                   	ret    

80103752 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103752:	55                   	push   %ebp
80103753:	89 e5                	mov    %esp,%ebp
80103755:	53                   	push   %ebx
80103756:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103759:	8b 45 08             	mov    0x8(%ebp),%eax
8010375c:	83 ec 0c             	sub    $0xc,%esp
8010375f:	50                   	push   %eax
80103760:	e8 73 14 00 00       	call   80104bd8 <acquire>
80103765:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010376f:	e9 ad 00 00 00       	jmp    80103821 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103774:	8b 45 08             	mov    0x8(%ebp),%eax
80103777:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010377d:	85 c0                	test   %eax,%eax
8010377f:	74 0c                	je     8010378d <pipewrite+0x3b>
80103781:	e8 92 02 00 00       	call   80103a18 <myproc>
80103786:	8b 40 24             	mov    0x24(%eax),%eax
80103789:	85 c0                	test   %eax,%eax
8010378b:	74 19                	je     801037a6 <pipewrite+0x54>
        release(&p->lock);
8010378d:	8b 45 08             	mov    0x8(%ebp),%eax
80103790:	83 ec 0c             	sub    $0xc,%esp
80103793:	50                   	push   %eax
80103794:	e8 ad 14 00 00       	call   80104c46 <release>
80103799:	83 c4 10             	add    $0x10,%esp
        return -1;
8010379c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037a1:	e9 a9 00 00 00       	jmp    8010384f <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037a6:	8b 45 08             	mov    0x8(%ebp),%eax
801037a9:	05 34 02 00 00       	add    $0x234,%eax
801037ae:	83 ec 0c             	sub    $0xc,%esp
801037b1:	50                   	push   %eax
801037b2:	e8 b1 10 00 00       	call   80104868 <wakeup>
801037b7:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037ba:	8b 45 08             	mov    0x8(%ebp),%eax
801037bd:	8b 55 08             	mov    0x8(%ebp),%edx
801037c0:	81 c2 38 02 00 00    	add    $0x238,%edx
801037c6:	83 ec 08             	sub    $0x8,%esp
801037c9:	50                   	push   %eax
801037ca:	52                   	push   %edx
801037cb:	e8 ae 0f 00 00       	call   8010477e <sleep>
801037d0:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037d3:	8b 45 08             	mov    0x8(%ebp),%eax
801037d6:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037dc:	8b 45 08             	mov    0x8(%ebp),%eax
801037df:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037e5:	05 00 02 00 00       	add    $0x200,%eax
801037ea:	39 c2                	cmp    %eax,%edx
801037ec:	74 86                	je     80103774 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801037ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801037f4:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801037f7:	8b 45 08             	mov    0x8(%ebp),%eax
801037fa:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103800:	8d 48 01             	lea    0x1(%eax),%ecx
80103803:	8b 55 08             	mov    0x8(%ebp),%edx
80103806:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010380c:	25 ff 01 00 00       	and    $0x1ff,%eax
80103811:	89 c1                	mov    %eax,%ecx
80103813:	0f b6 13             	movzbl (%ebx),%edx
80103816:	8b 45 08             	mov    0x8(%ebp),%eax
80103819:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010381d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103824:	3b 45 10             	cmp    0x10(%ebp),%eax
80103827:	7c aa                	jl     801037d3 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103829:	8b 45 08             	mov    0x8(%ebp),%eax
8010382c:	05 34 02 00 00       	add    $0x234,%eax
80103831:	83 ec 0c             	sub    $0xc,%esp
80103834:	50                   	push   %eax
80103835:	e8 2e 10 00 00       	call   80104868 <wakeup>
8010383a:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010383d:	8b 45 08             	mov    0x8(%ebp),%eax
80103840:	83 ec 0c             	sub    $0xc,%esp
80103843:	50                   	push   %eax
80103844:	e8 fd 13 00 00       	call   80104c46 <release>
80103849:	83 c4 10             	add    $0x10,%esp
  return n;
8010384c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010384f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103852:	c9                   	leave  
80103853:	c3                   	ret    

80103854 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103854:	55                   	push   %ebp
80103855:	89 e5                	mov    %esp,%ebp
80103857:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010385a:	8b 45 08             	mov    0x8(%ebp),%eax
8010385d:	83 ec 0c             	sub    $0xc,%esp
80103860:	50                   	push   %eax
80103861:	e8 72 13 00 00       	call   80104bd8 <acquire>
80103866:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103869:	eb 3e                	jmp    801038a9 <piperead+0x55>
    if(myproc()->killed){
8010386b:	e8 a8 01 00 00       	call   80103a18 <myproc>
80103870:	8b 40 24             	mov    0x24(%eax),%eax
80103873:	85 c0                	test   %eax,%eax
80103875:	74 19                	je     80103890 <piperead+0x3c>
      release(&p->lock);
80103877:	8b 45 08             	mov    0x8(%ebp),%eax
8010387a:	83 ec 0c             	sub    $0xc,%esp
8010387d:	50                   	push   %eax
8010387e:	e8 c3 13 00 00       	call   80104c46 <release>
80103883:	83 c4 10             	add    $0x10,%esp
      return -1;
80103886:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010388b:	e9 be 00 00 00       	jmp    8010394e <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103890:	8b 45 08             	mov    0x8(%ebp),%eax
80103893:	8b 55 08             	mov    0x8(%ebp),%edx
80103896:	81 c2 34 02 00 00    	add    $0x234,%edx
8010389c:	83 ec 08             	sub    $0x8,%esp
8010389f:	50                   	push   %eax
801038a0:	52                   	push   %edx
801038a1:	e8 d8 0e 00 00       	call   8010477e <sleep>
801038a6:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038a9:	8b 45 08             	mov    0x8(%ebp),%eax
801038ac:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038b2:	8b 45 08             	mov    0x8(%ebp),%eax
801038b5:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038bb:	39 c2                	cmp    %eax,%edx
801038bd:	75 0d                	jne    801038cc <piperead+0x78>
801038bf:	8b 45 08             	mov    0x8(%ebp),%eax
801038c2:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038c8:	85 c0                	test   %eax,%eax
801038ca:	75 9f                	jne    8010386b <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038d3:	eb 48                	jmp    8010391d <piperead+0xc9>
    if(p->nread == p->nwrite)
801038d5:	8b 45 08             	mov    0x8(%ebp),%eax
801038d8:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038de:	8b 45 08             	mov    0x8(%ebp),%eax
801038e1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038e7:	39 c2                	cmp    %eax,%edx
801038e9:	74 3c                	je     80103927 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801038eb:	8b 45 08             	mov    0x8(%ebp),%eax
801038ee:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801038f4:	8d 48 01             	lea    0x1(%eax),%ecx
801038f7:	8b 55 08             	mov    0x8(%ebp),%edx
801038fa:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103900:	25 ff 01 00 00       	and    $0x1ff,%eax
80103905:	89 c1                	mov    %eax,%ecx
80103907:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010390a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010390d:	01 c2                	add    %eax,%edx
8010390f:	8b 45 08             	mov    0x8(%ebp),%eax
80103912:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103917:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103919:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010391d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103920:	3b 45 10             	cmp    0x10(%ebp),%eax
80103923:	7c b0                	jl     801038d5 <piperead+0x81>
80103925:	eb 01                	jmp    80103928 <piperead+0xd4>
      break;
80103927:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103928:	8b 45 08             	mov    0x8(%ebp),%eax
8010392b:	05 38 02 00 00       	add    $0x238,%eax
80103930:	83 ec 0c             	sub    $0xc,%esp
80103933:	50                   	push   %eax
80103934:	e8 2f 0f 00 00       	call   80104868 <wakeup>
80103939:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010393c:	8b 45 08             	mov    0x8(%ebp),%eax
8010393f:	83 ec 0c             	sub    $0xc,%esp
80103942:	50                   	push   %eax
80103943:	e8 fe 12 00 00       	call   80104c46 <release>
80103948:	83 c4 10             	add    $0x10,%esp
  return i;
8010394b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010394e:	c9                   	leave  
8010394f:	c3                   	ret    

80103950 <readeflags>:
{
80103950:	55                   	push   %ebp
80103951:	89 e5                	mov    %esp,%ebp
80103953:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103956:	9c                   	pushf  
80103957:	58                   	pop    %eax
80103958:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010395b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010395e:	c9                   	leave  
8010395f:	c3                   	ret    

80103960 <sti>:
{
80103960:	55                   	push   %ebp
80103961:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103963:	fb                   	sti    
}
80103964:	90                   	nop
80103965:	5d                   	pop    %ebp
80103966:	c3                   	ret    

80103967 <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);

void pinit(void)
{
80103967:	55                   	push   %ebp
80103968:	89 e5                	mov    %esp,%ebp
8010396a:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010396d:	83 ec 08             	sub    $0x8,%esp
80103970:	68 b0 ab 10 80       	push   $0x8010abb0
80103975:	68 00 bb 30 80       	push   $0x8030bb00
8010397a:	e8 37 12 00 00       	call   80104bb6 <initlock>
8010397f:	83 c4 10             	add    $0x10,%esp
}
80103982:	90                   	nop
80103983:	c9                   	leave  
80103984:	c3                   	ret    

80103985 <cpuid>:

// Must be called with interrupts disabled
int cpuid()
{
80103985:	55                   	push   %ebp
80103986:	89 e5                	mov    %esp,%ebp
80103988:	83 ec 08             	sub    $0x8,%esp
  return mycpu() - cpus;
8010398b:	e8 10 00 00 00       	call   801039a0 <mycpu>
80103990:	2d 80 e4 30 80       	sub    $0x8030e480,%eax
80103995:	c1 f8 02             	sar    $0x2,%eax
80103998:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
8010399e:	c9                   	leave  
8010399f:	c3                   	ret    

801039a0 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu *
mycpu(void)
{
801039a0:	55                   	push   %ebp
801039a1:	89 e5                	mov    %esp,%ebp
801039a3:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;

  if (readeflags() & FL_IF)
801039a6:	e8 a5 ff ff ff       	call   80103950 <readeflags>
801039ab:	25 00 02 00 00       	and    $0x200,%eax
801039b0:	85 c0                	test   %eax,%eax
801039b2:	74 0d                	je     801039c1 <mycpu+0x21>
  {
    panic("mycpu called with interrupts enabled\n");
801039b4:	83 ec 0c             	sub    $0xc,%esp
801039b7:	68 b8 ab 10 80       	push   $0x8010abb8
801039bc:	e8 e8 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039c1:	e8 1c f1 ff ff       	call   80102ae2 <lapicid>
801039c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i)
801039c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039d0:	eb 2d                	jmp    801039ff <mycpu+0x5f>
  {
    if (cpus[i].apicid == apicid)
801039d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d5:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801039db:	05 80 e4 30 80       	add    $0x8030e480,%eax
801039e0:	0f b6 00             	movzbl (%eax),%eax
801039e3:	0f b6 c0             	movzbl %al,%eax
801039e6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801039e9:	75 10                	jne    801039fb <mycpu+0x5b>
    {
      return &cpus[i];
801039eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ee:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801039f4:	05 80 e4 30 80       	add    $0x8030e480,%eax
801039f9:	eb 1b                	jmp    80103a16 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i)
801039fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039ff:	a1 50 e7 30 80       	mov    0x8030e750,%eax
80103a04:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a07:	7c c9                	jl     801039d2 <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a09:	83 ec 0c             	sub    $0xc,%esp
80103a0c:	68 de ab 10 80       	push   $0x8010abde
80103a11:	e8 93 cb ff ff       	call   801005a9 <panic>
}
80103a16:	c9                   	leave  
80103a17:	c3                   	ret    

80103a18 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc *
myproc(void)
{
80103a18:	55                   	push   %ebp
80103a19:	89 e5                	mov    %esp,%ebp
80103a1b:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a1e:	e8 20 13 00 00       	call   80104d43 <pushcli>
  c = mycpu();
80103a23:	e8 78 ff ff ff       	call   801039a0 <mycpu>
80103a28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a37:	e8 54 13 00 00       	call   80104d90 <popcli>
  return p;
80103a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a3f:	c9                   	leave  
80103a40:	c3                   	ret    

80103a41 <allocproc>:
//   If found, change state to EMBRYO and initialize
//   state required to run in the kernel.
//   Otherwise return 0.
static struct proc *
allocproc(void)
{
80103a41:	55                   	push   %ebp
80103a42:	89 e5                	mov    %esp,%ebp
80103a44:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a47:	83 ec 0c             	sub    $0xc,%esp
80103a4a:	68 00 bb 30 80       	push   $0x8030bb00
80103a4f:	e8 84 11 00 00       	call   80104bd8 <acquire>
80103a54:	83 c4 10             	add    $0x10,%esp

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a57:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
80103a5e:	eb 11                	jmp    80103a71 <allocproc+0x30>
    if (p->state == UNUSED)
80103a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a63:	8b 40 0c             	mov    0xc(%eax),%eax
80103a66:	85 c0                	test   %eax,%eax
80103a68:	74 2a                	je     80103a94 <allocproc+0x53>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6a:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80103a71:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
80103a78:	72 e6                	jb     80103a60 <allocproc+0x1f>
    {
      goto found;
    }

  release(&ptable.lock);
80103a7a:	83 ec 0c             	sub    $0xc,%esp
80103a7d:	68 00 bb 30 80       	push   $0x8030bb00
80103a82:	e8 bf 11 00 00       	call   80104c46 <release>
80103a87:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a8a:	b8 00 00 00 00       	mov    $0x0,%eax
80103a8f:	e9 0a 01 00 00       	jmp    80103b9e <allocproc+0x15d>
      goto found;
80103a94:	90                   	nop

found:
  p->state = EMBRYO;
80103a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a98:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103a9f:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103aa4:	8d 50 01             	lea    0x1(%eax),%edx
80103aa7:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103aad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ab0:	89 42 10             	mov    %eax,0x10(%edx)

  int idx = p - ptable.proc; // 해당 프로세스의 인덱스 계산
80103ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab6:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
80103abb:	c1 f8 02             	sar    $0x2,%eax
80103abe:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
80103ac4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // MLFQ 전역 배열 초기화
  proc_priority[idx] = 3; // Q3가 가장 높은 우선순위
80103ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aca:	c7 04 85 00 b2 30 80 	movl   $0x3,-0x7fcf4e00(,%eax,4)
80103ad1:	03 00 00 00 
  memset(proc_ticks[idx], 0, sizeof(proc_ticks[idx]));
80103ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad8:	c1 e0 04             	shl    $0x4,%eax
80103adb:	05 00 b3 30 80       	add    $0x8030b300,%eax
80103ae0:	83 ec 04             	sub    $0x4,%esp
80103ae3:	6a 10                	push   $0x10
80103ae5:	6a 00                	push   $0x0
80103ae7:	50                   	push   %eax
80103ae8:	e8 61 13 00 00       	call   80104e4e <memset>
80103aed:	83 c4 10             	add    $0x10,%esp
  memset(proc_wait_ticks[idx], 0, sizeof(proc_wait_ticks[idx]));
80103af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af3:	c1 e0 04             	shl    $0x4,%eax
80103af6:	05 00 b7 30 80       	add    $0x8030b700,%eax
80103afb:	83 ec 04             	sub    $0x4,%esp
80103afe:	6a 10                	push   $0x10
80103b00:	6a 00                	push   $0x0
80103b02:	50                   	push   %eax
80103b03:	e8 46 13 00 00       	call   80104e4e <memset>
80103b08:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103b0b:	83 ec 0c             	sub    $0xc,%esp
80103b0e:	68 00 bb 30 80       	push   $0x8030bb00
80103b13:	e8 2e 11 00 00       	call   80104c46 <release>
80103b18:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if ((p->kstack = kalloc()) == 0)
80103b1b:	e8 68 ec ff ff       	call   80102788 <kalloc>
80103b20:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b23:	89 42 08             	mov    %eax,0x8(%edx)
80103b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b29:	8b 40 08             	mov    0x8(%eax),%eax
80103b2c:	85 c0                	test   %eax,%eax
80103b2e:	75 11                	jne    80103b41 <allocproc+0x100>
  {
    p->state = UNUSED;
80103b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b33:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b3a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b3f:	eb 5d                	jmp    80103b9e <allocproc+0x15d>
  }
  sp = p->kstack + KSTACKSIZE;
80103b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b44:	8b 40 08             	mov    0x8(%eax),%eax
80103b47:	05 00 10 00 00       	add    $0x1000,%eax
80103b4c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b4f:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe *)sp;
80103b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b56:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b59:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b5c:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint *)sp = (uint)trapret;
80103b60:	ba 61 65 10 80       	mov    $0x80106561,%edx
80103b65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b68:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b6a:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context *)sp;
80103b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b71:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b74:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7a:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b7d:	83 ec 04             	sub    $0x4,%esp
80103b80:	6a 14                	push   $0x14
80103b82:	6a 00                	push   $0x0
80103b84:	50                   	push   %eax
80103b85:	e8 c4 12 00 00       	call   80104e4e <memset>
80103b8a:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b90:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b93:	ba 38 47 10 80       	mov    $0x80104738,%edx
80103b98:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b9e:	c9                   	leave  
80103b9f:	c3                   	ret    

80103ba0 <userinit>:

// PAGEBREAK: 32
//  Set up first user process.
void userinit(void)
{
80103ba0:	55                   	push   %ebp
80103ba1:	89 e5                	mov    %esp,%ebp
80103ba3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103ba6:	e8 96 fe ff ff       	call   80103a41 <allocproc>
80103bab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  initproc = p;
80103bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb1:	a3 34 dc 30 80       	mov    %eax,0x8030dc34
  if ((p->pgdir = setupkvm()) == 0)
80103bb6:	e8 87 40 00 00       	call   80107c42 <setupkvm>
80103bbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bbe:	89 42 04             	mov    %eax,0x4(%edx)
80103bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc4:	8b 40 04             	mov    0x4(%eax),%eax
80103bc7:	85 c0                	test   %eax,%eax
80103bc9:	75 0d                	jne    80103bd8 <userinit+0x38>
  {
    panic("userinit: out of memory?");
80103bcb:	83 ec 0c             	sub    $0xc,%esp
80103bce:	68 ee ab 10 80       	push   $0x8010abee
80103bd3:	e8 d1 c9 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103bd8:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be0:	8b 40 04             	mov    0x4(%eax),%eax
80103be3:	83 ec 04             	sub    $0x4,%esp
80103be6:	52                   	push   %edx
80103be7:	68 0c f5 10 80       	push   $0x8010f50c
80103bec:	50                   	push   %eax
80103bed:	e8 0c 43 00 00       	call   80107efe <inituvm>
80103bf2:	83 c4 10             	add    $0x10,%esp

  p->sz = PGSIZE;
80103bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf8:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  if (p->sz > USERSTACKTOP - PGSIZE)
80103bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c01:	8b 00                	mov    (%eax),%eax
80103c03:	3d 00 70 ff 7f       	cmp    $0x7fff7000,%eax
80103c08:	76 0d                	jbe    80103c17 <userinit+0x77>
    panic("userinit: stack/heap overlap");
80103c0a:	83 ec 0c             	sub    $0xc,%esp
80103c0d:	68 07 ac 10 80       	push   $0x8010ac07
80103c12:	e8 92 c9 ff ff       	call   801005a9 <panic>

  cprintf("sz: %x, USERSTACKTOP-PGSIZE: %x, USERSTACKTOP: %x\n", p->sz, USERSTACKTOP - PGSIZE, USERSTACKTOP);
80103c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1a:	8b 00                	mov    (%eax),%eax
80103c1c:	68 00 80 ff 7f       	push   $0x7fff8000
80103c21:	68 00 70 ff 7f       	push   $0x7fff7000
80103c26:	50                   	push   %eax
80103c27:	68 24 ac 10 80       	push   $0x8010ac24
80103c2c:	e8 c3 c7 ff ff       	call   801003f4 <cprintf>
80103c31:	83 c4 10             	add    $0x10,%esp

  if (allocuvm(p->pgdir, USERSTACKTOP - 2 * PGSIZE, USERSTACKTOP) == 0)
80103c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c37:	8b 40 04             	mov    0x4(%eax),%eax
80103c3a:	83 ec 04             	sub    $0x4,%esp
80103c3d:	68 00 80 ff 7f       	push   $0x7fff8000
80103c42:	68 00 60 ff 7f       	push   $0x7fff6000
80103c47:	50                   	push   %eax
80103c48:	e8 ee 43 00 00       	call   8010803b <allocuvm>
80103c4d:	83 c4 10             	add    $0x10,%esp
80103c50:	85 c0                	test   %eax,%eax
80103c52:	75 0d                	jne    80103c61 <userinit+0xc1>
    panic("userinit: allocuvm fail");
80103c54:	83 ec 0c             	sub    $0xc,%esp
80103c57:	68 57 ac 10 80       	push   $0x8010ac57
80103c5c:	e8 48 c9 ff ff       	call   801005a9 <panic>

  memset(p->tf, 0, sizeof(*p->tf));
80103c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c64:	8b 40 18             	mov    0x18(%eax),%eax
80103c67:	83 ec 04             	sub    $0x4,%esp
80103c6a:	6a 4c                	push   $0x4c
80103c6c:	6a 00                	push   $0x0
80103c6e:	50                   	push   %eax
80103c6f:	e8 da 11 00 00       	call   80104e4e <memset>
80103c74:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	8b 40 18             	mov    0x18(%eax),%eax
80103c7d:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c86:	8b 40 18             	mov    0x18(%eax),%eax
80103c89:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c92:	8b 50 18             	mov    0x18(%eax),%edx
80103c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c98:	8b 40 18             	mov    0x18(%eax),%eax
80103c9b:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c9f:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca6:	8b 50 18             	mov    0x18(%eax),%edx
80103ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cac:	8b 40 18             	mov    0x18(%eax),%eax
80103caf:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103cb3:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cba:	8b 40 18             	mov    0x18(%eax),%eax
80103cbd:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = USERSTACKTOP - 4;
80103cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc7:	8b 40 18             	mov    0x18(%eax),%eax
80103cca:	c7 40 44 fc 7f ff 7f 	movl   $0x7fff7ffc,0x44(%eax)
  // p->tf->esp = PGSIZE;

  p->tf->eip = 0; // beginning of initcode.S
80103cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd4:	8b 40 18             	mov    0x18(%eax),%eax
80103cd7:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  cprintf("initcode size: %d\n", (int)_binary_initcode_size);
80103cde:	b8 2c 00 00 00       	mov    $0x2c,%eax
80103ce3:	83 ec 08             	sub    $0x8,%esp
80103ce6:	50                   	push   %eax
80103ce7:	68 6f ac 10 80       	push   $0x8010ac6f
80103cec:	e8 03 c7 ff ff       	call   801003f4 <cprintf>
80103cf1:	83 c4 10             	add    $0x10,%esp

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf7:	83 c0 6c             	add    $0x6c,%eax
80103cfa:	83 ec 04             	sub    $0x4,%esp
80103cfd:	6a 10                	push   $0x10
80103cff:	68 82 ac 10 80       	push   $0x8010ac82
80103d04:	50                   	push   %eax
80103d05:	e8 47 13 00 00       	call   80105051 <safestrcpy>
80103d0a:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103d0d:	83 ec 0c             	sub    $0xc,%esp
80103d10:	68 8b ac 10 80       	push   $0x8010ac8b
80103d15:	e8 eb e7 ff ff       	call   80102505 <namei>
80103d1a:	83 c4 10             	add    $0x10,%esp
80103d1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d20:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103d23:	83 ec 0c             	sub    $0xc,%esp
80103d26:	68 00 bb 30 80       	push   $0x8030bb00
80103d2b:	e8 a8 0e 00 00       	call   80104bd8 <acquire>
80103d30:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d36:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103d3d:	83 ec 0c             	sub    $0xc,%esp
80103d40:	68 00 bb 30 80       	push   $0x8030bb00
80103d45:	e8 fc 0e 00 00       	call   80104c46 <release>
80103d4a:	83 c4 10             	add    $0x10,%esp

  cprintf("userinit: eip=%x esp=%x sz=%x\n", p->tf->eip, p->tf->esp, p->sz);
80103d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d50:	8b 08                	mov    (%eax),%ecx
80103d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d55:	8b 40 18             	mov    0x18(%eax),%eax
80103d58:	8b 50 44             	mov    0x44(%eax),%edx
80103d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5e:	8b 40 18             	mov    0x18(%eax),%eax
80103d61:	8b 40 38             	mov    0x38(%eax),%eax
80103d64:	51                   	push   %ecx
80103d65:	52                   	push   %edx
80103d66:	50                   	push   %eax
80103d67:	68 90 ac 10 80       	push   $0x8010ac90
80103d6c:	e8 83 c6 ff ff       	call   801003f4 <cprintf>
80103d71:	83 c4 10             	add    $0x10,%esp
}
80103d74:	90                   	nop
80103d75:	c9                   	leave  
80103d76:	c3                   	ret    

80103d77 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int growproc(int n){
80103d77:	55                   	push   %ebp
80103d78:	89 e5                	mov    %esp,%ebp
80103d7a:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103d7d:	e8 96 fc ff ff       	call   80103a18 <myproc>
80103d82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint sz = curproc->sz;
80103d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d88:	8b 00                	mov    (%eax),%eax
80103d8a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if (n > 0)
80103d8d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d91:	7e 0b                	jle    80103d9e <growproc+0x27>
  {
    sz += n;
80103d93:	8b 45 08             	mov    0x8(%ebp),%eax
80103d96:	01 45 f4             	add    %eax,-0xc(%ebp)
80103d99:	e9 82 00 00 00       	jmp    80103e20 <growproc+0xa9>
  }
  else if (n < 0)
80103d9e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103da2:	79 7c                	jns    80103e20 <growproc+0xa9>
  {
    int sz_signed = (int)sz;
80103da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (sz_signed + n <= 0)
80103daa:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103dad:	8b 45 08             	mov    0x8(%ebp),%eax
80103db0:	01 d0                	add    %edx,%eax
80103db2:	85 c0                	test   %eax,%eax
80103db4:	7f 3c                	jg     80103df2 <growproc+0x7b>
    { 
      deallocuvm(curproc->pgdir, KERNBASE, 0);
80103db6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103db9:	8b 40 04             	mov    0x4(%eax),%eax
80103dbc:	83 ec 04             	sub    $0x4,%esp
80103dbf:	6a 00                	push   $0x0
80103dc1:	68 00 00 00 80       	push   $0x80000000
80103dc6:	50                   	push   %eax
80103dc7:	e8 74 43 00 00       	call   80108140 <deallocuvm>
80103dcc:	83 c4 10             	add    $0x10,%esp
      sz = 0;
80103dcf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
      cprintf("GROWPROC FULL FREE! proc %d sz=%x\n", curproc->pid, sz);
80103dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dd9:	8b 40 10             	mov    0x10(%eax),%eax
80103ddc:	83 ec 04             	sub    $0x4,%esp
80103ddf:	ff 75 f4             	push   -0xc(%ebp)
80103de2:	50                   	push   %eax
80103de3:	68 b0 ac 10 80       	push   $0x8010acb0
80103de8:	e8 07 c6 ff ff       	call   801003f4 <cprintf>
80103ded:	83 c4 10             	add    $0x10,%esp
80103df0:	eb 2e                	jmp    80103e20 <growproc+0xa9>
    }
    else
    {
      sz = deallocuvm(curproc->pgdir, sz, sz + n);
80103df2:	8b 55 08             	mov    0x8(%ebp),%edx
80103df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df8:	01 c2                	add    %eax,%edx
80103dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dfd:	8b 40 04             	mov    0x4(%eax),%eax
80103e00:	83 ec 04             	sub    $0x4,%esp
80103e03:	52                   	push   %edx
80103e04:	ff 75 f4             	push   -0xc(%ebp)
80103e07:	50                   	push   %eax
80103e08:	e8 33 43 00 00       	call   80108140 <deallocuvm>
80103e0d:	83 c4 10             	add    $0x10,%esp
80103e10:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if (sz == 0)
80103e13:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e17:	75 07                	jne    80103e20 <growproc+0xa9>
        return -1;
80103e19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e1e:	eb 1b                	jmp    80103e3b <growproc+0xc4>
    }
  }
  curproc->sz = sz;
80103e20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e23:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e26:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103e28:	83 ec 0c             	sub    $0xc,%esp
80103e2b:	ff 75 f0             	push   -0x10(%ebp)
80103e2e:	e8 2c 3f 00 00       	call   80107d5f <switchuvm>
80103e33:	83 c4 10             	add    $0x10,%esp
  return 0;
80103e36:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e3b:	c9                   	leave  
80103e3c:	c3                   	ret    

80103e3d <fork>:

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int fork(void)
{
80103e3d:	55                   	push   %ebp
80103e3e:	89 e5                	mov    %esp,%ebp
80103e40:	57                   	push   %edi
80103e41:	56                   	push   %esi
80103e42:	53                   	push   %ebx
80103e43:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103e46:	e8 cd fb ff ff       	call   80103a18 <myproc>
80103e4b:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if ((np = allocproc()) == 0)
80103e4e:	e8 ee fb ff ff       	call   80103a41 <allocproc>
80103e53:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103e56:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103e5a:	75 0a                	jne    80103e66 <fork+0x29>
  {
    return -1;
80103e5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e61:	e9 48 01 00 00       	jmp    80103fae <fork+0x171>
  }

  // Copy process state from proc.
  if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0)
80103e66:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e69:	8b 10                	mov    (%eax),%edx
80103e6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e6e:	8b 40 04             	mov    0x4(%eax),%eax
80103e71:	83 ec 08             	sub    $0x8,%esp
80103e74:	52                   	push   %edx
80103e75:	50                   	push   %eax
80103e76:	e8 44 44 00 00       	call   801082bf <copyuvm>
80103e7b:	83 c4 10             	add    $0x10,%esp
80103e7e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e81:	89 42 04             	mov    %eax,0x4(%edx)
80103e84:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e87:	8b 40 04             	mov    0x4(%eax),%eax
80103e8a:	85 c0                	test   %eax,%eax
80103e8c:	75 30                	jne    80103ebe <fork+0x81>
  {
    kfree(np->kstack);
80103e8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e91:	8b 40 08             	mov    0x8(%eax),%eax
80103e94:	83 ec 0c             	sub    $0xc,%esp
80103e97:	50                   	push   %eax
80103e98:	e8 51 e8 ff ff       	call   801026ee <kfree>
80103e9d:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103ea0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ea3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103eaa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ead:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103eb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103eb9:	e9 f0 00 00 00       	jmp    80103fae <fork+0x171>
  }
  np->sz = curproc->sz;
80103ebe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ec1:	8b 10                	mov    (%eax),%edx
80103ec3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ec6:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103ec8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ecb:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103ece:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103ed1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ed4:	8b 48 18             	mov    0x18(%eax),%ecx
80103ed7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103eda:	8b 40 18             	mov    0x18(%eax),%eax
80103edd:	89 c2                	mov    %eax,%edx
80103edf:	89 cb                	mov    %ecx,%ebx
80103ee1:	b8 13 00 00 00       	mov    $0x13,%eax
80103ee6:	89 d7                	mov    %edx,%edi
80103ee8:	89 de                	mov    %ebx,%esi
80103eea:	89 c1                	mov    %eax,%ecx
80103eec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103eee:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ef1:	8b 40 18             	mov    0x18(%eax),%eax
80103ef4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for (i = 0; i < NOFILE; i++)
80103efb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103f02:	eb 3b                	jmp    80103f3f <fork+0x102>
    if (curproc->ofile[i])
80103f04:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f07:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103f0a:	83 c2 08             	add    $0x8,%edx
80103f0d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f11:	85 c0                	test   %eax,%eax
80103f13:	74 26                	je     80103f3b <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103f15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f18:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103f1b:	83 c2 08             	add    $0x8,%edx
80103f1e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f22:	83 ec 0c             	sub    $0xc,%esp
80103f25:	50                   	push   %eax
80103f26:	e8 07 d1 ff ff       	call   80101032 <filedup>
80103f2b:	83 c4 10             	add    $0x10,%esp
80103f2e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f31:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103f34:	83 c1 08             	add    $0x8,%ecx
80103f37:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for (i = 0; i < NOFILE; i++)
80103f3b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103f3f:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103f43:	7e bf                	jle    80103f04 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103f45:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f48:	8b 40 68             	mov    0x68(%eax),%eax
80103f4b:	83 ec 0c             	sub    $0xc,%esp
80103f4e:	50                   	push   %eax
80103f4f:	e8 44 da ff ff       	call   80101998 <idup>
80103f54:	83 c4 10             	add    $0x10,%esp
80103f57:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f5a:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103f5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f60:	8d 50 6c             	lea    0x6c(%eax),%edx
80103f63:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f66:	83 c0 6c             	add    $0x6c,%eax
80103f69:	83 ec 04             	sub    $0x4,%esp
80103f6c:	6a 10                	push   $0x10
80103f6e:	52                   	push   %edx
80103f6f:	50                   	push   %eax
80103f70:	e8 dc 10 00 00       	call   80105051 <safestrcpy>
80103f75:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103f78:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f7b:	8b 40 10             	mov    0x10(%eax),%eax
80103f7e:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103f81:	83 ec 0c             	sub    $0xc,%esp
80103f84:	68 00 bb 30 80       	push   $0x8030bb00
80103f89:	e8 4a 0c 00 00       	call   80104bd8 <acquire>
80103f8e:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103f91:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f94:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103f9b:	83 ec 0c             	sub    $0xc,%esp
80103f9e:	68 00 bb 30 80       	push   $0x8030bb00
80103fa3:	e8 9e 0c 00 00       	call   80104c46 <release>
80103fa8:	83 c4 10             	add    $0x10,%esp

  return pid;
80103fab:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103fae:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103fb1:	5b                   	pop    %ebx
80103fb2:	5e                   	pop    %esi
80103fb3:	5f                   	pop    %edi
80103fb4:	5d                   	pop    %ebp
80103fb5:	c3                   	ret    

80103fb6 <exit>:
// 이거이거 살짝
//  Exit the current process.  Does not return.
//  An exited process remains in the zombie state
//  until its parent calls wait() to find out it exited.
void exit(void)
{
80103fb6:	55                   	push   %ebp
80103fb7:	89 e5                	mov    %esp,%ebp
80103fb9:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103fbc:	e8 57 fa ff ff       	call   80103a18 <myproc>
80103fc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if (curproc == initproc)
80103fc4:	a1 34 dc 30 80       	mov    0x8030dc34,%eax
80103fc9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103fcc:	75 0d                	jne    80103fdb <exit+0x25>
    panic("init exiting");
80103fce:	83 ec 0c             	sub    $0xc,%esp
80103fd1:	68 d3 ac 10 80       	push   $0x8010acd3
80103fd6:	e8 ce c5 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for (fd = 0; fd < NOFILE; fd++)
80103fdb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103fe2:	eb 3f                	jmp    80104023 <exit+0x6d>
  {
    if (curproc->ofile[fd])
80103fe4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fe7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103fea:	83 c2 08             	add    $0x8,%edx
80103fed:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ff1:	85 c0                	test   %eax,%eax
80103ff3:	74 2a                	je     8010401f <exit+0x69>
    {
      fileclose(curproc->ofile[fd]);
80103ff5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ff8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ffb:	83 c2 08             	add    $0x8,%edx
80103ffe:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104002:	83 ec 0c             	sub    $0xc,%esp
80104005:	50                   	push   %eax
80104006:	e8 78 d0 ff ff       	call   80101083 <fileclose>
8010400b:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
8010400e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104011:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104014:	83 c2 08             	add    $0x8,%edx
80104017:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010401e:	00 
  for (fd = 0; fd < NOFILE; fd++)
8010401f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104023:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104027:	7e bb                	jle    80103fe4 <exit+0x2e>
    }
  }

  begin_op();
80104029:	e8 f6 ef ff ff       	call   80103024 <begin_op>
  iput(curproc->cwd);
8010402e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104031:	8b 40 68             	mov    0x68(%eax),%eax
80104034:	83 ec 0c             	sub    $0xc,%esp
80104037:	50                   	push   %eax
80104038:	e8 f6 da ff ff       	call   80101b33 <iput>
8010403d:	83 c4 10             	add    $0x10,%esp
  end_op();
80104040:	e8 6b f0 ff ff       	call   801030b0 <end_op>
  curproc->cwd = 0;
80104045:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104048:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010404f:	83 ec 0c             	sub    $0xc,%esp
80104052:	68 00 bb 30 80       	push   $0x8030bb00
80104057:	e8 7c 0b 00 00       	call   80104bd8 <acquire>
8010405c:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010405f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104062:	8b 40 14             	mov    0x14(%eax),%eax
80104065:	83 ec 0c             	sub    $0xc,%esp
80104068:	50                   	push   %eax
80104069:	e8 b7 07 00 00       	call   80104825 <wakeup1>
8010406e:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104071:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
80104078:	eb 3a                	jmp    801040b4 <exit+0xfe>
  {
    if (p->parent == curproc)
8010407a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407d:	8b 40 14             	mov    0x14(%eax),%eax
80104080:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104083:	75 28                	jne    801040ad <exit+0xf7>
    {
      p->parent = initproc;
80104085:	8b 15 34 dc 30 80    	mov    0x8030dc34,%edx
8010408b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010408e:	89 50 14             	mov    %edx,0x14(%eax)
      if (p->state == ZOMBIE)
80104091:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104094:	8b 40 0c             	mov    0xc(%eax),%eax
80104097:	83 f8 05             	cmp    $0x5,%eax
8010409a:	75 11                	jne    801040ad <exit+0xf7>
        wakeup1(initproc);
8010409c:	a1 34 dc 30 80       	mov    0x8030dc34,%eax
801040a1:	83 ec 0c             	sub    $0xc,%esp
801040a4:	50                   	push   %eax
801040a5:	e8 7b 07 00 00       	call   80104825 <wakeup1>
801040aa:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040ad:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801040b4:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
801040bb:	72 bd                	jb     8010407a <exit+0xc4>
    }
  }

  int idx = myproc() - ptable.proc;
801040bd:	e8 56 f9 ff ff       	call   80103a18 <myproc>
801040c2:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
801040c7:	c1 f8 02             	sar    $0x2,%eax
801040ca:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
801040d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  proc_ticks[idx][proc_priority[idx]]++;
801040d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040d6:	8b 0c 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%ecx
801040dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040e0:	c1 e0 02             	shl    $0x2,%eax
801040e3:	01 c8                	add    %ecx,%eax
801040e5:	8b 04 85 00 b3 30 80 	mov    -0x7fcf4d00(,%eax,4),%eax
801040ec:	8d 50 01             	lea    0x1(%eax),%edx
801040ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040f2:	c1 e0 02             	shl    $0x2,%eax
801040f5:	01 c8                	add    %ecx,%eax
801040f7:	89 14 85 00 b3 30 80 	mov    %edx,-0x7fcf4d00(,%eax,4)

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801040fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104101:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104108:	e8 f7 04 00 00       	call   80104604 <sched>
  panic("zombie exit");
8010410d:	83 ec 0c             	sub    $0xc,%esp
80104110:	68 e0 ac 10 80       	push   $0x8010ace0
80104115:	e8 8f c4 ff ff       	call   801005a9 <panic>

8010411a <wait>:
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int wait(void)
{
8010411a:	55                   	push   %ebp
8010411b:	89 e5                	mov    %esp,%ebp
8010411d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104120:	e8 f3 f8 ff ff       	call   80103a18 <myproc>
80104125:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
80104128:	83 ec 0c             	sub    $0xc,%esp
8010412b:	68 00 bb 30 80       	push   $0x8030bb00
80104130:	e8 a3 0a 00 00       	call   80104bd8 <acquire>
80104135:	83 c4 10             	add    $0x10,%esp
  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
80104138:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010413f:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
80104146:	e9 a4 00 00 00       	jmp    801041ef <wait+0xd5>
    {
      if (p->parent != curproc)
8010414b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414e:	8b 40 14             	mov    0x14(%eax),%eax
80104151:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104154:	0f 85 8d 00 00 00    	jne    801041e7 <wait+0xcd>
        continue;
      havekids = 1;
8010415a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if (p->state == ZOMBIE)
80104161:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104164:	8b 40 0c             	mov    0xc(%eax),%eax
80104167:	83 f8 05             	cmp    $0x5,%eax
8010416a:	75 7c                	jne    801041e8 <wait+0xce>
      {
        // Found one.
        pid = p->pid;
8010416c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416f:	8b 40 10             	mov    0x10(%eax),%eax
80104172:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104178:	8b 40 08             	mov    0x8(%eax),%eax
8010417b:	83 ec 0c             	sub    $0xc,%esp
8010417e:	50                   	push   %eax
8010417f:	e8 6a e5 ff ff       	call   801026ee <kfree>
80104184:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010418a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104194:	8b 40 04             	mov    0x4(%eax),%eax
80104197:	83 ec 0c             	sub    $0xc,%esp
8010419a:	50                   	push   %eax
8010419b:	e8 45 40 00 00       	call   801081e5 <freevm>
801041a0:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801041a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a6:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801041ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801041b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ba:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801041be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c1:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801041c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041cb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801041d2:	83 ec 0c             	sub    $0xc,%esp
801041d5:	68 00 bb 30 80       	push   $0x8030bb00
801041da:	e8 67 0a 00 00       	call   80104c46 <release>
801041df:	83 c4 10             	add    $0x10,%esp
        return pid;
801041e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041e5:	eb 54                	jmp    8010423b <wait+0x121>
        continue;
801041e7:	90                   	nop
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801041e8:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801041ef:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
801041f6:	0f 82 4f ff ff ff    	jb     8010414b <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if (!havekids || curproc->killed)
801041fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104200:	74 0a                	je     8010420c <wait+0xf2>
80104202:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104205:	8b 40 24             	mov    0x24(%eax),%eax
80104208:	85 c0                	test   %eax,%eax
8010420a:	74 17                	je     80104223 <wait+0x109>
    {
      release(&ptable.lock);
8010420c:	83 ec 0c             	sub    $0xc,%esp
8010420f:	68 00 bb 30 80       	push   $0x8030bb00
80104214:	e8 2d 0a 00 00       	call   80104c46 <release>
80104219:	83 c4 10             	add    $0x10,%esp
      return -1;
8010421c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104221:	eb 18                	jmp    8010423b <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock); // DOC: wait-sleep
80104223:	83 ec 08             	sub    $0x8,%esp
80104226:	68 00 bb 30 80       	push   $0x8030bb00
8010422b:	ff 75 ec             	push   -0x14(%ebp)
8010422e:	e8 4b 05 00 00       	call   8010477e <sleep>
80104233:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104236:	e9 fd fe ff ff       	jmp    80104138 <wait+0x1e>
  }
}
8010423b:	c9                   	leave  
8010423c:	c3                   	ret    

8010423d <scheduler>:
//    - choose a process to run
//    - swtch to start running that process
//    - eventually that process transfers control
//        via swtch back to the scheduler.
void scheduler(void)
{
8010423d:	55                   	push   %ebp
8010423e:	89 e5                	mov    %esp,%ebp
80104240:	83 ec 58             	sub    $0x58,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104243:	e8 58 f7 ff ff       	call   801039a0 <mycpu>
80104248:	89 45 e8             	mov    %eax,-0x18(%ebp)
  c->proc = 0;
8010424b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010424e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104255:	00 00 00 

  for (;;)
  {
    sti(); // Enable interrupts
80104258:	e8 03 f7 ff ff       	call   80103960 <sti>

    acquire(&ptable.lock);
8010425d:	83 ec 0c             	sub    $0xc,%esp
80104260:	68 00 bb 30 80       	push   $0x8030bb00
80104265:	e8 6e 09 00 00       	call   80104bd8 <acquire>
8010426a:	83 c4 10             	add    $0x10,%esp

    int policy = c->sched_policy;
8010426d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104270:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104276:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    struct proc *chosen = 0;
80104279:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

    if (policy == 0)
80104280:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104284:	75 7b                	jne    80104301 <scheduler+0xc4>
    {
      // Round-robin scheduling
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104286:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
8010428d:	eb 64                	jmp    801042f3 <scheduler+0xb6>
      {
        if (p->state != RUNNABLE)
8010428f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104292:	8b 40 0c             	mov    0xc(%eax),%eax
80104295:	83 f8 03             	cmp    $0x3,%eax
80104298:	75 51                	jne    801042eb <scheduler+0xae>
          continue;

        c->proc = p;
8010429a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010429d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042a0:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
801042a6:	83 ec 0c             	sub    $0xc,%esp
801042a9:	ff 75 f4             	push   -0xc(%ebp)
801042ac:	e8 ae 3a 00 00       	call   80107d5f <switchuvm>
801042b1:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
801042b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b7:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
801042be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c1:	8b 40 1c             	mov    0x1c(%eax),%eax
801042c4:	8b 55 e8             	mov    -0x18(%ebp),%edx
801042c7:	83 c2 04             	add    $0x4,%edx
801042ca:	83 ec 08             	sub    $0x8,%esp
801042cd:	50                   	push   %eax
801042ce:	52                   	push   %edx
801042cf:	e8 ef 0d 00 00       	call   801050c3 <swtch>
801042d4:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801042d7:	e8 6a 3a 00 00       	call   80107d46 <switchkvm>

        c->proc = 0;
801042dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042df:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801042e6:	00 00 00 
801042e9:	eb 01                	jmp    801042ec <scheduler+0xaf>
          continue;
801042eb:	90                   	nop
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042ec:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801042f3:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
801042fa:	72 93                	jb     8010428f <scheduler+0x52>
801042fc:	e9 ee 02 00 00       	jmp    801045ef <scheduler+0x3b2>
    }
    else
    {
      // MLFQ scheduling
      int level;
      for (level = 3; level >= 0; level--)
80104301:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
80104308:	eb 53                	jmp    8010435d <scheduler+0x120>
      {
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010430a:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
80104311:	eb 3d                	jmp    80104350 <scheduler+0x113>
        {
          int idx = p - ptable.proc;
80104313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104316:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
8010431b:	c1 f8 02             	sar    $0x2,%eax
8010431e:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
80104324:	89 45 e0             	mov    %eax,-0x20(%ebp)
          if (p->state == RUNNABLE && proc_priority[idx] == level)
80104327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432a:	8b 40 0c             	mov    0xc(%eax),%eax
8010432d:	83 f8 03             	cmp    $0x3,%eax
80104330:	75 17                	jne    80104349 <scheduler+0x10c>
80104332:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104335:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
8010433c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010433f:	75 08                	jne    80104349 <scheduler+0x10c>
          {
            chosen = p;
80104341:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104344:	89 45 f0             	mov    %eax,-0x10(%ebp)
            goto found;
80104347:	eb 1b                	jmp    80104364 <scheduler+0x127>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104349:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104350:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
80104357:	72 ba                	jb     80104313 <scheduler+0xd6>
      for (level = 3; level >= 0; level--)
80104359:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
8010435d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104361:	79 a7                	jns    8010430a <scheduler+0xcd>
          }
        }
      }

    found:
80104363:	90                   	nop
      if (chosen)
80104364:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104368:	0f 84 15 01 00 00    	je     80104483 <scheduler+0x246>
      {
        int cidx = chosen - ptable.proc;
8010436e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104371:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
80104376:	c1 f8 02             	sar    $0x2,%eax
80104379:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
8010437f:	89 45 dc             	mov    %eax,-0x24(%ebp)
        c->proc = chosen;
80104382:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104385:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104388:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(chosen);
8010438e:	83 ec 0c             	sub    $0xc,%esp
80104391:	ff 75 f0             	push   -0x10(%ebp)
80104394:	e8 c6 39 00 00       	call   80107d5f <switchuvm>
80104399:	83 c4 10             	add    $0x10,%esp
        chosen->state = RUNNING;
8010439c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010439f:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&c->scheduler, chosen->context);
801043a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043a9:	8b 40 1c             	mov    0x1c(%eax),%eax
801043ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
801043af:	83 c2 04             	add    $0x4,%edx
801043b2:	83 ec 08             	sub    $0x8,%esp
801043b5:	50                   	push   %eax
801043b6:	52                   	push   %edx
801043b7:	e8 07 0d 00 00       	call   801050c3 <swtch>
801043bc:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801043bf:	e8 82 39 00 00       	call   80107d46 <switchkvm>

        proc_ticks[cidx][proc_priority[cidx]]++;
801043c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043c7:	8b 0c 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%ecx
801043ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043d1:	c1 e0 02             	shl    $0x2,%eax
801043d4:	01 c8                	add    %ecx,%eax
801043d6:	8b 04 85 00 b3 30 80 	mov    -0x7fcf4d00(,%eax,4),%eax
801043dd:	8d 50 01             	lea    0x1(%eax),%edx
801043e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043e3:	c1 e0 02             	shl    $0x2,%eax
801043e6:	01 c8                	add    %ecx,%eax
801043e8:	89 14 85 00 b3 30 80 	mov    %edx,-0x7fcf4d00(,%eax,4)

        if (proc_ticks[cidx][proc_priority[cidx]] >= (int[]){0, 32, 16, 8}[proc_priority[cidx]] && proc_priority[cidx] > 0)
801043ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043f2:	8b 14 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%edx
801043f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801043fc:	c1 e0 02             	shl    $0x2,%eax
801043ff:	01 d0                	add    %edx,%eax
80104401:	8b 14 85 00 b3 30 80 	mov    -0x7fcf4d00(,%eax,4),%edx
80104408:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
8010440f:	c7 45 c0 20 00 00 00 	movl   $0x20,-0x40(%ebp)
80104416:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
8010441d:	c7 45 c8 08 00 00 00 	movl   $0x8,-0x38(%ebp)
80104424:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104427:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
8010442e:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
80104432:	39 c2                	cmp    %eax,%edx
80104434:	7c 40                	jl     80104476 <scheduler+0x239>
80104436:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104439:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
80104440:	85 c0                	test   %eax,%eax
80104442:	7e 32                	jle    80104476 <scheduler+0x239>
        {
          proc_priority[cidx]--;
80104444:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104447:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
8010444e:	8d 50 ff             	lea    -0x1(%eax),%edx
80104451:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104454:	89 14 85 00 b2 30 80 	mov    %edx,-0x7fcf4e00(,%eax,4)
          memset(proc_wait_ticks[cidx], 0, sizeof(proc_wait_ticks[cidx]));
8010445b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010445e:	c1 e0 04             	shl    $0x4,%eax
80104461:	05 00 b7 30 80       	add    $0x8030b700,%eax
80104466:	83 ec 04             	sub    $0x4,%esp
80104469:	6a 10                	push   $0x10
8010446b:	6a 00                	push   $0x0
8010446d:	50                   	push   %eax
8010446e:	e8 db 09 00 00       	call   80104e4e <memset>
80104473:	83 c4 10             	add    $0x10,%esp
        }

        c->proc = 0;
80104476:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104479:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104480:	00 00 00 
      }

      // wait_ticks 증가
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104483:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
8010448a:	eb 59                	jmp    801044e5 <scheduler+0x2a8>
      {
        int idx = p - ptable.proc;
8010448c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448f:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
80104494:	c1 f8 02             	sar    $0x2,%eax
80104497:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
8010449d:	89 45 cc             	mov    %eax,-0x34(%ebp)
        if (p->state == RUNNABLE && p != chosen)
801044a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a3:	8b 40 0c             	mov    0xc(%eax),%eax
801044a6:	83 f8 03             	cmp    $0x3,%eax
801044a9:	75 33                	jne    801044de <scheduler+0x2a1>
801044ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ae:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801044b1:	74 2b                	je     801044de <scheduler+0x2a1>
        {
          proc_wait_ticks[idx][proc_priority[idx]]++;
801044b3:	8b 45 cc             	mov    -0x34(%ebp),%eax
801044b6:	8b 0c 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%ecx
801044bd:	8b 45 cc             	mov    -0x34(%ebp),%eax
801044c0:	c1 e0 02             	shl    $0x2,%eax
801044c3:	01 c8                	add    %ecx,%eax
801044c5:	8b 04 85 00 b7 30 80 	mov    -0x7fcf4900(,%eax,4),%eax
801044cc:	8d 50 01             	lea    0x1(%eax),%edx
801044cf:	8b 45 cc             	mov    -0x34(%ebp),%eax
801044d2:	c1 e0 02             	shl    $0x2,%eax
801044d5:	01 c8                	add    %ecx,%eax
801044d7:	89 14 85 00 b7 30 80 	mov    %edx,-0x7fcf4900(,%eax,4)
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044de:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801044e5:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
801044ec:	72 9e                	jb     8010448c <scheduler+0x24f>
        }
      }

      // Boosting (policy 1, 2만)
      if (policy != 3)
801044ee:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
801044f2:	0f 84 f7 00 00 00    	je     801045ef <scheduler+0x3b2>
      {
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044f8:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
801044ff:	e9 de 00 00 00       	jmp    801045e2 <scheduler+0x3a5>
        {
          int idx = p - ptable.proc;
80104504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104507:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
8010450c:	c1 f8 02             	sar    $0x2,%eax
8010450f:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
80104515:	89 45 d8             	mov    %eax,-0x28(%ebp)
          if (p->state == RUNNABLE && proc_priority[idx] < 3)
80104518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451b:	8b 40 0c             	mov    0xc(%eax),%eax
8010451e:	83 f8 03             	cmp    $0x3,%eax
80104521:	0f 85 b4 00 00 00    	jne    801045db <scheduler+0x39e>
80104527:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010452a:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
80104531:	83 f8 02             	cmp    $0x2,%eax
80104534:	0f 8f a1 00 00 00    	jg     801045db <scheduler+0x39e>
          {
            int waited = proc_wait_ticks[idx][proc_priority[idx]];
8010453a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010453d:	8b 14 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%edx
80104544:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104547:	c1 e0 02             	shl    $0x2,%eax
8010454a:	01 d0                	add    %edx,%eax
8010454c:	8b 04 85 00 b7 30 80 	mov    -0x7fcf4900(,%eax,4),%eax
80104553:	89 45 d4             	mov    %eax,-0x2c(%ebp)
            int required = (proc_priority[idx] == 0) ? 500 : 10 * (int[]){0, 32, 16, 8}[proc_priority[idx]];
80104556:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104559:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
80104560:	85 c0                	test   %eax,%eax
80104562:	74 35                	je     80104599 <scheduler+0x35c>
80104564:	c7 45 ac 00 00 00 00 	movl   $0x0,-0x54(%ebp)
8010456b:	c7 45 b0 20 00 00 00 	movl   $0x20,-0x50(%ebp)
80104572:	c7 45 b4 10 00 00 00 	movl   $0x10,-0x4c(%ebp)
80104579:	c7 45 b8 08 00 00 00 	movl   $0x8,-0x48(%ebp)
80104580:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104583:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
8010458a:	8b 54 85 ac          	mov    -0x54(%ebp,%eax,4),%edx
8010458e:	89 d0                	mov    %edx,%eax
80104590:	c1 e0 02             	shl    $0x2,%eax
80104593:	01 d0                	add    %edx,%eax
80104595:	01 c0                	add    %eax,%eax
80104597:	eb 05                	jmp    8010459e <scheduler+0x361>
80104599:	b8 f4 01 00 00       	mov    $0x1f4,%eax
8010459e:	89 45 d0             	mov    %eax,-0x30(%ebp)

            if (waited >= required)
801045a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801045a4:	3b 45 d0             	cmp    -0x30(%ebp),%eax
801045a7:	7c 32                	jl     801045db <scheduler+0x39e>
            {
              proc_priority[idx]++;
801045a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801045ac:	8b 04 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%eax
801045b3:	8d 50 01             	lea    0x1(%eax),%edx
801045b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801045b9:	89 14 85 00 b2 30 80 	mov    %edx,-0x7fcf4e00(,%eax,4)
              memset(proc_wait_ticks[idx], 0, sizeof(proc_wait_ticks[idx]));
801045c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801045c3:	c1 e0 04             	shl    $0x4,%eax
801045c6:	05 00 b7 30 80       	add    $0x8030b700,%eax
801045cb:	83 ec 04             	sub    $0x4,%esp
801045ce:	6a 10                	push   $0x10
801045d0:	6a 00                	push   $0x0
801045d2:	50                   	push   %eax
801045d3:	e8 76 08 00 00       	call   80104e4e <memset>
801045d8:	83 c4 10             	add    $0x10,%esp
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045db:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801045e2:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
801045e9:	0f 82 15 ff ff ff    	jb     80104504 <scheduler+0x2c7>
          }
        }
      }
    }

    release(&ptable.lock);
801045ef:	83 ec 0c             	sub    $0xc,%esp
801045f2:	68 00 bb 30 80       	push   $0x8030bb00
801045f7:	e8 4a 06 00 00       	call   80104c46 <release>
801045fc:	83 c4 10             	add    $0x10,%esp
  {
801045ff:	e9 54 fc ff ff       	jmp    80104258 <scheduler+0x1b>

80104604 <sched>:
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void sched(void)
{
80104604:	55                   	push   %ebp
80104605:	89 e5                	mov    %esp,%ebp
80104607:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010460a:	e8 09 f4 ff ff       	call   80103a18 <myproc>
8010460f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if (!holding(&ptable.lock))
80104612:	83 ec 0c             	sub    $0xc,%esp
80104615:	68 00 bb 30 80       	push   $0x8030bb00
8010461a:	e8 f4 06 00 00       	call   80104d13 <holding>
8010461f:	83 c4 10             	add    $0x10,%esp
80104622:	85 c0                	test   %eax,%eax
80104624:	75 0d                	jne    80104633 <sched+0x2f>
    panic("sched ptable.lock");
80104626:	83 ec 0c             	sub    $0xc,%esp
80104629:	68 ec ac 10 80       	push   $0x8010acec
8010462e:	e8 76 bf ff ff       	call   801005a9 <panic>
  if (mycpu()->ncli != 1)
80104633:	e8 68 f3 ff ff       	call   801039a0 <mycpu>
80104638:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010463e:	83 f8 01             	cmp    $0x1,%eax
80104641:	74 0d                	je     80104650 <sched+0x4c>
    panic("sched locks");
80104643:	83 ec 0c             	sub    $0xc,%esp
80104646:	68 fe ac 10 80       	push   $0x8010acfe
8010464b:	e8 59 bf ff ff       	call   801005a9 <panic>
  if (p->state == RUNNING)
80104650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104653:	8b 40 0c             	mov    0xc(%eax),%eax
80104656:	83 f8 04             	cmp    $0x4,%eax
80104659:	75 0d                	jne    80104668 <sched+0x64>
    panic("sched running");
8010465b:	83 ec 0c             	sub    $0xc,%esp
8010465e:	68 0a ad 10 80       	push   $0x8010ad0a
80104663:	e8 41 bf ff ff       	call   801005a9 <panic>
  if (readeflags() & FL_IF)
80104668:	e8 e3 f2 ff ff       	call   80103950 <readeflags>
8010466d:	25 00 02 00 00       	and    $0x200,%eax
80104672:	85 c0                	test   %eax,%eax
80104674:	74 0d                	je     80104683 <sched+0x7f>
    panic("sched interruptible");
80104676:	83 ec 0c             	sub    $0xc,%esp
80104679:	68 18 ad 10 80       	push   $0x8010ad18
8010467e:	e8 26 bf ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104683:	e8 18 f3 ff ff       	call   801039a0 <mycpu>
80104688:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010468e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104691:	e8 0a f3 ff ff       	call   801039a0 <mycpu>
80104696:	8b 40 04             	mov    0x4(%eax),%eax
80104699:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010469c:	83 c2 1c             	add    $0x1c,%edx
8010469f:	83 ec 08             	sub    $0x8,%esp
801046a2:	50                   	push   %eax
801046a3:	52                   	push   %edx
801046a4:	e8 1a 0a 00 00       	call   801050c3 <swtch>
801046a9:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801046ac:	e8 ef f2 ff ff       	call   801039a0 <mycpu>
801046b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046b4:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801046ba:	90                   	nop
801046bb:	c9                   	leave  
801046bc:	c3                   	ret    

801046bd <yield>:

// 이거이거거
// Give up the CPU for one scheduling round.
void yield(void)
{
801046bd:	55                   	push   %ebp
801046be:	89 e5                	mov    %esp,%ebp
801046c0:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock); // DOC: yieldlock
801046c3:	83 ec 0c             	sub    $0xc,%esp
801046c6:	68 00 bb 30 80       	push   $0x8030bb00
801046cb:	e8 08 05 00 00       	call   80104bd8 <acquire>
801046d0:	83 c4 10             	add    $0x10,%esp

  int idx = myproc() - ptable.proc;
801046d3:	e8 40 f3 ff ff       	call   80103a18 <myproc>
801046d8:	2d 34 bb 30 80       	sub    $0x8030bb34,%eax
801046dd:	c1 f8 02             	sar    $0x2,%eax
801046e0:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
801046e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  proc_ticks[idx][proc_priority[idx]]++;
801046e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ec:	8b 0c 85 00 b2 30 80 	mov    -0x7fcf4e00(,%eax,4),%ecx
801046f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f6:	c1 e0 02             	shl    $0x2,%eax
801046f9:	01 c8                	add    %ecx,%eax
801046fb:	8b 04 85 00 b3 30 80 	mov    -0x7fcf4d00(,%eax,4),%eax
80104702:	8d 50 01             	lea    0x1(%eax),%edx
80104705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104708:	c1 e0 02             	shl    $0x2,%eax
8010470b:	01 c8                	add    %ecx,%eax
8010470d:	89 14 85 00 b3 30 80 	mov    %edx,-0x7fcf4d00(,%eax,4)

  myproc()->state = RUNNABLE;
80104714:	e8 ff f2 ff ff       	call   80103a18 <myproc>
80104719:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104720:	e8 df fe ff ff       	call   80104604 <sched>
  release(&ptable.lock);
80104725:	83 ec 0c             	sub    $0xc,%esp
80104728:	68 00 bb 30 80       	push   $0x8030bb00
8010472d:	e8 14 05 00 00       	call   80104c46 <release>
80104732:	83 c4 10             	add    $0x10,%esp
}
80104735:	90                   	nop
80104736:	c9                   	leave  
80104737:	c3                   	ret    

80104738 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void forkret(void)
{
80104738:	55                   	push   %ebp
80104739:	89 e5                	mov    %esp,%ebp
8010473b:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010473e:	83 ec 0c             	sub    $0xc,%esp
80104741:	68 00 bb 30 80       	push   $0x8030bb00
80104746:	e8 fb 04 00 00       	call   80104c46 <release>
8010474b:	83 c4 10             	add    $0x10,%esp

  if (first)
8010474e:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104753:	85 c0                	test   %eax,%eax
80104755:	74 24                	je     8010477b <forkret+0x43>
  {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104757:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010475e:	00 00 00 
    iinit(ROOTDEV);
80104761:	83 ec 0c             	sub    $0xc,%esp
80104764:	6a 01                	push   $0x1
80104766:	e8 f5 ce ff ff       	call   80101660 <iinit>
8010476b:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010476e:	83 ec 0c             	sub    $0xc,%esp
80104771:	6a 01                	push   $0x1
80104773:	e8 8d e6 ff ff       	call   80102e05 <initlog>
80104778:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010477b:	90                   	nop
8010477c:	c9                   	leave  
8010477d:	c3                   	ret    

8010477e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
8010477e:	55                   	push   %ebp
8010477f:	89 e5                	mov    %esp,%ebp
80104781:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104784:	e8 8f f2 ff ff       	call   80103a18 <myproc>
80104789:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if (p == 0)
8010478c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104790:	75 0d                	jne    8010479f <sleep+0x21>
    panic("sleep");
80104792:	83 ec 0c             	sub    $0xc,%esp
80104795:	68 2c ad 10 80       	push   $0x8010ad2c
8010479a:	e8 0a be ff ff       	call   801005a9 <panic>

  if (lk == 0)
8010479f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801047a3:	75 0d                	jne    801047b2 <sleep+0x34>
    panic("sleep without lk");
801047a5:	83 ec 0c             	sub    $0xc,%esp
801047a8:	68 32 ad 10 80       	push   $0x8010ad32
801047ad:	e8 f7 bd ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if (lk != &ptable.lock)
801047b2:	81 7d 0c 00 bb 30 80 	cmpl   $0x8030bb00,0xc(%ebp)
801047b9:	74 1e                	je     801047d9 <sleep+0x5b>
  {                        // DOC: sleeplock0
    acquire(&ptable.lock); // DOC: sleeplock1
801047bb:	83 ec 0c             	sub    $0xc,%esp
801047be:	68 00 bb 30 80       	push   $0x8030bb00
801047c3:	e8 10 04 00 00       	call   80104bd8 <acquire>
801047c8:	83 c4 10             	add    $0x10,%esp
    release(lk);
801047cb:	83 ec 0c             	sub    $0xc,%esp
801047ce:	ff 75 0c             	push   0xc(%ebp)
801047d1:	e8 70 04 00 00       	call   80104c46 <release>
801047d6:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801047d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047dc:	8b 55 08             	mov    0x8(%ebp),%edx
801047df:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801047e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e5:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801047ec:	e8 13 fe ff ff       	call   80104604 <sched>

  // Tidy up.
  p->chan = 0;
801047f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f4:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if (lk != &ptable.lock)
801047fb:	81 7d 0c 00 bb 30 80 	cmpl   $0x8030bb00,0xc(%ebp)
80104802:	74 1e                	je     80104822 <sleep+0xa4>
  { // DOC: sleeplock2
    release(&ptable.lock);
80104804:	83 ec 0c             	sub    $0xc,%esp
80104807:	68 00 bb 30 80       	push   $0x8030bb00
8010480c:	e8 35 04 00 00       	call   80104c46 <release>
80104811:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104814:	83 ec 0c             	sub    $0xc,%esp
80104817:	ff 75 0c             	push   0xc(%ebp)
8010481a:	e8 b9 03 00 00       	call   80104bd8 <acquire>
8010481f:	83 c4 10             	add    $0x10,%esp
  }
}
80104822:	90                   	nop
80104823:	c9                   	leave  
80104824:	c3                   	ret    

80104825 <wakeup1>:
// PAGEBREAK!
//  Wake up all processes sleeping on chan.
//  The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104825:	55                   	push   %ebp
80104826:	89 e5                	mov    %esp,%ebp
80104828:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010482b:	c7 45 fc 34 bb 30 80 	movl   $0x8030bb34,-0x4(%ebp)
80104832:	eb 27                	jmp    8010485b <wakeup1+0x36>
    if (p->state == SLEEPING && p->chan == chan)
80104834:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104837:	8b 40 0c             	mov    0xc(%eax),%eax
8010483a:	83 f8 02             	cmp    $0x2,%eax
8010483d:	75 15                	jne    80104854 <wakeup1+0x2f>
8010483f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104842:	8b 40 20             	mov    0x20(%eax),%eax
80104845:	39 45 08             	cmp    %eax,0x8(%ebp)
80104848:	75 0a                	jne    80104854 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010484a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010484d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104854:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
8010485b:	81 7d fc 34 dc 30 80 	cmpl   $0x8030dc34,-0x4(%ebp)
80104862:	72 d0                	jb     80104834 <wakeup1+0xf>
}
80104864:	90                   	nop
80104865:	90                   	nop
80104866:	c9                   	leave  
80104867:	c3                   	ret    

80104868 <wakeup>:

// Wake up all processes sleeping on chan.
void wakeup(void *chan)
{
80104868:	55                   	push   %ebp
80104869:	89 e5                	mov    %esp,%ebp
8010486b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010486e:	83 ec 0c             	sub    $0xc,%esp
80104871:	68 00 bb 30 80       	push   $0x8030bb00
80104876:	e8 5d 03 00 00       	call   80104bd8 <acquire>
8010487b:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010487e:	83 ec 0c             	sub    $0xc,%esp
80104881:	ff 75 08             	push   0x8(%ebp)
80104884:	e8 9c ff ff ff       	call   80104825 <wakeup1>
80104889:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010488c:	83 ec 0c             	sub    $0xc,%esp
8010488f:	68 00 bb 30 80       	push   $0x8030bb00
80104894:	e8 ad 03 00 00       	call   80104c46 <release>
80104899:	83 c4 10             	add    $0x10,%esp
}
8010489c:	90                   	nop
8010489d:	c9                   	leave  
8010489e:	c3                   	ret    

8010489f <kill>:

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int kill(int pid)
{
8010489f:	55                   	push   %ebp
801048a0:	89 e5                	mov    %esp,%ebp
801048a2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801048a5:	83 ec 0c             	sub    $0xc,%esp
801048a8:	68 00 bb 30 80       	push   $0x8030bb00
801048ad:	e8 26 03 00 00       	call   80104bd8 <acquire>
801048b2:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048b5:	c7 45 f4 34 bb 30 80 	movl   $0x8030bb34,-0xc(%ebp)
801048bc:	eb 48                	jmp    80104906 <kill+0x67>
  {
    if (p->pid == pid)
801048be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c1:	8b 40 10             	mov    0x10(%eax),%eax
801048c4:	39 45 08             	cmp    %eax,0x8(%ebp)
801048c7:	75 36                	jne    801048ff <kill+0x60>
    {
      p->killed = 1;
801048c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048cc:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if (p->state == SLEEPING)
801048d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d6:	8b 40 0c             	mov    0xc(%eax),%eax
801048d9:	83 f8 02             	cmp    $0x2,%eax
801048dc:	75 0a                	jne    801048e8 <kill+0x49>
        p->state = RUNNABLE;
801048de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801048e8:	83 ec 0c             	sub    $0xc,%esp
801048eb:	68 00 bb 30 80       	push   $0x8030bb00
801048f0:	e8 51 03 00 00       	call   80104c46 <release>
801048f5:	83 c4 10             	add    $0x10,%esp
      return 0;
801048f8:	b8 00 00 00 00       	mov    $0x0,%eax
801048fd:	eb 25                	jmp    80104924 <kill+0x85>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048ff:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104906:	81 7d f4 34 dc 30 80 	cmpl   $0x8030dc34,-0xc(%ebp)
8010490d:	72 af                	jb     801048be <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010490f:	83 ec 0c             	sub    $0xc,%esp
80104912:	68 00 bb 30 80       	push   $0x8030bb00
80104917:	e8 2a 03 00 00       	call   80104c46 <release>
8010491c:	83 c4 10             	add    $0x10,%esp
  return -1;
8010491f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104924:	c9                   	leave  
80104925:	c3                   	ret    

80104926 <procdump>:
// PAGEBREAK: 36
//  Print a process listing to console.  For debugging.
//  Runs when user types ^P on console.
//  No lock to avoid wedging a stuck machine further.
void procdump(void)
{
80104926:	55                   	push   %ebp
80104927:	89 e5                	mov    %esp,%ebp
80104929:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010492c:	c7 45 f0 34 bb 30 80 	movl   $0x8030bb34,-0x10(%ebp)
80104933:	e9 da 00 00 00       	jmp    80104a12 <procdump+0xec>
  {
    if (p->state == UNUSED)
80104938:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010493b:	8b 40 0c             	mov    0xc(%eax),%eax
8010493e:	85 c0                	test   %eax,%eax
80104940:	0f 84 c4 00 00 00    	je     80104a0a <procdump+0xe4>
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104946:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104949:	8b 40 0c             	mov    0xc(%eax),%eax
8010494c:	83 f8 05             	cmp    $0x5,%eax
8010494f:	77 23                	ja     80104974 <procdump+0x4e>
80104951:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104954:	8b 40 0c             	mov    0xc(%eax),%eax
80104957:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010495e:	85 c0                	test   %eax,%eax
80104960:	74 12                	je     80104974 <procdump+0x4e>
      state = states[p->state];
80104962:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104965:	8b 40 0c             	mov    0xc(%eax),%eax
80104968:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010496f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104972:	eb 07                	jmp    8010497b <procdump+0x55>
    else
      state = "???";
80104974:	c7 45 ec 43 ad 10 80 	movl   $0x8010ad43,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010497b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010497e:	8d 50 6c             	lea    0x6c(%eax),%edx
80104981:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104984:	8b 40 10             	mov    0x10(%eax),%eax
80104987:	52                   	push   %edx
80104988:	ff 75 ec             	push   -0x14(%ebp)
8010498b:	50                   	push   %eax
8010498c:	68 47 ad 10 80       	push   $0x8010ad47
80104991:	e8 5e ba ff ff       	call   801003f4 <cprintf>
80104996:	83 c4 10             	add    $0x10,%esp
    if (p->state == SLEEPING)
80104999:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010499c:	8b 40 0c             	mov    0xc(%eax),%eax
8010499f:	83 f8 02             	cmp    $0x2,%eax
801049a2:	75 54                	jne    801049f8 <procdump+0xd2>
    {
      getcallerpcs((uint *)p->context->ebp + 2, pc);
801049a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049a7:	8b 40 1c             	mov    0x1c(%eax),%eax
801049aa:	8b 40 0c             	mov    0xc(%eax),%eax
801049ad:	83 c0 08             	add    $0x8,%eax
801049b0:	89 c2                	mov    %eax,%edx
801049b2:	83 ec 08             	sub    $0x8,%esp
801049b5:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801049b8:	50                   	push   %eax
801049b9:	52                   	push   %edx
801049ba:	e8 d9 02 00 00       	call   80104c98 <getcallerpcs>
801049bf:	83 c4 10             	add    $0x10,%esp
      for (i = 0; i < 10 && pc[i] != 0; i++)
801049c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801049c9:	eb 1c                	jmp    801049e7 <procdump+0xc1>
        cprintf(" %p", pc[i]);
801049cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ce:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801049d2:	83 ec 08             	sub    $0x8,%esp
801049d5:	50                   	push   %eax
801049d6:	68 50 ad 10 80       	push   $0x8010ad50
801049db:	e8 14 ba ff ff       	call   801003f4 <cprintf>
801049e0:	83 c4 10             	add    $0x10,%esp
      for (i = 0; i < 10 && pc[i] != 0; i++)
801049e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801049e7:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801049eb:	7f 0b                	jg     801049f8 <procdump+0xd2>
801049ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f0:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801049f4:	85 c0                	test   %eax,%eax
801049f6:	75 d3                	jne    801049cb <procdump+0xa5>
    }
    cprintf("\n");
801049f8:	83 ec 0c             	sub    $0xc,%esp
801049fb:	68 54 ad 10 80       	push   $0x8010ad54
80104a00:	e8 ef b9 ff ff       	call   801003f4 <cprintf>
80104a05:	83 c4 10             	add    $0x10,%esp
80104a08:	eb 01                	jmp    80104a0b <procdump+0xe5>
      continue;
80104a0a:	90                   	nop
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a0b:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104a12:	81 7d f0 34 dc 30 80 	cmpl   $0x8030dc34,-0x10(%ebp)
80104a19:	0f 82 19 ff ff ff    	jb     80104938 <procdump+0x12>
  }
}
80104a1f:	90                   	nop
80104a20:	90                   	nop
80104a21:	c9                   	leave  
80104a22:	c3                   	ret    

80104a23 <find_proc_by_pid>:

struct proc *find_proc_by_pid(int pid)
{
80104a23:	55                   	push   %ebp
80104a24:	89 e5                	mov    %esp,%ebp
80104a26:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a29:	c7 45 fc 34 bb 30 80 	movl   $0x8030bb34,-0x4(%ebp)
80104a30:	eb 17                	jmp    80104a49 <find_proc_by_pid+0x26>
  {
    if (p->pid == pid)
80104a32:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a35:	8b 40 10             	mov    0x10(%eax),%eax
80104a38:	39 45 08             	cmp    %eax,0x8(%ebp)
80104a3b:	75 05                	jne    80104a42 <find_proc_by_pid+0x1f>
      return p;
80104a3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a40:	eb 15                	jmp    80104a57 <find_proc_by_pid+0x34>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a42:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104a49:	81 7d fc 34 dc 30 80 	cmpl   $0x8030dc34,-0x4(%ebp)
80104a50:	72 e0                	jb     80104a32 <find_proc_by_pid+0xf>
  }
  return 0;
80104a52:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a57:	c9                   	leave  
80104a58:	c3                   	ret    

80104a59 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104a59:	55                   	push   %ebp
80104a5a:	89 e5                	mov    %esp,%ebp
80104a5c:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a62:	83 c0 04             	add    $0x4,%eax
80104a65:	83 ec 08             	sub    $0x8,%esp
80104a68:	68 80 ad 10 80       	push   $0x8010ad80
80104a6d:	50                   	push   %eax
80104a6e:	e8 43 01 00 00       	call   80104bb6 <initlock>
80104a73:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104a76:	8b 45 08             	mov    0x8(%ebp),%eax
80104a79:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a7c:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a88:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8b:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104a92:	90                   	nop
80104a93:	c9                   	leave  
80104a94:	c3                   	ret    

80104a95 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104a95:	55                   	push   %ebp
80104a96:	89 e5                	mov    %esp,%ebp
80104a98:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a9e:	83 c0 04             	add    $0x4,%eax
80104aa1:	83 ec 0c             	sub    $0xc,%esp
80104aa4:	50                   	push   %eax
80104aa5:	e8 2e 01 00 00       	call   80104bd8 <acquire>
80104aaa:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104aad:	eb 15                	jmp    80104ac4 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab2:	83 c0 04             	add    $0x4,%eax
80104ab5:	83 ec 08             	sub    $0x8,%esp
80104ab8:	50                   	push   %eax
80104ab9:	ff 75 08             	push   0x8(%ebp)
80104abc:	e8 bd fc ff ff       	call   8010477e <sleep>
80104ac1:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac7:	8b 00                	mov    (%eax),%eax
80104ac9:	85 c0                	test   %eax,%eax
80104acb:	75 e2                	jne    80104aaf <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104acd:	8b 45 08             	mov    0x8(%ebp),%eax
80104ad0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104ad6:	e8 3d ef ff ff       	call   80103a18 <myproc>
80104adb:	8b 50 10             	mov    0x10(%eax),%edx
80104ade:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae1:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae7:	83 c0 04             	add    $0x4,%eax
80104aea:	83 ec 0c             	sub    $0xc,%esp
80104aed:	50                   	push   %eax
80104aee:	e8 53 01 00 00       	call   80104c46 <release>
80104af3:	83 c4 10             	add    $0x10,%esp
}
80104af6:	90                   	nop
80104af7:	c9                   	leave  
80104af8:	c3                   	ret    

80104af9 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104af9:	55                   	push   %ebp
80104afa:	89 e5                	mov    %esp,%ebp
80104afc:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104aff:	8b 45 08             	mov    0x8(%ebp),%eax
80104b02:	83 c0 04             	add    $0x4,%eax
80104b05:	83 ec 0c             	sub    $0xc,%esp
80104b08:	50                   	push   %eax
80104b09:	e8 ca 00 00 00       	call   80104bd8 <acquire>
80104b0e:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104b11:	8b 45 08             	mov    0x8(%ebp),%eax
80104b14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104b24:	83 ec 0c             	sub    $0xc,%esp
80104b27:	ff 75 08             	push   0x8(%ebp)
80104b2a:	e8 39 fd ff ff       	call   80104868 <wakeup>
80104b2f:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104b32:	8b 45 08             	mov    0x8(%ebp),%eax
80104b35:	83 c0 04             	add    $0x4,%eax
80104b38:	83 ec 0c             	sub    $0xc,%esp
80104b3b:	50                   	push   %eax
80104b3c:	e8 05 01 00 00       	call   80104c46 <release>
80104b41:	83 c4 10             	add    $0x10,%esp
}
80104b44:	90                   	nop
80104b45:	c9                   	leave  
80104b46:	c3                   	ret    

80104b47 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104b47:	55                   	push   %ebp
80104b48:	89 e5                	mov    %esp,%ebp
80104b4a:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104b4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b50:	83 c0 04             	add    $0x4,%eax
80104b53:	83 ec 0c             	sub    $0xc,%esp
80104b56:	50                   	push   %eax
80104b57:	e8 7c 00 00 00       	call   80104bd8 <acquire>
80104b5c:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b62:	8b 00                	mov    (%eax),%eax
80104b64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104b67:	8b 45 08             	mov    0x8(%ebp),%eax
80104b6a:	83 c0 04             	add    $0x4,%eax
80104b6d:	83 ec 0c             	sub    $0xc,%esp
80104b70:	50                   	push   %eax
80104b71:	e8 d0 00 00 00       	call   80104c46 <release>
80104b76:	83 c4 10             	add    $0x10,%esp
  return r;
80104b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b7c:	c9                   	leave  
80104b7d:	c3                   	ret    

80104b7e <readeflags>:
{
80104b7e:	55                   	push   %ebp
80104b7f:	89 e5                	mov    %esp,%ebp
80104b81:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b84:	9c                   	pushf  
80104b85:	58                   	pop    %eax
80104b86:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b89:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b8c:	c9                   	leave  
80104b8d:	c3                   	ret    

80104b8e <cli>:
{
80104b8e:	55                   	push   %ebp
80104b8f:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104b91:	fa                   	cli    
}
80104b92:	90                   	nop
80104b93:	5d                   	pop    %ebp
80104b94:	c3                   	ret    

80104b95 <sti>:
{
80104b95:	55                   	push   %ebp
80104b96:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104b98:	fb                   	sti    
}
80104b99:	90                   	nop
80104b9a:	5d                   	pop    %ebp
80104b9b:	c3                   	ret    

80104b9c <xchg>:
{
80104b9c:	55                   	push   %ebp
80104b9d:	89 e5                	mov    %esp,%ebp
80104b9f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104ba2:	8b 55 08             	mov    0x8(%ebp),%edx
80104ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ba8:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104bab:	f0 87 02             	lock xchg %eax,(%edx)
80104bae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104bb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bb4:	c9                   	leave  
80104bb5:	c3                   	ret    

80104bb6 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104bb6:	55                   	push   %ebp
80104bb7:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bbf:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80104bce:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104bd5:	90                   	nop
80104bd6:	5d                   	pop    %ebp
80104bd7:	c3                   	ret    

80104bd8 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104bd8:	55                   	push   %ebp
80104bd9:	89 e5                	mov    %esp,%ebp
80104bdb:	53                   	push   %ebx
80104bdc:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104bdf:	e8 5f 01 00 00       	call   80104d43 <pushcli>
  if(holding(lk)){
80104be4:	8b 45 08             	mov    0x8(%ebp),%eax
80104be7:	83 ec 0c             	sub    $0xc,%esp
80104bea:	50                   	push   %eax
80104beb:	e8 23 01 00 00       	call   80104d13 <holding>
80104bf0:	83 c4 10             	add    $0x10,%esp
80104bf3:	85 c0                	test   %eax,%eax
80104bf5:	74 0d                	je     80104c04 <acquire+0x2c>
    panic("acquire");
80104bf7:	83 ec 0c             	sub    $0xc,%esp
80104bfa:	68 8b ad 10 80       	push   $0x8010ad8b
80104bff:	e8 a5 b9 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104c04:	90                   	nop
80104c05:	8b 45 08             	mov    0x8(%ebp),%eax
80104c08:	83 ec 08             	sub    $0x8,%esp
80104c0b:	6a 01                	push   $0x1
80104c0d:	50                   	push   %eax
80104c0e:	e8 89 ff ff ff       	call   80104b9c <xchg>
80104c13:	83 c4 10             	add    $0x10,%esp
80104c16:	85 c0                	test   %eax,%eax
80104c18:	75 eb                	jne    80104c05 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104c1a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104c1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104c22:	e8 79 ed ff ff       	call   801039a0 <mycpu>
80104c27:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104c2a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c2d:	83 c0 0c             	add    $0xc,%eax
80104c30:	83 ec 08             	sub    $0x8,%esp
80104c33:	50                   	push   %eax
80104c34:	8d 45 08             	lea    0x8(%ebp),%eax
80104c37:	50                   	push   %eax
80104c38:	e8 5b 00 00 00       	call   80104c98 <getcallerpcs>
80104c3d:	83 c4 10             	add    $0x10,%esp
}
80104c40:	90                   	nop
80104c41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c44:	c9                   	leave  
80104c45:	c3                   	ret    

80104c46 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104c46:	55                   	push   %ebp
80104c47:	89 e5                	mov    %esp,%ebp
80104c49:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104c4c:	83 ec 0c             	sub    $0xc,%esp
80104c4f:	ff 75 08             	push   0x8(%ebp)
80104c52:	e8 bc 00 00 00       	call   80104d13 <holding>
80104c57:	83 c4 10             	add    $0x10,%esp
80104c5a:	85 c0                	test   %eax,%eax
80104c5c:	75 0d                	jne    80104c6b <release+0x25>
    panic("release");
80104c5e:	83 ec 0c             	sub    $0xc,%esp
80104c61:	68 93 ad 10 80       	push   $0x8010ad93
80104c66:	e8 3e b9 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104c75:	8b 45 08             	mov    0x8(%ebp),%eax
80104c78:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104c7f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104c84:	8b 45 08             	mov    0x8(%ebp),%eax
80104c87:	8b 55 08             	mov    0x8(%ebp),%edx
80104c8a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104c90:	e8 fb 00 00 00       	call   80104d90 <popcli>
}
80104c95:	90                   	nop
80104c96:	c9                   	leave  
80104c97:	c3                   	ret    

80104c98 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104c98:	55                   	push   %ebp
80104c99:	89 e5                	mov    %esp,%ebp
80104c9b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca1:	83 e8 08             	sub    $0x8,%eax
80104ca4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104ca7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104cae:	eb 38                	jmp    80104ce8 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104cb0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104cb4:	74 53                	je     80104d09 <getcallerpcs+0x71>
80104cb6:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104cbd:	76 4a                	jbe    80104d09 <getcallerpcs+0x71>
80104cbf:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104cc3:	74 44                	je     80104d09 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104cc5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cc8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cd2:	01 c2                	add    %eax,%edx
80104cd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cd7:	8b 40 04             	mov    0x4(%eax),%eax
80104cda:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104cdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cdf:	8b 00                	mov    (%eax),%eax
80104ce1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104ce4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ce8:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104cec:	7e c2                	jle    80104cb0 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104cee:	eb 19                	jmp    80104d09 <getcallerpcs+0x71>
    pcs[i] = 0;
80104cf0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cf3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cfd:	01 d0                	add    %edx,%eax
80104cff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104d05:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104d09:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104d0d:	7e e1                	jle    80104cf0 <getcallerpcs+0x58>
}
80104d0f:	90                   	nop
80104d10:	90                   	nop
80104d11:	c9                   	leave  
80104d12:	c3                   	ret    

80104d13 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104d13:	55                   	push   %ebp
80104d14:	89 e5                	mov    %esp,%ebp
80104d16:	53                   	push   %ebx
80104d17:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104d1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d1d:	8b 00                	mov    (%eax),%eax
80104d1f:	85 c0                	test   %eax,%eax
80104d21:	74 16                	je     80104d39 <holding+0x26>
80104d23:	8b 45 08             	mov    0x8(%ebp),%eax
80104d26:	8b 58 08             	mov    0x8(%eax),%ebx
80104d29:	e8 72 ec ff ff       	call   801039a0 <mycpu>
80104d2e:	39 c3                	cmp    %eax,%ebx
80104d30:	75 07                	jne    80104d39 <holding+0x26>
80104d32:	b8 01 00 00 00       	mov    $0x1,%eax
80104d37:	eb 05                	jmp    80104d3e <holding+0x2b>
80104d39:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d41:	c9                   	leave  
80104d42:	c3                   	ret    

80104d43 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104d43:	55                   	push   %ebp
80104d44:	89 e5                	mov    %esp,%ebp
80104d46:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104d49:	e8 30 fe ff ff       	call   80104b7e <readeflags>
80104d4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104d51:	e8 38 fe ff ff       	call   80104b8e <cli>
  if(mycpu()->ncli == 0)
80104d56:	e8 45 ec ff ff       	call   801039a0 <mycpu>
80104d5b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d61:	85 c0                	test   %eax,%eax
80104d63:	75 14                	jne    80104d79 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104d65:	e8 36 ec ff ff       	call   801039a0 <mycpu>
80104d6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d6d:	81 e2 00 02 00 00    	and    $0x200,%edx
80104d73:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104d79:	e8 22 ec ff ff       	call   801039a0 <mycpu>
80104d7e:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d84:	83 c2 01             	add    $0x1,%edx
80104d87:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104d8d:	90                   	nop
80104d8e:	c9                   	leave  
80104d8f:	c3                   	ret    

80104d90 <popcli>:

void
popcli(void)
{
80104d90:	55                   	push   %ebp
80104d91:	89 e5                	mov    %esp,%ebp
80104d93:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104d96:	e8 e3 fd ff ff       	call   80104b7e <readeflags>
80104d9b:	25 00 02 00 00       	and    $0x200,%eax
80104da0:	85 c0                	test   %eax,%eax
80104da2:	74 0d                	je     80104db1 <popcli+0x21>
    panic("popcli - interruptible");
80104da4:	83 ec 0c             	sub    $0xc,%esp
80104da7:	68 9b ad 10 80       	push   $0x8010ad9b
80104dac:	e8 f8 b7 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104db1:	e8 ea eb ff ff       	call   801039a0 <mycpu>
80104db6:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104dbc:	83 ea 01             	sub    $0x1,%edx
80104dbf:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104dc5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104dcb:	85 c0                	test   %eax,%eax
80104dcd:	79 0d                	jns    80104ddc <popcli+0x4c>
    panic("popcli");
80104dcf:	83 ec 0c             	sub    $0xc,%esp
80104dd2:	68 b2 ad 10 80       	push   $0x8010adb2
80104dd7:	e8 cd b7 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104ddc:	e8 bf eb ff ff       	call   801039a0 <mycpu>
80104de1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104de7:	85 c0                	test   %eax,%eax
80104de9:	75 14                	jne    80104dff <popcli+0x6f>
80104deb:	e8 b0 eb ff ff       	call   801039a0 <mycpu>
80104df0:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104df6:	85 c0                	test   %eax,%eax
80104df8:	74 05                	je     80104dff <popcli+0x6f>
    sti();
80104dfa:	e8 96 fd ff ff       	call   80104b95 <sti>
}
80104dff:	90                   	nop
80104e00:	c9                   	leave  
80104e01:	c3                   	ret    

80104e02 <stosb>:
{
80104e02:	55                   	push   %ebp
80104e03:	89 e5                	mov    %esp,%ebp
80104e05:	57                   	push   %edi
80104e06:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104e07:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e0a:	8b 55 10             	mov    0x10(%ebp),%edx
80104e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e10:	89 cb                	mov    %ecx,%ebx
80104e12:	89 df                	mov    %ebx,%edi
80104e14:	89 d1                	mov    %edx,%ecx
80104e16:	fc                   	cld    
80104e17:	f3 aa                	rep stos %al,%es:(%edi)
80104e19:	89 ca                	mov    %ecx,%edx
80104e1b:	89 fb                	mov    %edi,%ebx
80104e1d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e20:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e23:	90                   	nop
80104e24:	5b                   	pop    %ebx
80104e25:	5f                   	pop    %edi
80104e26:	5d                   	pop    %ebp
80104e27:	c3                   	ret    

80104e28 <stosl>:
{
80104e28:	55                   	push   %ebp
80104e29:	89 e5                	mov    %esp,%ebp
80104e2b:	57                   	push   %edi
80104e2c:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104e2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e30:	8b 55 10             	mov    0x10(%ebp),%edx
80104e33:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e36:	89 cb                	mov    %ecx,%ebx
80104e38:	89 df                	mov    %ebx,%edi
80104e3a:	89 d1                	mov    %edx,%ecx
80104e3c:	fc                   	cld    
80104e3d:	f3 ab                	rep stos %eax,%es:(%edi)
80104e3f:	89 ca                	mov    %ecx,%edx
80104e41:	89 fb                	mov    %edi,%ebx
80104e43:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e46:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e49:	90                   	nop
80104e4a:	5b                   	pop    %ebx
80104e4b:	5f                   	pop    %edi
80104e4c:	5d                   	pop    %ebp
80104e4d:	c3                   	ret    

80104e4e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104e4e:	55                   	push   %ebp
80104e4f:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104e51:	8b 45 08             	mov    0x8(%ebp),%eax
80104e54:	83 e0 03             	and    $0x3,%eax
80104e57:	85 c0                	test   %eax,%eax
80104e59:	75 43                	jne    80104e9e <memset+0x50>
80104e5b:	8b 45 10             	mov    0x10(%ebp),%eax
80104e5e:	83 e0 03             	and    $0x3,%eax
80104e61:	85 c0                	test   %eax,%eax
80104e63:	75 39                	jne    80104e9e <memset+0x50>
    c &= 0xFF;
80104e65:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e6c:	8b 45 10             	mov    0x10(%ebp),%eax
80104e6f:	c1 e8 02             	shr    $0x2,%eax
80104e72:	89 c2                	mov    %eax,%edx
80104e74:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e77:	c1 e0 18             	shl    $0x18,%eax
80104e7a:	89 c1                	mov    %eax,%ecx
80104e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e7f:	c1 e0 10             	shl    $0x10,%eax
80104e82:	09 c1                	or     %eax,%ecx
80104e84:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e87:	c1 e0 08             	shl    $0x8,%eax
80104e8a:	09 c8                	or     %ecx,%eax
80104e8c:	0b 45 0c             	or     0xc(%ebp),%eax
80104e8f:	52                   	push   %edx
80104e90:	50                   	push   %eax
80104e91:	ff 75 08             	push   0x8(%ebp)
80104e94:	e8 8f ff ff ff       	call   80104e28 <stosl>
80104e99:	83 c4 0c             	add    $0xc,%esp
80104e9c:	eb 12                	jmp    80104eb0 <memset+0x62>
  } else
    stosb(dst, c, n);
80104e9e:	8b 45 10             	mov    0x10(%ebp),%eax
80104ea1:	50                   	push   %eax
80104ea2:	ff 75 0c             	push   0xc(%ebp)
80104ea5:	ff 75 08             	push   0x8(%ebp)
80104ea8:	e8 55 ff ff ff       	call   80104e02 <stosb>
80104ead:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104eb0:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104eb3:	c9                   	leave  
80104eb4:	c3                   	ret    

80104eb5 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104eb5:	55                   	push   %ebp
80104eb6:	89 e5                	mov    %esp,%ebp
80104eb8:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ebe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ec4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104ec7:	eb 30                	jmp    80104ef9 <memcmp+0x44>
    if(*s1 != *s2)
80104ec9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ecc:	0f b6 10             	movzbl (%eax),%edx
80104ecf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ed2:	0f b6 00             	movzbl (%eax),%eax
80104ed5:	38 c2                	cmp    %al,%dl
80104ed7:	74 18                	je     80104ef1 <memcmp+0x3c>
      return *s1 - *s2;
80104ed9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104edc:	0f b6 00             	movzbl (%eax),%eax
80104edf:	0f b6 d0             	movzbl %al,%edx
80104ee2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ee5:	0f b6 00             	movzbl (%eax),%eax
80104ee8:	0f b6 c8             	movzbl %al,%ecx
80104eeb:	89 d0                	mov    %edx,%eax
80104eed:	29 c8                	sub    %ecx,%eax
80104eef:	eb 1a                	jmp    80104f0b <memcmp+0x56>
    s1++, s2++;
80104ef1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104ef5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104ef9:	8b 45 10             	mov    0x10(%ebp),%eax
80104efc:	8d 50 ff             	lea    -0x1(%eax),%edx
80104eff:	89 55 10             	mov    %edx,0x10(%ebp)
80104f02:	85 c0                	test   %eax,%eax
80104f04:	75 c3                	jne    80104ec9 <memcmp+0x14>
  }

  return 0;
80104f06:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f0b:	c9                   	leave  
80104f0c:	c3                   	ret    

80104f0d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104f0d:	55                   	push   %ebp
80104f0e:	89 e5                	mov    %esp,%ebp
80104f10:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104f13:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f16:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104f19:	8b 45 08             	mov    0x8(%ebp),%eax
80104f1c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104f1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f22:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104f25:	73 54                	jae    80104f7b <memmove+0x6e>
80104f27:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f2a:	8b 45 10             	mov    0x10(%ebp),%eax
80104f2d:	01 d0                	add    %edx,%eax
80104f2f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104f32:	73 47                	jae    80104f7b <memmove+0x6e>
    s += n;
80104f34:	8b 45 10             	mov    0x10(%ebp),%eax
80104f37:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104f3a:	8b 45 10             	mov    0x10(%ebp),%eax
80104f3d:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104f40:	eb 13                	jmp    80104f55 <memmove+0x48>
      *--d = *--s;
80104f42:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104f46:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104f4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f4d:	0f b6 10             	movzbl (%eax),%edx
80104f50:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f53:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f55:	8b 45 10             	mov    0x10(%ebp),%eax
80104f58:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f5b:	89 55 10             	mov    %edx,0x10(%ebp)
80104f5e:	85 c0                	test   %eax,%eax
80104f60:	75 e0                	jne    80104f42 <memmove+0x35>
  if(s < d && s + n > d){
80104f62:	eb 24                	jmp    80104f88 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104f64:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f67:	8d 42 01             	lea    0x1(%edx),%eax
80104f6a:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104f6d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f70:	8d 48 01             	lea    0x1(%eax),%ecx
80104f73:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104f76:	0f b6 12             	movzbl (%edx),%edx
80104f79:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f7b:	8b 45 10             	mov    0x10(%ebp),%eax
80104f7e:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f81:	89 55 10             	mov    %edx,0x10(%ebp)
80104f84:	85 c0                	test   %eax,%eax
80104f86:	75 dc                	jne    80104f64 <memmove+0x57>

  return dst;
80104f88:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104f8b:	c9                   	leave  
80104f8c:	c3                   	ret    

80104f8d <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104f8d:	55                   	push   %ebp
80104f8e:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104f90:	ff 75 10             	push   0x10(%ebp)
80104f93:	ff 75 0c             	push   0xc(%ebp)
80104f96:	ff 75 08             	push   0x8(%ebp)
80104f99:	e8 6f ff ff ff       	call   80104f0d <memmove>
80104f9e:	83 c4 0c             	add    $0xc,%esp
}
80104fa1:	c9                   	leave  
80104fa2:	c3                   	ret    

80104fa3 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104fa3:	55                   	push   %ebp
80104fa4:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104fa6:	eb 0c                	jmp    80104fb4 <strncmp+0x11>
    n--, p++, q++;
80104fa8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104fb0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104fb4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fb8:	74 1a                	je     80104fd4 <strncmp+0x31>
80104fba:	8b 45 08             	mov    0x8(%ebp),%eax
80104fbd:	0f b6 00             	movzbl (%eax),%eax
80104fc0:	84 c0                	test   %al,%al
80104fc2:	74 10                	je     80104fd4 <strncmp+0x31>
80104fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc7:	0f b6 10             	movzbl (%eax),%edx
80104fca:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fcd:	0f b6 00             	movzbl (%eax),%eax
80104fd0:	38 c2                	cmp    %al,%dl
80104fd2:	74 d4                	je     80104fa8 <strncmp+0x5>
  if(n == 0)
80104fd4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fd8:	75 07                	jne    80104fe1 <strncmp+0x3e>
    return 0;
80104fda:	b8 00 00 00 00       	mov    $0x0,%eax
80104fdf:	eb 16                	jmp    80104ff7 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe4:	0f b6 00             	movzbl (%eax),%eax
80104fe7:	0f b6 d0             	movzbl %al,%edx
80104fea:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fed:	0f b6 00             	movzbl (%eax),%eax
80104ff0:	0f b6 c8             	movzbl %al,%ecx
80104ff3:	89 d0                	mov    %edx,%eax
80104ff5:	29 c8                	sub    %ecx,%eax
}
80104ff7:	5d                   	pop    %ebp
80104ff8:	c3                   	ret    

80104ff9 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104ff9:	55                   	push   %ebp
80104ffa:	89 e5                	mov    %esp,%ebp
80104ffc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104fff:	8b 45 08             	mov    0x8(%ebp),%eax
80105002:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105005:	90                   	nop
80105006:	8b 45 10             	mov    0x10(%ebp),%eax
80105009:	8d 50 ff             	lea    -0x1(%eax),%edx
8010500c:	89 55 10             	mov    %edx,0x10(%ebp)
8010500f:	85 c0                	test   %eax,%eax
80105011:	7e 2c                	jle    8010503f <strncpy+0x46>
80105013:	8b 55 0c             	mov    0xc(%ebp),%edx
80105016:	8d 42 01             	lea    0x1(%edx),%eax
80105019:	89 45 0c             	mov    %eax,0xc(%ebp)
8010501c:	8b 45 08             	mov    0x8(%ebp),%eax
8010501f:	8d 48 01             	lea    0x1(%eax),%ecx
80105022:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105025:	0f b6 12             	movzbl (%edx),%edx
80105028:	88 10                	mov    %dl,(%eax)
8010502a:	0f b6 00             	movzbl (%eax),%eax
8010502d:	84 c0                	test   %al,%al
8010502f:	75 d5                	jne    80105006 <strncpy+0xd>
    ;
  while(n-- > 0)
80105031:	eb 0c                	jmp    8010503f <strncpy+0x46>
    *s++ = 0;
80105033:	8b 45 08             	mov    0x8(%ebp),%eax
80105036:	8d 50 01             	lea    0x1(%eax),%edx
80105039:	89 55 08             	mov    %edx,0x8(%ebp)
8010503c:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010503f:	8b 45 10             	mov    0x10(%ebp),%eax
80105042:	8d 50 ff             	lea    -0x1(%eax),%edx
80105045:	89 55 10             	mov    %edx,0x10(%ebp)
80105048:	85 c0                	test   %eax,%eax
8010504a:	7f e7                	jg     80105033 <strncpy+0x3a>
  return os;
8010504c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010504f:	c9                   	leave  
80105050:	c3                   	ret    

80105051 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105051:	55                   	push   %ebp
80105052:	89 e5                	mov    %esp,%ebp
80105054:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105057:	8b 45 08             	mov    0x8(%ebp),%eax
8010505a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010505d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105061:	7f 05                	jg     80105068 <safestrcpy+0x17>
    return os;
80105063:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105066:	eb 32                	jmp    8010509a <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80105068:	90                   	nop
80105069:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010506d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105071:	7e 1e                	jle    80105091 <safestrcpy+0x40>
80105073:	8b 55 0c             	mov    0xc(%ebp),%edx
80105076:	8d 42 01             	lea    0x1(%edx),%eax
80105079:	89 45 0c             	mov    %eax,0xc(%ebp)
8010507c:	8b 45 08             	mov    0x8(%ebp),%eax
8010507f:	8d 48 01             	lea    0x1(%eax),%ecx
80105082:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105085:	0f b6 12             	movzbl (%edx),%edx
80105088:	88 10                	mov    %dl,(%eax)
8010508a:	0f b6 00             	movzbl (%eax),%eax
8010508d:	84 c0                	test   %al,%al
8010508f:	75 d8                	jne    80105069 <safestrcpy+0x18>
    ;
  *s = 0;
80105091:	8b 45 08             	mov    0x8(%ebp),%eax
80105094:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105097:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010509a:	c9                   	leave  
8010509b:	c3                   	ret    

8010509c <strlen>:

int
strlen(const char *s)
{
8010509c:	55                   	push   %ebp
8010509d:	89 e5                	mov    %esp,%ebp
8010509f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801050a2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801050a9:	eb 04                	jmp    801050af <strlen+0x13>
801050ab:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050af:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050b2:	8b 45 08             	mov    0x8(%ebp),%eax
801050b5:	01 d0                	add    %edx,%eax
801050b7:	0f b6 00             	movzbl (%eax),%eax
801050ba:	84 c0                	test   %al,%al
801050bc:	75 ed                	jne    801050ab <strlen+0xf>
    ;
  return n;
801050be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050c1:	c9                   	leave  
801050c2:	c3                   	ret    

801050c3 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801050c3:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801050c7:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801050cb:	55                   	push   %ebp
  pushl %ebx
801050cc:	53                   	push   %ebx
  pushl %esi
801050cd:	56                   	push   %esi
  pushl %edi
801050ce:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801050cf:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801050d1:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801050d3:	5f                   	pop    %edi
  popl %esi
801050d4:	5e                   	pop    %esi
  popl %ebx
801050d5:	5b                   	pop    %ebx
  popl %ebp
801050d6:	5d                   	pop    %ebp
  ret
801050d7:	c3                   	ret    

801050d8 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801050d8:	55                   	push   %ebp
801050d9:	89 e5                	mov    %esp,%ebp
  //struct proc *curproc = myproc();

  if(addr >= /*curproc->sz*/ KERNBASE || addr+4 > /*curproc->sz*/ KERNBASE)
801050db:	8b 45 08             	mov    0x8(%ebp),%eax
801050de:	85 c0                	test   %eax,%eax
801050e0:	78 0d                	js     801050ef <fetchint+0x17>
801050e2:	8b 45 08             	mov    0x8(%ebp),%eax
801050e5:	83 c0 04             	add    $0x4,%eax
801050e8:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801050ed:	76 07                	jbe    801050f6 <fetchint+0x1e>
    return -1;
801050ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050f4:	eb 0f                	jmp    80105105 <fetchint+0x2d>
  *ip = *(int*)(addr);
801050f6:	8b 45 08             	mov    0x8(%ebp),%eax
801050f9:	8b 10                	mov    (%eax),%edx
801050fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801050fe:	89 10                	mov    %edx,(%eax)
  return 0;
80105100:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105105:	5d                   	pop    %ebp
80105106:	c3                   	ret    

80105107 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105107:	55                   	push   %ebp
80105108:	89 e5                	mov    %esp,%ebp
8010510a:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;
  //struct proc *curproc = myproc();

  if(addr >= /*curproc->sz*/ KERNBASE)
8010510d:	8b 45 08             	mov    0x8(%ebp),%eax
80105110:	85 c0                	test   %eax,%eax
80105112:	79 07                	jns    8010511b <fetchstr+0x14>
    return -1;
80105114:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105119:	eb 40                	jmp    8010515b <fetchstr+0x54>
  *pp = (char*)addr;
8010511b:	8b 55 08             	mov    0x8(%ebp),%edx
8010511e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105121:	89 10                	mov    %edx,(%eax)
  ep = (char*)/*curproc->sz*/ KERNBASE;
80105123:	c7 45 f8 00 00 00 80 	movl   $0x80000000,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
8010512a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010512d:	8b 00                	mov    (%eax),%eax
8010512f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105132:	eb 1a                	jmp    8010514e <fetchstr+0x47>
    if(*s == 0)
80105134:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105137:	0f b6 00             	movzbl (%eax),%eax
8010513a:	84 c0                	test   %al,%al
8010513c:	75 0c                	jne    8010514a <fetchstr+0x43>
      return s - *pp;
8010513e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105141:	8b 10                	mov    (%eax),%edx
80105143:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105146:	29 d0                	sub    %edx,%eax
80105148:	eb 11                	jmp    8010515b <fetchstr+0x54>
  for(s = *pp; s < ep; s++){
8010514a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010514e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105151:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105154:	72 de                	jb     80105134 <fetchstr+0x2d>
  }
  return -1;
80105156:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010515b:	c9                   	leave  
8010515c:	c3                   	ret    

8010515d <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010515d:	55                   	push   %ebp
8010515e:	89 e5                	mov    %esp,%ebp
80105160:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105163:	e8 b0 e8 ff ff       	call   80103a18 <myproc>
80105168:	8b 40 18             	mov    0x18(%eax),%eax
8010516b:	8b 50 44             	mov    0x44(%eax),%edx
8010516e:	8b 45 08             	mov    0x8(%ebp),%eax
80105171:	c1 e0 02             	shl    $0x2,%eax
80105174:	01 d0                	add    %edx,%eax
80105176:	83 c0 04             	add    $0x4,%eax
80105179:	83 ec 08             	sub    $0x8,%esp
8010517c:	ff 75 0c             	push   0xc(%ebp)
8010517f:	50                   	push   %eax
80105180:	e8 53 ff ff ff       	call   801050d8 <fetchint>
80105185:	83 c4 10             	add    $0x10,%esp
}
80105188:	c9                   	leave  
80105189:	c3                   	ret    

8010518a <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010518a:	55                   	push   %ebp
8010518b:	89 e5                	mov    %esp,%ebp
8010518d:	83 ec 18             	sub    $0x18,%esp
  int i;
  //struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
80105190:	83 ec 08             	sub    $0x8,%esp
80105193:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105196:	50                   	push   %eax
80105197:	ff 75 08             	push   0x8(%ebp)
8010519a:	e8 be ff ff ff       	call   8010515d <argint>
8010519f:	83 c4 10             	add    $0x10,%esp
801051a2:	85 c0                	test   %eax,%eax
801051a4:	79 07                	jns    801051ad <argptr+0x23>
    return -1;
801051a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ab:	eb 34                	jmp    801051e1 <argptr+0x57>
  if(size < 0 || (uint)i >= /*curproc->sz*/ KERNBASE || (uint)i+size > /*curproc->sz*/ KERNBASE)
801051ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051b1:	78 18                	js     801051cb <argptr+0x41>
801051b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b6:	85 c0                	test   %eax,%eax
801051b8:	78 11                	js     801051cb <argptr+0x41>
801051ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051bd:	89 c2                	mov    %eax,%edx
801051bf:	8b 45 10             	mov    0x10(%ebp),%eax
801051c2:	01 d0                	add    %edx,%eax
801051c4:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801051c9:	76 07                	jbe    801051d2 <argptr+0x48>
    return -1;
801051cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051d0:	eb 0f                	jmp    801051e1 <argptr+0x57>
  *pp = (char*)i;
801051d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d5:	89 c2                	mov    %eax,%edx
801051d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801051da:	89 10                	mov    %edx,(%eax)
  return 0;
801051dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051e1:	c9                   	leave  
801051e2:	c3                   	ret    

801051e3 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801051e3:	55                   	push   %ebp
801051e4:	89 e5                	mov    %esp,%ebp
801051e6:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801051e9:	83 ec 08             	sub    $0x8,%esp
801051ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051ef:	50                   	push   %eax
801051f0:	ff 75 08             	push   0x8(%ebp)
801051f3:	e8 65 ff ff ff       	call   8010515d <argint>
801051f8:	83 c4 10             	add    $0x10,%esp
801051fb:	85 c0                	test   %eax,%eax
801051fd:	79 07                	jns    80105206 <argstr+0x23>
    return -1;
801051ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105204:	eb 12                	jmp    80105218 <argstr+0x35>
  return fetchstr(addr, pp);
80105206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105209:	83 ec 08             	sub    $0x8,%esp
8010520c:	ff 75 0c             	push   0xc(%ebp)
8010520f:	50                   	push   %eax
80105210:	e8 f2 fe ff ff       	call   80105107 <fetchstr>
80105215:	83 c4 10             	add    $0x10,%esp
}
80105218:	c9                   	leave  
80105219:	c3                   	ret    

8010521a <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
8010521a:	55                   	push   %ebp
8010521b:	89 e5                	mov    %esp,%ebp
8010521d:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105220:	e8 f3 e7 ff ff       	call   80103a18 <myproc>
80105225:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010522b:	8b 40 18             	mov    0x18(%eax),%eax
8010522e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105231:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105234:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105238:	7e 2f                	jle    80105269 <syscall+0x4f>
8010523a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010523d:	83 f8 1b             	cmp    $0x1b,%eax
80105240:	77 27                	ja     80105269 <syscall+0x4f>
80105242:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105245:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010524c:	85 c0                	test   %eax,%eax
8010524e:	74 19                	je     80105269 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105250:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105253:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010525a:	ff d0                	call   *%eax
8010525c:	89 c2                	mov    %eax,%edx
8010525e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105261:	8b 40 18             	mov    0x18(%eax),%eax
80105264:	89 50 1c             	mov    %edx,0x1c(%eax)
80105267:	eb 2c                	jmp    80105295 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105269:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010526c:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010526f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105272:	8b 40 10             	mov    0x10(%eax),%eax
80105275:	ff 75 f0             	push   -0x10(%ebp)
80105278:	52                   	push   %edx
80105279:	50                   	push   %eax
8010527a:	68 b9 ad 10 80       	push   $0x8010adb9
8010527f:	e8 70 b1 ff ff       	call   801003f4 <cprintf>
80105284:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010528a:	8b 40 18             	mov    0x18(%eax),%eax
8010528d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105294:	90                   	nop
80105295:	90                   	nop
80105296:	c9                   	leave  
80105297:	c3                   	ret    

80105298 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105298:	55                   	push   %ebp
80105299:	89 e5                	mov    %esp,%ebp
8010529b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010529e:	83 ec 08             	sub    $0x8,%esp
801052a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052a4:	50                   	push   %eax
801052a5:	ff 75 08             	push   0x8(%ebp)
801052a8:	e8 b0 fe ff ff       	call   8010515d <argint>
801052ad:	83 c4 10             	add    $0x10,%esp
801052b0:	85 c0                	test   %eax,%eax
801052b2:	79 07                	jns    801052bb <argfd+0x23>
    return -1;
801052b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b9:	eb 4f                	jmp    8010530a <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801052bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052be:	85 c0                	test   %eax,%eax
801052c0:	78 20                	js     801052e2 <argfd+0x4a>
801052c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052c5:	83 f8 0f             	cmp    $0xf,%eax
801052c8:	7f 18                	jg     801052e2 <argfd+0x4a>
801052ca:	e8 49 e7 ff ff       	call   80103a18 <myproc>
801052cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052d2:	83 c2 08             	add    $0x8,%edx
801052d5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801052d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052e0:	75 07                	jne    801052e9 <argfd+0x51>
    return -1;
801052e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052e7:	eb 21                	jmp    8010530a <argfd+0x72>
  if(pfd)
801052e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801052ed:	74 08                	je     801052f7 <argfd+0x5f>
    *pfd = fd;
801052ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f5:	89 10                	mov    %edx,(%eax)
  if(pf)
801052f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052fb:	74 08                	je     80105305 <argfd+0x6d>
    *pf = f;
801052fd:	8b 45 10             	mov    0x10(%ebp),%eax
80105300:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105303:	89 10                	mov    %edx,(%eax)
  return 0;
80105305:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010530a:	c9                   	leave  
8010530b:	c3                   	ret    

8010530c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010530c:	55                   	push   %ebp
8010530d:	89 e5                	mov    %esp,%ebp
8010530f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105312:	e8 01 e7 ff ff       	call   80103a18 <myproc>
80105317:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010531a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105321:	eb 2a                	jmp    8010534d <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105323:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105326:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105329:	83 c2 08             	add    $0x8,%edx
8010532c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105330:	85 c0                	test   %eax,%eax
80105332:	75 15                	jne    80105349 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105337:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010533a:	8d 4a 08             	lea    0x8(%edx),%ecx
8010533d:	8b 55 08             	mov    0x8(%ebp),%edx
80105340:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105347:	eb 0f                	jmp    80105358 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105349:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010534d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105351:	7e d0                	jle    80105323 <fdalloc+0x17>
    }
  }
  return -1;
80105353:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105358:	c9                   	leave  
80105359:	c3                   	ret    

8010535a <sys_dup>:

int
sys_dup(void)
{
8010535a:	55                   	push   %ebp
8010535b:	89 e5                	mov    %esp,%ebp
8010535d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105360:	83 ec 04             	sub    $0x4,%esp
80105363:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105366:	50                   	push   %eax
80105367:	6a 00                	push   $0x0
80105369:	6a 00                	push   $0x0
8010536b:	e8 28 ff ff ff       	call   80105298 <argfd>
80105370:	83 c4 10             	add    $0x10,%esp
80105373:	85 c0                	test   %eax,%eax
80105375:	79 07                	jns    8010537e <sys_dup+0x24>
    return -1;
80105377:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010537c:	eb 31                	jmp    801053af <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010537e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105381:	83 ec 0c             	sub    $0xc,%esp
80105384:	50                   	push   %eax
80105385:	e8 82 ff ff ff       	call   8010530c <fdalloc>
8010538a:	83 c4 10             	add    $0x10,%esp
8010538d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105390:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105394:	79 07                	jns    8010539d <sys_dup+0x43>
    return -1;
80105396:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010539b:	eb 12                	jmp    801053af <sys_dup+0x55>
  filedup(f);
8010539d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053a0:	83 ec 0c             	sub    $0xc,%esp
801053a3:	50                   	push   %eax
801053a4:	e8 89 bc ff ff       	call   80101032 <filedup>
801053a9:	83 c4 10             	add    $0x10,%esp
  return fd;
801053ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801053af:	c9                   	leave  
801053b0:	c3                   	ret    

801053b1 <sys_read>:

int
sys_read(void)
{
801053b1:	55                   	push   %ebp
801053b2:	89 e5                	mov    %esp,%ebp
801053b4:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053b7:	83 ec 04             	sub    $0x4,%esp
801053ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053bd:	50                   	push   %eax
801053be:	6a 00                	push   $0x0
801053c0:	6a 00                	push   $0x0
801053c2:	e8 d1 fe ff ff       	call   80105298 <argfd>
801053c7:	83 c4 10             	add    $0x10,%esp
801053ca:	85 c0                	test   %eax,%eax
801053cc:	78 2e                	js     801053fc <sys_read+0x4b>
801053ce:	83 ec 08             	sub    $0x8,%esp
801053d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053d4:	50                   	push   %eax
801053d5:	6a 02                	push   $0x2
801053d7:	e8 81 fd ff ff       	call   8010515d <argint>
801053dc:	83 c4 10             	add    $0x10,%esp
801053df:	85 c0                	test   %eax,%eax
801053e1:	78 19                	js     801053fc <sys_read+0x4b>
801053e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e6:	83 ec 04             	sub    $0x4,%esp
801053e9:	50                   	push   %eax
801053ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053ed:	50                   	push   %eax
801053ee:	6a 01                	push   $0x1
801053f0:	e8 95 fd ff ff       	call   8010518a <argptr>
801053f5:	83 c4 10             	add    $0x10,%esp
801053f8:	85 c0                	test   %eax,%eax
801053fa:	79 07                	jns    80105403 <sys_read+0x52>
    return -1;
801053fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105401:	eb 17                	jmp    8010541a <sys_read+0x69>
  return fileread(f, p, n);
80105403:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105406:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105409:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010540c:	83 ec 04             	sub    $0x4,%esp
8010540f:	51                   	push   %ecx
80105410:	52                   	push   %edx
80105411:	50                   	push   %eax
80105412:	e8 ab bd ff ff       	call   801011c2 <fileread>
80105417:	83 c4 10             	add    $0x10,%esp
}
8010541a:	c9                   	leave  
8010541b:	c3                   	ret    

8010541c <sys_write>:

int
sys_write(void)
{
8010541c:	55                   	push   %ebp
8010541d:	89 e5                	mov    %esp,%ebp
8010541f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105422:	83 ec 04             	sub    $0x4,%esp
80105425:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105428:	50                   	push   %eax
80105429:	6a 00                	push   $0x0
8010542b:	6a 00                	push   $0x0
8010542d:	e8 66 fe ff ff       	call   80105298 <argfd>
80105432:	83 c4 10             	add    $0x10,%esp
80105435:	85 c0                	test   %eax,%eax
80105437:	78 2e                	js     80105467 <sys_write+0x4b>
80105439:	83 ec 08             	sub    $0x8,%esp
8010543c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010543f:	50                   	push   %eax
80105440:	6a 02                	push   $0x2
80105442:	e8 16 fd ff ff       	call   8010515d <argint>
80105447:	83 c4 10             	add    $0x10,%esp
8010544a:	85 c0                	test   %eax,%eax
8010544c:	78 19                	js     80105467 <sys_write+0x4b>
8010544e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105451:	83 ec 04             	sub    $0x4,%esp
80105454:	50                   	push   %eax
80105455:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105458:	50                   	push   %eax
80105459:	6a 01                	push   $0x1
8010545b:	e8 2a fd ff ff       	call   8010518a <argptr>
80105460:	83 c4 10             	add    $0x10,%esp
80105463:	85 c0                	test   %eax,%eax
80105465:	79 07                	jns    8010546e <sys_write+0x52>
    return -1;
80105467:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010546c:	eb 17                	jmp    80105485 <sys_write+0x69>
  return filewrite(f, p, n);
8010546e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105471:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105477:	83 ec 04             	sub    $0x4,%esp
8010547a:	51                   	push   %ecx
8010547b:	52                   	push   %edx
8010547c:	50                   	push   %eax
8010547d:	e8 f8 bd ff ff       	call   8010127a <filewrite>
80105482:	83 c4 10             	add    $0x10,%esp
}
80105485:	c9                   	leave  
80105486:	c3                   	ret    

80105487 <sys_close>:

int
sys_close(void)
{
80105487:	55                   	push   %ebp
80105488:	89 e5                	mov    %esp,%ebp
8010548a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010548d:	83 ec 04             	sub    $0x4,%esp
80105490:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105493:	50                   	push   %eax
80105494:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105497:	50                   	push   %eax
80105498:	6a 00                	push   $0x0
8010549a:	e8 f9 fd ff ff       	call   80105298 <argfd>
8010549f:	83 c4 10             	add    $0x10,%esp
801054a2:	85 c0                	test   %eax,%eax
801054a4:	79 07                	jns    801054ad <sys_close+0x26>
    return -1;
801054a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ab:	eb 27                	jmp    801054d4 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801054ad:	e8 66 e5 ff ff       	call   80103a18 <myproc>
801054b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054b5:	83 c2 08             	add    $0x8,%edx
801054b8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801054bf:	00 
  fileclose(f);
801054c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054c3:	83 ec 0c             	sub    $0xc,%esp
801054c6:	50                   	push   %eax
801054c7:	e8 b7 bb ff ff       	call   80101083 <fileclose>
801054cc:	83 c4 10             	add    $0x10,%esp
  return 0;
801054cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054d4:	c9                   	leave  
801054d5:	c3                   	ret    

801054d6 <sys_fstat>:

int
sys_fstat(void)
{
801054d6:	55                   	push   %ebp
801054d7:	89 e5                	mov    %esp,%ebp
801054d9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801054dc:	83 ec 04             	sub    $0x4,%esp
801054df:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054e2:	50                   	push   %eax
801054e3:	6a 00                	push   $0x0
801054e5:	6a 00                	push   $0x0
801054e7:	e8 ac fd ff ff       	call   80105298 <argfd>
801054ec:	83 c4 10             	add    $0x10,%esp
801054ef:	85 c0                	test   %eax,%eax
801054f1:	78 17                	js     8010550a <sys_fstat+0x34>
801054f3:	83 ec 04             	sub    $0x4,%esp
801054f6:	6a 14                	push   $0x14
801054f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054fb:	50                   	push   %eax
801054fc:	6a 01                	push   $0x1
801054fe:	e8 87 fc ff ff       	call   8010518a <argptr>
80105503:	83 c4 10             	add    $0x10,%esp
80105506:	85 c0                	test   %eax,%eax
80105508:	79 07                	jns    80105511 <sys_fstat+0x3b>
    return -1;
8010550a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010550f:	eb 13                	jmp    80105524 <sys_fstat+0x4e>
  return filestat(f, st);
80105511:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105517:	83 ec 08             	sub    $0x8,%esp
8010551a:	52                   	push   %edx
8010551b:	50                   	push   %eax
8010551c:	e8 4a bc ff ff       	call   8010116b <filestat>
80105521:	83 c4 10             	add    $0x10,%esp
}
80105524:	c9                   	leave  
80105525:	c3                   	ret    

80105526 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105526:	55                   	push   %ebp
80105527:	89 e5                	mov    %esp,%ebp
80105529:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010552c:	83 ec 08             	sub    $0x8,%esp
8010552f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105532:	50                   	push   %eax
80105533:	6a 00                	push   $0x0
80105535:	e8 a9 fc ff ff       	call   801051e3 <argstr>
8010553a:	83 c4 10             	add    $0x10,%esp
8010553d:	85 c0                	test   %eax,%eax
8010553f:	78 15                	js     80105556 <sys_link+0x30>
80105541:	83 ec 08             	sub    $0x8,%esp
80105544:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105547:	50                   	push   %eax
80105548:	6a 01                	push   $0x1
8010554a:	e8 94 fc ff ff       	call   801051e3 <argstr>
8010554f:	83 c4 10             	add    $0x10,%esp
80105552:	85 c0                	test   %eax,%eax
80105554:	79 0a                	jns    80105560 <sys_link+0x3a>
    return -1;
80105556:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010555b:	e9 68 01 00 00       	jmp    801056c8 <sys_link+0x1a2>

  begin_op();
80105560:	e8 bf da ff ff       	call   80103024 <begin_op>
  if((ip = namei(old)) == 0){
80105565:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105568:	83 ec 0c             	sub    $0xc,%esp
8010556b:	50                   	push   %eax
8010556c:	e8 94 cf ff ff       	call   80102505 <namei>
80105571:	83 c4 10             	add    $0x10,%esp
80105574:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105577:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010557b:	75 0f                	jne    8010558c <sys_link+0x66>
    end_op();
8010557d:	e8 2e db ff ff       	call   801030b0 <end_op>
    return -1;
80105582:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105587:	e9 3c 01 00 00       	jmp    801056c8 <sys_link+0x1a2>
  }

  ilock(ip);
8010558c:	83 ec 0c             	sub    $0xc,%esp
8010558f:	ff 75 f4             	push   -0xc(%ebp)
80105592:	e8 3b c4 ff ff       	call   801019d2 <ilock>
80105597:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010559a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055a1:	66 83 f8 01          	cmp    $0x1,%ax
801055a5:	75 1d                	jne    801055c4 <sys_link+0x9e>
    iunlockput(ip);
801055a7:	83 ec 0c             	sub    $0xc,%esp
801055aa:	ff 75 f4             	push   -0xc(%ebp)
801055ad:	e8 51 c6 ff ff       	call   80101c03 <iunlockput>
801055b2:	83 c4 10             	add    $0x10,%esp
    end_op();
801055b5:	e8 f6 da ff ff       	call   801030b0 <end_op>
    return -1;
801055ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055bf:	e9 04 01 00 00       	jmp    801056c8 <sys_link+0x1a2>
  }

  ip->nlink++;
801055c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055cb:	83 c0 01             	add    $0x1,%eax
801055ce:	89 c2                	mov    %eax,%edx
801055d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d3:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801055d7:	83 ec 0c             	sub    $0xc,%esp
801055da:	ff 75 f4             	push   -0xc(%ebp)
801055dd:	e8 13 c2 ff ff       	call   801017f5 <iupdate>
801055e2:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801055e5:	83 ec 0c             	sub    $0xc,%esp
801055e8:	ff 75 f4             	push   -0xc(%ebp)
801055eb:	e8 f5 c4 ff ff       	call   80101ae5 <iunlock>
801055f0:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801055f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801055f6:	83 ec 08             	sub    $0x8,%esp
801055f9:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801055fc:	52                   	push   %edx
801055fd:	50                   	push   %eax
801055fe:	e8 1e cf ff ff       	call   80102521 <nameiparent>
80105603:	83 c4 10             	add    $0x10,%esp
80105606:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105609:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010560d:	74 71                	je     80105680 <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010560f:	83 ec 0c             	sub    $0xc,%esp
80105612:	ff 75 f0             	push   -0x10(%ebp)
80105615:	e8 b8 c3 ff ff       	call   801019d2 <ilock>
8010561a:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010561d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105620:	8b 10                	mov    (%eax),%edx
80105622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105625:	8b 00                	mov    (%eax),%eax
80105627:	39 c2                	cmp    %eax,%edx
80105629:	75 1d                	jne    80105648 <sys_link+0x122>
8010562b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010562e:	8b 40 04             	mov    0x4(%eax),%eax
80105631:	83 ec 04             	sub    $0x4,%esp
80105634:	50                   	push   %eax
80105635:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105638:	50                   	push   %eax
80105639:	ff 75 f0             	push   -0x10(%ebp)
8010563c:	e8 2d cc ff ff       	call   8010226e <dirlink>
80105641:	83 c4 10             	add    $0x10,%esp
80105644:	85 c0                	test   %eax,%eax
80105646:	79 10                	jns    80105658 <sys_link+0x132>
    iunlockput(dp);
80105648:	83 ec 0c             	sub    $0xc,%esp
8010564b:	ff 75 f0             	push   -0x10(%ebp)
8010564e:	e8 b0 c5 ff ff       	call   80101c03 <iunlockput>
80105653:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105656:	eb 29                	jmp    80105681 <sys_link+0x15b>
  }
  iunlockput(dp);
80105658:	83 ec 0c             	sub    $0xc,%esp
8010565b:	ff 75 f0             	push   -0x10(%ebp)
8010565e:	e8 a0 c5 ff ff       	call   80101c03 <iunlockput>
80105663:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105666:	83 ec 0c             	sub    $0xc,%esp
80105669:	ff 75 f4             	push   -0xc(%ebp)
8010566c:	e8 c2 c4 ff ff       	call   80101b33 <iput>
80105671:	83 c4 10             	add    $0x10,%esp

  end_op();
80105674:	e8 37 da ff ff       	call   801030b0 <end_op>

  return 0;
80105679:	b8 00 00 00 00       	mov    $0x0,%eax
8010567e:	eb 48                	jmp    801056c8 <sys_link+0x1a2>
    goto bad;
80105680:	90                   	nop

bad:
  ilock(ip);
80105681:	83 ec 0c             	sub    $0xc,%esp
80105684:	ff 75 f4             	push   -0xc(%ebp)
80105687:	e8 46 c3 ff ff       	call   801019d2 <ilock>
8010568c:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010568f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105692:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105696:	83 e8 01             	sub    $0x1,%eax
80105699:	89 c2                	mov    %eax,%edx
8010569b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010569e:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801056a2:	83 ec 0c             	sub    $0xc,%esp
801056a5:	ff 75 f4             	push   -0xc(%ebp)
801056a8:	e8 48 c1 ff ff       	call   801017f5 <iupdate>
801056ad:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801056b0:	83 ec 0c             	sub    $0xc,%esp
801056b3:	ff 75 f4             	push   -0xc(%ebp)
801056b6:	e8 48 c5 ff ff       	call   80101c03 <iunlockput>
801056bb:	83 c4 10             	add    $0x10,%esp
  end_op();
801056be:	e8 ed d9 ff ff       	call   801030b0 <end_op>
  return -1;
801056c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056c8:	c9                   	leave  
801056c9:	c3                   	ret    

801056ca <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801056ca:	55                   	push   %ebp
801056cb:	89 e5                	mov    %esp,%ebp
801056cd:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056d0:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801056d7:	eb 40                	jmp    80105719 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801056d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056dc:	6a 10                	push   $0x10
801056de:	50                   	push   %eax
801056df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801056e2:	50                   	push   %eax
801056e3:	ff 75 08             	push   0x8(%ebp)
801056e6:	e8 d3 c7 ff ff       	call   80101ebe <readi>
801056eb:	83 c4 10             	add    $0x10,%esp
801056ee:	83 f8 10             	cmp    $0x10,%eax
801056f1:	74 0d                	je     80105700 <isdirempty+0x36>
      panic("isdirempty: readi");
801056f3:	83 ec 0c             	sub    $0xc,%esp
801056f6:	68 d5 ad 10 80       	push   $0x8010add5
801056fb:	e8 a9 ae ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105700:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105704:	66 85 c0             	test   %ax,%ax
80105707:	74 07                	je     80105710 <isdirempty+0x46>
      return 0;
80105709:	b8 00 00 00 00       	mov    $0x0,%eax
8010570e:	eb 1b                	jmp    8010572b <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105713:	83 c0 10             	add    $0x10,%eax
80105716:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105719:	8b 45 08             	mov    0x8(%ebp),%eax
8010571c:	8b 50 58             	mov    0x58(%eax),%edx
8010571f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105722:	39 c2                	cmp    %eax,%edx
80105724:	77 b3                	ja     801056d9 <isdirempty+0xf>
  }
  return 1;
80105726:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010572b:	c9                   	leave  
8010572c:	c3                   	ret    

8010572d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010572d:	55                   	push   %ebp
8010572e:	89 e5                	mov    %esp,%ebp
80105730:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105733:	83 ec 08             	sub    $0x8,%esp
80105736:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105739:	50                   	push   %eax
8010573a:	6a 00                	push   $0x0
8010573c:	e8 a2 fa ff ff       	call   801051e3 <argstr>
80105741:	83 c4 10             	add    $0x10,%esp
80105744:	85 c0                	test   %eax,%eax
80105746:	79 0a                	jns    80105752 <sys_unlink+0x25>
    return -1;
80105748:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010574d:	e9 bf 01 00 00       	jmp    80105911 <sys_unlink+0x1e4>

  begin_op();
80105752:	e8 cd d8 ff ff       	call   80103024 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105757:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010575a:	83 ec 08             	sub    $0x8,%esp
8010575d:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105760:	52                   	push   %edx
80105761:	50                   	push   %eax
80105762:	e8 ba cd ff ff       	call   80102521 <nameiparent>
80105767:	83 c4 10             	add    $0x10,%esp
8010576a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010576d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105771:	75 0f                	jne    80105782 <sys_unlink+0x55>
    end_op();
80105773:	e8 38 d9 ff ff       	call   801030b0 <end_op>
    return -1;
80105778:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010577d:	e9 8f 01 00 00       	jmp    80105911 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105782:	83 ec 0c             	sub    $0xc,%esp
80105785:	ff 75 f4             	push   -0xc(%ebp)
80105788:	e8 45 c2 ff ff       	call   801019d2 <ilock>
8010578d:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105790:	83 ec 08             	sub    $0x8,%esp
80105793:	68 e7 ad 10 80       	push   $0x8010ade7
80105798:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010579b:	50                   	push   %eax
8010579c:	e8 f8 c9 ff ff       	call   80102199 <namecmp>
801057a1:	83 c4 10             	add    $0x10,%esp
801057a4:	85 c0                	test   %eax,%eax
801057a6:	0f 84 49 01 00 00    	je     801058f5 <sys_unlink+0x1c8>
801057ac:	83 ec 08             	sub    $0x8,%esp
801057af:	68 e9 ad 10 80       	push   $0x8010ade9
801057b4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057b7:	50                   	push   %eax
801057b8:	e8 dc c9 ff ff       	call   80102199 <namecmp>
801057bd:	83 c4 10             	add    $0x10,%esp
801057c0:	85 c0                	test   %eax,%eax
801057c2:	0f 84 2d 01 00 00    	je     801058f5 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801057c8:	83 ec 04             	sub    $0x4,%esp
801057cb:	8d 45 c8             	lea    -0x38(%ebp),%eax
801057ce:	50                   	push   %eax
801057cf:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057d2:	50                   	push   %eax
801057d3:	ff 75 f4             	push   -0xc(%ebp)
801057d6:	e8 d9 c9 ff ff       	call   801021b4 <dirlookup>
801057db:	83 c4 10             	add    $0x10,%esp
801057de:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057e5:	0f 84 0d 01 00 00    	je     801058f8 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
801057eb:	83 ec 0c             	sub    $0xc,%esp
801057ee:	ff 75 f0             	push   -0x10(%ebp)
801057f1:	e8 dc c1 ff ff       	call   801019d2 <ilock>
801057f6:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801057f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057fc:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105800:	66 85 c0             	test   %ax,%ax
80105803:	7f 0d                	jg     80105812 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105805:	83 ec 0c             	sub    $0xc,%esp
80105808:	68 ec ad 10 80       	push   $0x8010adec
8010580d:	e8 97 ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105812:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105815:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105819:	66 83 f8 01          	cmp    $0x1,%ax
8010581d:	75 25                	jne    80105844 <sys_unlink+0x117>
8010581f:	83 ec 0c             	sub    $0xc,%esp
80105822:	ff 75 f0             	push   -0x10(%ebp)
80105825:	e8 a0 fe ff ff       	call   801056ca <isdirempty>
8010582a:	83 c4 10             	add    $0x10,%esp
8010582d:	85 c0                	test   %eax,%eax
8010582f:	75 13                	jne    80105844 <sys_unlink+0x117>
    iunlockput(ip);
80105831:	83 ec 0c             	sub    $0xc,%esp
80105834:	ff 75 f0             	push   -0x10(%ebp)
80105837:	e8 c7 c3 ff ff       	call   80101c03 <iunlockput>
8010583c:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010583f:	e9 b5 00 00 00       	jmp    801058f9 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105844:	83 ec 04             	sub    $0x4,%esp
80105847:	6a 10                	push   $0x10
80105849:	6a 00                	push   $0x0
8010584b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010584e:	50                   	push   %eax
8010584f:	e8 fa f5 ff ff       	call   80104e4e <memset>
80105854:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105857:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010585a:	6a 10                	push   $0x10
8010585c:	50                   	push   %eax
8010585d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105860:	50                   	push   %eax
80105861:	ff 75 f4             	push   -0xc(%ebp)
80105864:	e8 aa c7 ff ff       	call   80102013 <writei>
80105869:	83 c4 10             	add    $0x10,%esp
8010586c:	83 f8 10             	cmp    $0x10,%eax
8010586f:	74 0d                	je     8010587e <sys_unlink+0x151>
    panic("unlink: writei");
80105871:	83 ec 0c             	sub    $0xc,%esp
80105874:	68 fe ad 10 80       	push   $0x8010adfe
80105879:	e8 2b ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
8010587e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105881:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105885:	66 83 f8 01          	cmp    $0x1,%ax
80105889:	75 21                	jne    801058ac <sys_unlink+0x17f>
    dp->nlink--;
8010588b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105892:	83 e8 01             	sub    $0x1,%eax
80105895:	89 c2                	mov    %eax,%edx
80105897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010589a:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010589e:	83 ec 0c             	sub    $0xc,%esp
801058a1:	ff 75 f4             	push   -0xc(%ebp)
801058a4:	e8 4c bf ff ff       	call   801017f5 <iupdate>
801058a9:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801058ac:	83 ec 0c             	sub    $0xc,%esp
801058af:	ff 75 f4             	push   -0xc(%ebp)
801058b2:	e8 4c c3 ff ff       	call   80101c03 <iunlockput>
801058b7:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801058ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058bd:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058c1:	83 e8 01             	sub    $0x1,%eax
801058c4:	89 c2                	mov    %eax,%edx
801058c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c9:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801058cd:	83 ec 0c             	sub    $0xc,%esp
801058d0:	ff 75 f0             	push   -0x10(%ebp)
801058d3:	e8 1d bf ff ff       	call   801017f5 <iupdate>
801058d8:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801058db:	83 ec 0c             	sub    $0xc,%esp
801058de:	ff 75 f0             	push   -0x10(%ebp)
801058e1:	e8 1d c3 ff ff       	call   80101c03 <iunlockput>
801058e6:	83 c4 10             	add    $0x10,%esp

  end_op();
801058e9:	e8 c2 d7 ff ff       	call   801030b0 <end_op>

  return 0;
801058ee:	b8 00 00 00 00       	mov    $0x0,%eax
801058f3:	eb 1c                	jmp    80105911 <sys_unlink+0x1e4>
    goto bad;
801058f5:	90                   	nop
801058f6:	eb 01                	jmp    801058f9 <sys_unlink+0x1cc>
    goto bad;
801058f8:	90                   	nop

bad:
  iunlockput(dp);
801058f9:	83 ec 0c             	sub    $0xc,%esp
801058fc:	ff 75 f4             	push   -0xc(%ebp)
801058ff:	e8 ff c2 ff ff       	call   80101c03 <iunlockput>
80105904:	83 c4 10             	add    $0x10,%esp
  end_op();
80105907:	e8 a4 d7 ff ff       	call   801030b0 <end_op>
  return -1;
8010590c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105911:	c9                   	leave  
80105912:	c3                   	ret    

80105913 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105913:	55                   	push   %ebp
80105914:	89 e5                	mov    %esp,%ebp
80105916:	83 ec 38             	sub    $0x38,%esp
80105919:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010591c:	8b 55 10             	mov    0x10(%ebp),%edx
8010591f:	8b 45 14             	mov    0x14(%ebp),%eax
80105922:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105926:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010592a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010592e:	83 ec 08             	sub    $0x8,%esp
80105931:	8d 45 de             	lea    -0x22(%ebp),%eax
80105934:	50                   	push   %eax
80105935:	ff 75 08             	push   0x8(%ebp)
80105938:	e8 e4 cb ff ff       	call   80102521 <nameiparent>
8010593d:	83 c4 10             	add    $0x10,%esp
80105940:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105943:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105947:	75 0a                	jne    80105953 <create+0x40>
    return 0;
80105949:	b8 00 00 00 00       	mov    $0x0,%eax
8010594e:	e9 90 01 00 00       	jmp    80105ae3 <create+0x1d0>
  ilock(dp);
80105953:	83 ec 0c             	sub    $0xc,%esp
80105956:	ff 75 f4             	push   -0xc(%ebp)
80105959:	e8 74 c0 ff ff       	call   801019d2 <ilock>
8010595e:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105961:	83 ec 04             	sub    $0x4,%esp
80105964:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105967:	50                   	push   %eax
80105968:	8d 45 de             	lea    -0x22(%ebp),%eax
8010596b:	50                   	push   %eax
8010596c:	ff 75 f4             	push   -0xc(%ebp)
8010596f:	e8 40 c8 ff ff       	call   801021b4 <dirlookup>
80105974:	83 c4 10             	add    $0x10,%esp
80105977:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010597a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010597e:	74 50                	je     801059d0 <create+0xbd>
    iunlockput(dp);
80105980:	83 ec 0c             	sub    $0xc,%esp
80105983:	ff 75 f4             	push   -0xc(%ebp)
80105986:	e8 78 c2 ff ff       	call   80101c03 <iunlockput>
8010598b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010598e:	83 ec 0c             	sub    $0xc,%esp
80105991:	ff 75 f0             	push   -0x10(%ebp)
80105994:	e8 39 c0 ff ff       	call   801019d2 <ilock>
80105999:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010599c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801059a1:	75 15                	jne    801059b8 <create+0xa5>
801059a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059aa:	66 83 f8 02          	cmp    $0x2,%ax
801059ae:	75 08                	jne    801059b8 <create+0xa5>
      return ip;
801059b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b3:	e9 2b 01 00 00       	jmp    80105ae3 <create+0x1d0>
    iunlockput(ip);
801059b8:	83 ec 0c             	sub    $0xc,%esp
801059bb:	ff 75 f0             	push   -0x10(%ebp)
801059be:	e8 40 c2 ff ff       	call   80101c03 <iunlockput>
801059c3:	83 c4 10             	add    $0x10,%esp
    return 0;
801059c6:	b8 00 00 00 00       	mov    $0x0,%eax
801059cb:	e9 13 01 00 00       	jmp    80105ae3 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801059d0:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801059d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d7:	8b 00                	mov    (%eax),%eax
801059d9:	83 ec 08             	sub    $0x8,%esp
801059dc:	52                   	push   %edx
801059dd:	50                   	push   %eax
801059de:	e8 3b bd ff ff       	call   8010171e <ialloc>
801059e3:	83 c4 10             	add    $0x10,%esp
801059e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059ed:	75 0d                	jne    801059fc <create+0xe9>
    panic("create: ialloc");
801059ef:	83 ec 0c             	sub    $0xc,%esp
801059f2:	68 0d ae 10 80       	push   $0x8010ae0d
801059f7:	e8 ad ab ff ff       	call   801005a9 <panic>

  ilock(ip);
801059fc:	83 ec 0c             	sub    $0xc,%esp
801059ff:	ff 75 f0             	push   -0x10(%ebp)
80105a02:	e8 cb bf ff ff       	call   801019d2 <ilock>
80105a07:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a0d:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105a11:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a18:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105a1c:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a23:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105a29:	83 ec 0c             	sub    $0xc,%esp
80105a2c:	ff 75 f0             	push   -0x10(%ebp)
80105a2f:	e8 c1 bd ff ff       	call   801017f5 <iupdate>
80105a34:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105a37:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a3c:	75 6a                	jne    80105aa8 <create+0x195>
    dp->nlink++;  // for ".."
80105a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a41:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a45:	83 c0 01             	add    $0x1,%eax
80105a48:	89 c2                	mov    %eax,%edx
80105a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a4d:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a51:	83 ec 0c             	sub    $0xc,%esp
80105a54:	ff 75 f4             	push   -0xc(%ebp)
80105a57:	e8 99 bd ff ff       	call   801017f5 <iupdate>
80105a5c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a62:	8b 40 04             	mov    0x4(%eax),%eax
80105a65:	83 ec 04             	sub    $0x4,%esp
80105a68:	50                   	push   %eax
80105a69:	68 e7 ad 10 80       	push   $0x8010ade7
80105a6e:	ff 75 f0             	push   -0x10(%ebp)
80105a71:	e8 f8 c7 ff ff       	call   8010226e <dirlink>
80105a76:	83 c4 10             	add    $0x10,%esp
80105a79:	85 c0                	test   %eax,%eax
80105a7b:	78 1e                	js     80105a9b <create+0x188>
80105a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a80:	8b 40 04             	mov    0x4(%eax),%eax
80105a83:	83 ec 04             	sub    $0x4,%esp
80105a86:	50                   	push   %eax
80105a87:	68 e9 ad 10 80       	push   $0x8010ade9
80105a8c:	ff 75 f0             	push   -0x10(%ebp)
80105a8f:	e8 da c7 ff ff       	call   8010226e <dirlink>
80105a94:	83 c4 10             	add    $0x10,%esp
80105a97:	85 c0                	test   %eax,%eax
80105a99:	79 0d                	jns    80105aa8 <create+0x195>
      panic("create dots");
80105a9b:	83 ec 0c             	sub    $0xc,%esp
80105a9e:	68 1c ae 10 80       	push   $0x8010ae1c
80105aa3:	e8 01 ab ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aab:	8b 40 04             	mov    0x4(%eax),%eax
80105aae:	83 ec 04             	sub    $0x4,%esp
80105ab1:	50                   	push   %eax
80105ab2:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ab5:	50                   	push   %eax
80105ab6:	ff 75 f4             	push   -0xc(%ebp)
80105ab9:	e8 b0 c7 ff ff       	call   8010226e <dirlink>
80105abe:	83 c4 10             	add    $0x10,%esp
80105ac1:	85 c0                	test   %eax,%eax
80105ac3:	79 0d                	jns    80105ad2 <create+0x1bf>
    panic("create: dirlink");
80105ac5:	83 ec 0c             	sub    $0xc,%esp
80105ac8:	68 28 ae 10 80       	push   $0x8010ae28
80105acd:	e8 d7 aa ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105ad2:	83 ec 0c             	sub    $0xc,%esp
80105ad5:	ff 75 f4             	push   -0xc(%ebp)
80105ad8:	e8 26 c1 ff ff       	call   80101c03 <iunlockput>
80105add:	83 c4 10             	add    $0x10,%esp

  return ip;
80105ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105ae3:	c9                   	leave  
80105ae4:	c3                   	ret    

80105ae5 <sys_open>:

int
sys_open(void)
{
80105ae5:	55                   	push   %ebp
80105ae6:	89 e5                	mov    %esp,%ebp
80105ae8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105aeb:	83 ec 08             	sub    $0x8,%esp
80105aee:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105af1:	50                   	push   %eax
80105af2:	6a 00                	push   $0x0
80105af4:	e8 ea f6 ff ff       	call   801051e3 <argstr>
80105af9:	83 c4 10             	add    $0x10,%esp
80105afc:	85 c0                	test   %eax,%eax
80105afe:	78 15                	js     80105b15 <sys_open+0x30>
80105b00:	83 ec 08             	sub    $0x8,%esp
80105b03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b06:	50                   	push   %eax
80105b07:	6a 01                	push   $0x1
80105b09:	e8 4f f6 ff ff       	call   8010515d <argint>
80105b0e:	83 c4 10             	add    $0x10,%esp
80105b11:	85 c0                	test   %eax,%eax
80105b13:	79 0a                	jns    80105b1f <sys_open+0x3a>
    return -1;
80105b15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1a:	e9 61 01 00 00       	jmp    80105c80 <sys_open+0x19b>

  begin_op();
80105b1f:	e8 00 d5 ff ff       	call   80103024 <begin_op>

  if(omode & O_CREATE){
80105b24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b27:	25 00 02 00 00       	and    $0x200,%eax
80105b2c:	85 c0                	test   %eax,%eax
80105b2e:	74 2a                	je     80105b5a <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105b30:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b33:	6a 00                	push   $0x0
80105b35:	6a 00                	push   $0x0
80105b37:	6a 02                	push   $0x2
80105b39:	50                   	push   %eax
80105b3a:	e8 d4 fd ff ff       	call   80105913 <create>
80105b3f:	83 c4 10             	add    $0x10,%esp
80105b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105b45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b49:	75 75                	jne    80105bc0 <sys_open+0xdb>
      end_op();
80105b4b:	e8 60 d5 ff ff       	call   801030b0 <end_op>
      return -1;
80105b50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b55:	e9 26 01 00 00       	jmp    80105c80 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105b5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b5d:	83 ec 0c             	sub    $0xc,%esp
80105b60:	50                   	push   %eax
80105b61:	e8 9f c9 ff ff       	call   80102505 <namei>
80105b66:	83 c4 10             	add    $0x10,%esp
80105b69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b70:	75 0f                	jne    80105b81 <sys_open+0x9c>
      end_op();
80105b72:	e8 39 d5 ff ff       	call   801030b0 <end_op>
      return -1;
80105b77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7c:	e9 ff 00 00 00       	jmp    80105c80 <sys_open+0x19b>
    }
    ilock(ip);
80105b81:	83 ec 0c             	sub    $0xc,%esp
80105b84:	ff 75 f4             	push   -0xc(%ebp)
80105b87:	e8 46 be ff ff       	call   801019d2 <ilock>
80105b8c:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b92:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b96:	66 83 f8 01          	cmp    $0x1,%ax
80105b9a:	75 24                	jne    80105bc0 <sys_open+0xdb>
80105b9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b9f:	85 c0                	test   %eax,%eax
80105ba1:	74 1d                	je     80105bc0 <sys_open+0xdb>
      iunlockput(ip);
80105ba3:	83 ec 0c             	sub    $0xc,%esp
80105ba6:	ff 75 f4             	push   -0xc(%ebp)
80105ba9:	e8 55 c0 ff ff       	call   80101c03 <iunlockput>
80105bae:	83 c4 10             	add    $0x10,%esp
      end_op();
80105bb1:	e8 fa d4 ff ff       	call   801030b0 <end_op>
      return -1;
80105bb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bbb:	e9 c0 00 00 00       	jmp    80105c80 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105bc0:	e8 00 b4 ff ff       	call   80100fc5 <filealloc>
80105bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bc8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bcc:	74 17                	je     80105be5 <sys_open+0x100>
80105bce:	83 ec 0c             	sub    $0xc,%esp
80105bd1:	ff 75 f0             	push   -0x10(%ebp)
80105bd4:	e8 33 f7 ff ff       	call   8010530c <fdalloc>
80105bd9:	83 c4 10             	add    $0x10,%esp
80105bdc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105bdf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105be3:	79 2e                	jns    80105c13 <sys_open+0x12e>
    if(f)
80105be5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105be9:	74 0e                	je     80105bf9 <sys_open+0x114>
      fileclose(f);
80105beb:	83 ec 0c             	sub    $0xc,%esp
80105bee:	ff 75 f0             	push   -0x10(%ebp)
80105bf1:	e8 8d b4 ff ff       	call   80101083 <fileclose>
80105bf6:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105bf9:	83 ec 0c             	sub    $0xc,%esp
80105bfc:	ff 75 f4             	push   -0xc(%ebp)
80105bff:	e8 ff bf ff ff       	call   80101c03 <iunlockput>
80105c04:	83 c4 10             	add    $0x10,%esp
    end_op();
80105c07:	e8 a4 d4 ff ff       	call   801030b0 <end_op>
    return -1;
80105c0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c11:	eb 6d                	jmp    80105c80 <sys_open+0x19b>
  }
  iunlock(ip);
80105c13:	83 ec 0c             	sub    $0xc,%esp
80105c16:	ff 75 f4             	push   -0xc(%ebp)
80105c19:	e8 c7 be ff ff       	call   80101ae5 <iunlock>
80105c1e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c21:	e8 8a d4 ff ff       	call   801030b0 <end_op>

  f->type = FD_INODE;
80105c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c29:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c32:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c35:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105c42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c45:	83 e0 01             	and    $0x1,%eax
80105c48:	85 c0                	test   %eax,%eax
80105c4a:	0f 94 c0             	sete   %al
80105c4d:	89 c2                	mov    %eax,%edx
80105c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c52:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105c55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c58:	83 e0 01             	and    $0x1,%eax
80105c5b:	85 c0                	test   %eax,%eax
80105c5d:	75 0a                	jne    80105c69 <sys_open+0x184>
80105c5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c62:	83 e0 02             	and    $0x2,%eax
80105c65:	85 c0                	test   %eax,%eax
80105c67:	74 07                	je     80105c70 <sys_open+0x18b>
80105c69:	b8 01 00 00 00       	mov    $0x1,%eax
80105c6e:	eb 05                	jmp    80105c75 <sys_open+0x190>
80105c70:	b8 00 00 00 00       	mov    $0x0,%eax
80105c75:	89 c2                	mov    %eax,%edx
80105c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7a:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105c7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105c80:	c9                   	leave  
80105c81:	c3                   	ret    

80105c82 <sys_mkdir>:

int
sys_mkdir(void)
{
80105c82:	55                   	push   %ebp
80105c83:	89 e5                	mov    %esp,%ebp
80105c85:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105c88:	e8 97 d3 ff ff       	call   80103024 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105c8d:	83 ec 08             	sub    $0x8,%esp
80105c90:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c93:	50                   	push   %eax
80105c94:	6a 00                	push   $0x0
80105c96:	e8 48 f5 ff ff       	call   801051e3 <argstr>
80105c9b:	83 c4 10             	add    $0x10,%esp
80105c9e:	85 c0                	test   %eax,%eax
80105ca0:	78 1b                	js     80105cbd <sys_mkdir+0x3b>
80105ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca5:	6a 00                	push   $0x0
80105ca7:	6a 00                	push   $0x0
80105ca9:	6a 01                	push   $0x1
80105cab:	50                   	push   %eax
80105cac:	e8 62 fc ff ff       	call   80105913 <create>
80105cb1:	83 c4 10             	add    $0x10,%esp
80105cb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cb7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cbb:	75 0c                	jne    80105cc9 <sys_mkdir+0x47>
    end_op();
80105cbd:	e8 ee d3 ff ff       	call   801030b0 <end_op>
    return -1;
80105cc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc7:	eb 18                	jmp    80105ce1 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105cc9:	83 ec 0c             	sub    $0xc,%esp
80105ccc:	ff 75 f4             	push   -0xc(%ebp)
80105ccf:	e8 2f bf ff ff       	call   80101c03 <iunlockput>
80105cd4:	83 c4 10             	add    $0x10,%esp
  end_op();
80105cd7:	e8 d4 d3 ff ff       	call   801030b0 <end_op>
  return 0;
80105cdc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ce1:	c9                   	leave  
80105ce2:	c3                   	ret    

80105ce3 <sys_mknod>:

int
sys_mknod(void)
{
80105ce3:	55                   	push   %ebp
80105ce4:	89 e5                	mov    %esp,%ebp
80105ce6:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105ce9:	e8 36 d3 ff ff       	call   80103024 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105cee:	83 ec 08             	sub    $0x8,%esp
80105cf1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cf4:	50                   	push   %eax
80105cf5:	6a 00                	push   $0x0
80105cf7:	e8 e7 f4 ff ff       	call   801051e3 <argstr>
80105cfc:	83 c4 10             	add    $0x10,%esp
80105cff:	85 c0                	test   %eax,%eax
80105d01:	78 4f                	js     80105d52 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105d03:	83 ec 08             	sub    $0x8,%esp
80105d06:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d09:	50                   	push   %eax
80105d0a:	6a 01                	push   $0x1
80105d0c:	e8 4c f4 ff ff       	call   8010515d <argint>
80105d11:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105d14:	85 c0                	test   %eax,%eax
80105d16:	78 3a                	js     80105d52 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105d18:	83 ec 08             	sub    $0x8,%esp
80105d1b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d1e:	50                   	push   %eax
80105d1f:	6a 02                	push   $0x2
80105d21:	e8 37 f4 ff ff       	call   8010515d <argint>
80105d26:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105d29:	85 c0                	test   %eax,%eax
80105d2b:	78 25                	js     80105d52 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d30:	0f bf c8             	movswl %ax,%ecx
80105d33:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d36:	0f bf d0             	movswl %ax,%edx
80105d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d3c:	51                   	push   %ecx
80105d3d:	52                   	push   %edx
80105d3e:	6a 03                	push   $0x3
80105d40:	50                   	push   %eax
80105d41:	e8 cd fb ff ff       	call   80105913 <create>
80105d46:	83 c4 10             	add    $0x10,%esp
80105d49:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105d4c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d50:	75 0c                	jne    80105d5e <sys_mknod+0x7b>
    end_op();
80105d52:	e8 59 d3 ff ff       	call   801030b0 <end_op>
    return -1;
80105d57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d5c:	eb 18                	jmp    80105d76 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105d5e:	83 ec 0c             	sub    $0xc,%esp
80105d61:	ff 75 f4             	push   -0xc(%ebp)
80105d64:	e8 9a be ff ff       	call   80101c03 <iunlockput>
80105d69:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d6c:	e8 3f d3 ff ff       	call   801030b0 <end_op>
  return 0;
80105d71:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d76:	c9                   	leave  
80105d77:	c3                   	ret    

80105d78 <sys_chdir>:

int
sys_chdir(void)
{
80105d78:	55                   	push   %ebp
80105d79:	89 e5                	mov    %esp,%ebp
80105d7b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105d7e:	e8 95 dc ff ff       	call   80103a18 <myproc>
80105d83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105d86:	e8 99 d2 ff ff       	call   80103024 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105d8b:	83 ec 08             	sub    $0x8,%esp
80105d8e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d91:	50                   	push   %eax
80105d92:	6a 00                	push   $0x0
80105d94:	e8 4a f4 ff ff       	call   801051e3 <argstr>
80105d99:	83 c4 10             	add    $0x10,%esp
80105d9c:	85 c0                	test   %eax,%eax
80105d9e:	78 18                	js     80105db8 <sys_chdir+0x40>
80105da0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105da3:	83 ec 0c             	sub    $0xc,%esp
80105da6:	50                   	push   %eax
80105da7:	e8 59 c7 ff ff       	call   80102505 <namei>
80105dac:	83 c4 10             	add    $0x10,%esp
80105daf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105db2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105db6:	75 0c                	jne    80105dc4 <sys_chdir+0x4c>
    end_op();
80105db8:	e8 f3 d2 ff ff       	call   801030b0 <end_op>
    return -1;
80105dbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc2:	eb 68                	jmp    80105e2c <sys_chdir+0xb4>
  }
  ilock(ip);
80105dc4:	83 ec 0c             	sub    $0xc,%esp
80105dc7:	ff 75 f0             	push   -0x10(%ebp)
80105dca:	e8 03 bc ff ff       	call   801019d2 <ilock>
80105dcf:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105dd9:	66 83 f8 01          	cmp    $0x1,%ax
80105ddd:	74 1a                	je     80105df9 <sys_chdir+0x81>
    iunlockput(ip);
80105ddf:	83 ec 0c             	sub    $0xc,%esp
80105de2:	ff 75 f0             	push   -0x10(%ebp)
80105de5:	e8 19 be ff ff       	call   80101c03 <iunlockput>
80105dea:	83 c4 10             	add    $0x10,%esp
    end_op();
80105ded:	e8 be d2 ff ff       	call   801030b0 <end_op>
    return -1;
80105df2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105df7:	eb 33                	jmp    80105e2c <sys_chdir+0xb4>
  }
  iunlock(ip);
80105df9:	83 ec 0c             	sub    $0xc,%esp
80105dfc:	ff 75 f0             	push   -0x10(%ebp)
80105dff:	e8 e1 bc ff ff       	call   80101ae5 <iunlock>
80105e04:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0a:	8b 40 68             	mov    0x68(%eax),%eax
80105e0d:	83 ec 0c             	sub    $0xc,%esp
80105e10:	50                   	push   %eax
80105e11:	e8 1d bd ff ff       	call   80101b33 <iput>
80105e16:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e19:	e8 92 d2 ff ff       	call   801030b0 <end_op>
  curproc->cwd = ip;
80105e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e21:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e24:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105e27:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e2c:	c9                   	leave  
80105e2d:	c3                   	ret    

80105e2e <sys_exec>:

int
sys_exec(void)
{
80105e2e:	55                   	push   %ebp
80105e2f:	89 e5                	mov    %esp,%ebp
80105e31:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105e37:	83 ec 08             	sub    $0x8,%esp
80105e3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e3d:	50                   	push   %eax
80105e3e:	6a 00                	push   $0x0
80105e40:	e8 9e f3 ff ff       	call   801051e3 <argstr>
80105e45:	83 c4 10             	add    $0x10,%esp
80105e48:	85 c0                	test   %eax,%eax
80105e4a:	78 18                	js     80105e64 <sys_exec+0x36>
80105e4c:	83 ec 08             	sub    $0x8,%esp
80105e4f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105e55:	50                   	push   %eax
80105e56:	6a 01                	push   $0x1
80105e58:	e8 00 f3 ff ff       	call   8010515d <argint>
80105e5d:	83 c4 10             	add    $0x10,%esp
80105e60:	85 c0                	test   %eax,%eax
80105e62:	79 0a                	jns    80105e6e <sys_exec+0x40>
    return -1;
80105e64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e69:	e9 c6 00 00 00       	jmp    80105f34 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105e6e:	83 ec 04             	sub    $0x4,%esp
80105e71:	68 80 00 00 00       	push   $0x80
80105e76:	6a 00                	push   $0x0
80105e78:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e7e:	50                   	push   %eax
80105e7f:	e8 ca ef ff ff       	call   80104e4e <memset>
80105e84:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105e87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e91:	83 f8 1f             	cmp    $0x1f,%eax
80105e94:	76 0a                	jbe    80105ea0 <sys_exec+0x72>
      return -1;
80105e96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e9b:	e9 94 00 00 00       	jmp    80105f34 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea3:	c1 e0 02             	shl    $0x2,%eax
80105ea6:	89 c2                	mov    %eax,%edx
80105ea8:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105eae:	01 c2                	add    %eax,%edx
80105eb0:	83 ec 08             	sub    $0x8,%esp
80105eb3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105eb9:	50                   	push   %eax
80105eba:	52                   	push   %edx
80105ebb:	e8 18 f2 ff ff       	call   801050d8 <fetchint>
80105ec0:	83 c4 10             	add    $0x10,%esp
80105ec3:	85 c0                	test   %eax,%eax
80105ec5:	79 07                	jns    80105ece <sys_exec+0xa0>
      return -1;
80105ec7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ecc:	eb 66                	jmp    80105f34 <sys_exec+0x106>
    if(uarg == 0){
80105ece:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105ed4:	85 c0                	test   %eax,%eax
80105ed6:	75 27                	jne    80105eff <sys_exec+0xd1>
      argv[i] = 0;
80105ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edb:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105ee2:	00 00 00 00 
      break;
80105ee6:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eea:	83 ec 08             	sub    $0x8,%esp
80105eed:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105ef3:	52                   	push   %edx
80105ef4:	50                   	push   %eax
80105ef5:	e8 86 ac ff ff       	call   80100b80 <exec>
80105efa:	83 c4 10             	add    $0x10,%esp
80105efd:	eb 35                	jmp    80105f34 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105eff:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f08:	c1 e0 02             	shl    $0x2,%eax
80105f0b:	01 c2                	add    %eax,%edx
80105f0d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f13:	83 ec 08             	sub    $0x8,%esp
80105f16:	52                   	push   %edx
80105f17:	50                   	push   %eax
80105f18:	e8 ea f1 ff ff       	call   80105107 <fetchstr>
80105f1d:	83 c4 10             	add    $0x10,%esp
80105f20:	85 c0                	test   %eax,%eax
80105f22:	79 07                	jns    80105f2b <sys_exec+0xfd>
      return -1;
80105f24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f29:	eb 09                	jmp    80105f34 <sys_exec+0x106>
  for(i=0;; i++){
80105f2b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105f2f:	e9 5a ff ff ff       	jmp    80105e8e <sys_exec+0x60>
}
80105f34:	c9                   	leave  
80105f35:	c3                   	ret    

80105f36 <sys_pipe>:

int
sys_pipe(void)
{
80105f36:	55                   	push   %ebp
80105f37:	89 e5                	mov    %esp,%ebp
80105f39:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105f3c:	83 ec 04             	sub    $0x4,%esp
80105f3f:	6a 08                	push   $0x8
80105f41:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f44:	50                   	push   %eax
80105f45:	6a 00                	push   $0x0
80105f47:	e8 3e f2 ff ff       	call   8010518a <argptr>
80105f4c:	83 c4 10             	add    $0x10,%esp
80105f4f:	85 c0                	test   %eax,%eax
80105f51:	79 0a                	jns    80105f5d <sys_pipe+0x27>
    return -1;
80105f53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f58:	e9 ae 00 00 00       	jmp    8010600b <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105f5d:	83 ec 08             	sub    $0x8,%esp
80105f60:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f63:	50                   	push   %eax
80105f64:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f67:	50                   	push   %eax
80105f68:	e8 e8 d5 ff ff       	call   80103555 <pipealloc>
80105f6d:	83 c4 10             	add    $0x10,%esp
80105f70:	85 c0                	test   %eax,%eax
80105f72:	79 0a                	jns    80105f7e <sys_pipe+0x48>
    return -1;
80105f74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f79:	e9 8d 00 00 00       	jmp    8010600b <sys_pipe+0xd5>
  fd0 = -1;
80105f7e:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105f85:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f88:	83 ec 0c             	sub    $0xc,%esp
80105f8b:	50                   	push   %eax
80105f8c:	e8 7b f3 ff ff       	call   8010530c <fdalloc>
80105f91:	83 c4 10             	add    $0x10,%esp
80105f94:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f97:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f9b:	78 18                	js     80105fb5 <sys_pipe+0x7f>
80105f9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fa0:	83 ec 0c             	sub    $0xc,%esp
80105fa3:	50                   	push   %eax
80105fa4:	e8 63 f3 ff ff       	call   8010530c <fdalloc>
80105fa9:	83 c4 10             	add    $0x10,%esp
80105fac:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105faf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fb3:	79 3e                	jns    80105ff3 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105fb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fb9:	78 13                	js     80105fce <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105fbb:	e8 58 da ff ff       	call   80103a18 <myproc>
80105fc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fc3:	83 c2 08             	add    $0x8,%edx
80105fc6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105fcd:	00 
    fileclose(rf);
80105fce:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fd1:	83 ec 0c             	sub    $0xc,%esp
80105fd4:	50                   	push   %eax
80105fd5:	e8 a9 b0 ff ff       	call   80101083 <fileclose>
80105fda:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105fdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fe0:	83 ec 0c             	sub    $0xc,%esp
80105fe3:	50                   	push   %eax
80105fe4:	e8 9a b0 ff ff       	call   80101083 <fileclose>
80105fe9:	83 c4 10             	add    $0x10,%esp
    return -1;
80105fec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff1:	eb 18                	jmp    8010600b <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105ff3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ff6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ff9:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105ffb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ffe:	8d 50 04             	lea    0x4(%eax),%edx
80106001:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106004:	89 02                	mov    %eax,(%edx)
  return 0;
80106006:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010600b:	c9                   	leave  
8010600c:	c3                   	ret    

8010600d <sys_fork>:
  struct proc proc[NPROC];
} ptable;

int
sys_fork(void)
{
8010600d:	55                   	push   %ebp
8010600e:	89 e5                	mov    %esp,%ebp
80106010:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106013:	e8 25 de ff ff       	call   80103e3d <fork>
}
80106018:	c9                   	leave  
80106019:	c3                   	ret    

8010601a <sys_exit>:

int
sys_exit(void)
{
8010601a:	55                   	push   %ebp
8010601b:	89 e5                	mov    %esp,%ebp
8010601d:	83 ec 08             	sub    $0x8,%esp
  exit();
80106020:	e8 91 df ff ff       	call   80103fb6 <exit>
  return 0;  // not reached
80106025:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010602a:	c9                   	leave  
8010602b:	c3                   	ret    

8010602c <sys_wait>:

int
sys_wait(void)
{
8010602c:	55                   	push   %ebp
8010602d:	89 e5                	mov    %esp,%ebp
8010602f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106032:	e8 e3 e0 ff ff       	call   8010411a <wait>
}
80106037:	c9                   	leave  
80106038:	c3                   	ret    

80106039 <sys_kill>:

int
sys_kill(void)
{
80106039:	55                   	push   %ebp
8010603a:	89 e5                	mov    %esp,%ebp
8010603c:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010603f:	83 ec 08             	sub    $0x8,%esp
80106042:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106045:	50                   	push   %eax
80106046:	6a 00                	push   $0x0
80106048:	e8 10 f1 ff ff       	call   8010515d <argint>
8010604d:	83 c4 10             	add    $0x10,%esp
80106050:	85 c0                	test   %eax,%eax
80106052:	79 07                	jns    8010605b <sys_kill+0x22>
    return -1;
80106054:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106059:	eb 0f                	jmp    8010606a <sys_kill+0x31>
  return kill(pid);
8010605b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010605e:	83 ec 0c             	sub    $0xc,%esp
80106061:	50                   	push   %eax
80106062:	e8 38 e8 ff ff       	call   8010489f <kill>
80106067:	83 c4 10             	add    $0x10,%esp
}
8010606a:	c9                   	leave  
8010606b:	c3                   	ret    

8010606c <sys_getpid>:

int
sys_getpid(void)
{
8010606c:	55                   	push   %ebp
8010606d:	89 e5                	mov    %esp,%ebp
8010606f:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106072:	e8 a1 d9 ff ff       	call   80103a18 <myproc>
80106077:	8b 40 10             	mov    0x10(%eax),%eax
}
8010607a:	c9                   	leave  
8010607b:	c3                   	ret    

8010607c <sys_sbrk>:
//   if(growproc(n) < 0)
//     return -1;
//   return addr;
// }

int sys_sbrk(void) {
8010607c:	55                   	push   %ebp
8010607d:	89 e5                	mov    %esp,%ebp
8010607f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;
  struct proc *curproc = myproc();
80106082:	e8 91 d9 ff ff       	call   80103a18 <myproc>
80106087:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if (argint(0, &n) < 0)
8010608a:	83 ec 08             	sub    $0x8,%esp
8010608d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106090:	50                   	push   %eax
80106091:	6a 00                	push   $0x0
80106093:	e8 c5 f0 ff ff       	call   8010515d <argint>
80106098:	83 c4 10             	add    $0x10,%esp
8010609b:	85 c0                	test   %eax,%eax
8010609d:	79 07                	jns    801060a6 <sys_sbrk+0x2a>
    return -1;
8010609f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a4:	eb 4d                	jmp    801060f3 <sys_sbrk+0x77>
  addr = curproc->sz;
801060a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a9:	8b 00                	mov    (%eax),%eax
801060ab:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(n < 0){
801060ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801060b1:	85 c0                	test   %eax,%eax
801060b3:	79 2c                	jns    801060e1 <sys_sbrk+0x65>
    if(deallocuvm(curproc->pgdir, addr, addr + n) == 0)
801060b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801060b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060bb:	01 d0                	add    %edx,%eax
801060bd:	89 c1                	mov    %eax,%ecx
801060bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c5:	8b 40 04             	mov    0x4(%eax),%eax
801060c8:	83 ec 04             	sub    $0x4,%esp
801060cb:	51                   	push   %ecx
801060cc:	52                   	push   %edx
801060cd:	50                   	push   %eax
801060ce:	e8 6d 20 00 00       	call   80108140 <deallocuvm>
801060d3:	83 c4 10             	add    $0x10,%esp
801060d6:	85 c0                	test   %eax,%eax
801060d8:	75 07                	jne    801060e1 <sys_sbrk+0x65>
      return -1;
801060da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060df:	eb 12                	jmp    801060f3 <sys_sbrk+0x77>
  }

  curproc->sz += n;
801060e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e4:	8b 10                	mov    (%eax),%edx
801060e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801060e9:	01 c2                	add    %eax,%edx
801060eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ee:	89 10                	mov    %edx,(%eax)

  return addr;
801060f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801060f3:	c9                   	leave  
801060f4:	c3                   	ret    

801060f5 <sys_sleep>:



int
sys_sleep(void)
{
801060f5:	55                   	push   %ebp
801060f6:	89 e5                	mov    %esp,%ebp
801060f8:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801060fb:	83 ec 08             	sub    $0x8,%esp
801060fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106101:	50                   	push   %eax
80106102:	6a 00                	push   $0x0
80106104:	e8 54 f0 ff ff       	call   8010515d <argint>
80106109:	83 c4 10             	add    $0x10,%esp
8010610c:	85 c0                	test   %eax,%eax
8010610e:	79 07                	jns    80106117 <sys_sleep+0x22>
    return -1;
80106110:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106115:	eb 76                	jmp    8010618d <sys_sleep+0x98>
  acquire(&tickslock);
80106117:	83 ec 0c             	sub    $0xc,%esp
8010611a:	68 40 e4 30 80       	push   $0x8030e440
8010611f:	e8 b4 ea ff ff       	call   80104bd8 <acquire>
80106124:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106127:	a1 74 e4 30 80       	mov    0x8030e474,%eax
8010612c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010612f:	eb 38                	jmp    80106169 <sys_sleep+0x74>
    if(myproc()->killed){
80106131:	e8 e2 d8 ff ff       	call   80103a18 <myproc>
80106136:	8b 40 24             	mov    0x24(%eax),%eax
80106139:	85 c0                	test   %eax,%eax
8010613b:	74 17                	je     80106154 <sys_sleep+0x5f>
      release(&tickslock);
8010613d:	83 ec 0c             	sub    $0xc,%esp
80106140:	68 40 e4 30 80       	push   $0x8030e440
80106145:	e8 fc ea ff ff       	call   80104c46 <release>
8010614a:	83 c4 10             	add    $0x10,%esp
      return -1;
8010614d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106152:	eb 39                	jmp    8010618d <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106154:	83 ec 08             	sub    $0x8,%esp
80106157:	68 40 e4 30 80       	push   $0x8030e440
8010615c:	68 74 e4 30 80       	push   $0x8030e474
80106161:	e8 18 e6 ff ff       	call   8010477e <sleep>
80106166:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106169:	a1 74 e4 30 80       	mov    0x8030e474,%eax
8010616e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106171:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106174:	39 d0                	cmp    %edx,%eax
80106176:	72 b9                	jb     80106131 <sys_sleep+0x3c>
  }
  release(&tickslock);
80106178:	83 ec 0c             	sub    $0xc,%esp
8010617b:	68 40 e4 30 80       	push   $0x8030e440
80106180:	e8 c1 ea ff ff       	call   80104c46 <release>
80106185:	83 c4 10             	add    $0x10,%esp
  return 0;
80106188:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010618d:	c9                   	leave  
8010618e:	c3                   	ret    

8010618f <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010618f:	55                   	push   %ebp
80106190:	89 e5                	mov    %esp,%ebp
80106192:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106195:	83 ec 0c             	sub    $0xc,%esp
80106198:	68 40 e4 30 80       	push   $0x8030e440
8010619d:	e8 36 ea ff ff       	call   80104bd8 <acquire>
801061a2:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801061a5:	a1 74 e4 30 80       	mov    0x8030e474,%eax
801061aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801061ad:	83 ec 0c             	sub    $0xc,%esp
801061b0:	68 40 e4 30 80       	push   $0x8030e440
801061b5:	e8 8c ea ff ff       	call   80104c46 <release>
801061ba:	83 c4 10             	add    $0x10,%esp
  return xticks;
801061bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801061c0:	c9                   	leave  
801061c1:	c3                   	ret    

801061c2 <sys_uthread_init>:

// 이거 추가
int
sys_uthread_init(void)
{
801061c2:	55                   	push   %ebp
801061c3:	89 e5                	mov    %esp,%ebp
801061c5:	53                   	push   %ebx
801061c6:	83 ec 14             	sub    $0x14,%esp
  int addr;
  if (argint(0, &addr) < 0)
801061c9:	83 ec 08             	sub    $0x8,%esp
801061cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061cf:	50                   	push   %eax
801061d0:	6a 00                	push   $0x0
801061d2:	e8 86 ef ff ff       	call   8010515d <argint>
801061d7:	83 c4 10             	add    $0x10,%esp
801061da:	85 c0                	test   %eax,%eax
801061dc:	79 07                	jns    801061e5 <sys_uthread_init+0x23>
    return -1;
801061de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e3:	eb 12                	jmp    801061f7 <sys_uthread_init+0x35>
  myproc()->scheduler = addr;
801061e5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801061e8:	e8 2b d8 ff ff       	call   80103a18 <myproc>
801061ed:	89 da                	mov    %ebx,%edx
801061ef:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
801061f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801061fa:	c9                   	leave  
801061fb:	c3                   	ret    

801061fc <sys_check_thread>:



int
sys_check_thread(void) {
801061fc:	55                   	push   %ebp
801061fd:	89 e5                	mov    %esp,%ebp
801061ff:	83 ec 18             	sub    $0x18,%esp
  int op;
  if (argint(0, &op) < 0)  // 사용자로부터 인자 하나 받음
80106202:	83 ec 08             	sub    $0x8,%esp
80106205:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106208:	50                   	push   %eax
80106209:	6a 00                	push   $0x0
8010620b:	e8 4d ef ff ff       	call   8010515d <argint>
80106210:	83 c4 10             	add    $0x10,%esp
80106213:	85 c0                	test   %eax,%eax
80106215:	79 07                	jns    8010621e <sys_check_thread+0x22>
    return -1;
80106217:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621c:	eb 24                	jmp    80106242 <sys_check_thread+0x46>

  struct proc* p = myproc();
8010621e:	e8 f5 d7 ff ff       	call   80103a18 <myproc>
80106223:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p->check_thread += op;  // +1 또는 -1
80106226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106229:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
8010622f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106232:	01 c2                	add    %eax,%edx
80106234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106237:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  return 0;
8010623d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106242:	c9                   	leave  
80106243:	c3                   	ret    

80106244 <sys_getpinfo>:


int
sys_getpinfo(void) {
80106244:	55                   	push   %ebp
80106245:	89 e5                	mov    %esp,%ebp
80106247:	53                   	push   %ebx
80106248:	83 ec 14             	sub    $0x14,%esp
  struct pstat *ps;
  if (argptr(0, (void *)&ps, sizeof(*ps)) < 0)
8010624b:	83 ec 04             	sub    $0x4,%esp
8010624e:	68 00 0c 00 00       	push   $0xc00
80106253:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106256:	50                   	push   %eax
80106257:	6a 00                	push   $0x0
80106259:	e8 2c ef ff ff       	call   8010518a <argptr>
8010625e:	83 c4 10             	add    $0x10,%esp
80106261:	85 c0                	test   %eax,%eax
80106263:	79 0a                	jns    8010626f <sys_getpinfo+0x2b>
    return -1;
80106265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010626a:	e9 21 01 00 00       	jmp    80106390 <sys_getpinfo+0x14c>

  acquire(&ptable.lock);
8010626f:	83 ec 0c             	sub    $0xc,%esp
80106272:	68 00 bb 30 80       	push   $0x8030bb00
80106277:	e8 5c e9 ff ff       	call   80104bd8 <acquire>
8010627c:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
8010627f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106286:	e9 e6 00 00 00       	jmp    80106371 <sys_getpinfo+0x12d>
    struct proc *p = &ptable.proc[i];
8010628b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010628e:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
80106294:	83 c0 30             	add    $0x30,%eax
80106297:	05 00 bb 30 80       	add    $0x8030bb00,%eax
8010629c:	83 c0 04             	add    $0x4,%eax
8010629f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    ps->inuse[i] = (p->state != UNUSED);
801062a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062a5:	8b 40 0c             	mov    0xc(%eax),%eax
801062a8:	85 c0                	test   %eax,%eax
801062aa:	0f 95 c2             	setne  %dl
801062ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062b0:	0f b6 ca             	movzbl %dl,%ecx
801062b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062b6:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    ps->pid[i] = p->pid;
801062b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062bc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801062bf:	8b 52 10             	mov    0x10(%edx),%edx
801062c2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801062c5:	83 c1 40             	add    $0x40,%ecx
801062c8:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->priority[i] = proc_priority[i];
801062cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062d1:	8b 14 95 00 b2 30 80 	mov    -0x7fcf4e00(,%edx,4),%edx
801062d8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801062db:	83 e9 80             	sub    $0xffffff80,%ecx
801062de:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->state[i] = p->state;
801062e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062e4:	8b 50 0c             	mov    0xc(%eax),%edx
801062e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062ea:	89 d1                	mov    %edx,%ecx
801062ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062ef:	81 c2 c0 00 00 00    	add    $0xc0,%edx
801062f5:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    for (int j = 0; j < 4; j++) {
801062f8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801062ff:	eb 66                	jmp    80106367 <sys_getpinfo+0x123>
      ps->ticks[i][j] = proc_ticks[i][j];
80106301:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106304:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106307:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
8010630e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106311:	01 ca                	add    %ecx,%edx
80106313:	8b 14 95 00 b3 30 80 	mov    -0x7fcf4d00(,%edx,4),%edx
8010631a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010631d:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80106324:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106327:	01 d9                	add    %ebx,%ecx
80106329:	81 c1 00 01 00 00    	add    $0x100,%ecx
8010632f:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = proc_wait_ticks[i][j];
80106332:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106335:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106338:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
8010633f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106342:	01 ca                	add    %ecx,%edx
80106344:	8b 14 95 00 b7 30 80 	mov    -0x7fcf4900(,%edx,4),%edx
8010634b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010634e:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80106355:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106358:	01 d9                	add    %ebx,%ecx
8010635a:	81 c1 00 02 00 00    	add    $0x200,%ecx
80106360:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80106363:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80106367:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
8010636b:	7e 94                	jle    80106301 <sys_getpinfo+0xbd>
  for (int i = 0; i < NPROC; i++) {
8010636d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106371:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80106375:	0f 8e 10 ff ff ff    	jle    8010628b <sys_getpinfo+0x47>
    }
  }
  release(&ptable.lock);
8010637b:	83 ec 0c             	sub    $0xc,%esp
8010637e:	68 00 bb 30 80       	push   $0x8030bb00
80106383:	e8 be e8 ff ff       	call   80104c46 <release>
80106388:	83 c4 10             	add    $0x10,%esp
  return 0;
8010638b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106390:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106393:	c9                   	leave  
80106394:	c3                   	ret    

80106395 <sys_setSchedPolicy>:


int
sys_setSchedPolicy(void) {
80106395:	55                   	push   %ebp
80106396:	89 e5                	mov    %esp,%ebp
80106398:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
8010639b:	83 ec 08             	sub    $0x8,%esp
8010639e:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063a1:	50                   	push   %eax
801063a2:	6a 00                	push   $0x0
801063a4:	e8 b4 ed ff ff       	call   8010515d <argint>
801063a9:	83 c4 10             	add    $0x10,%esp
801063ac:	85 c0                	test   %eax,%eax
801063ae:	79 07                	jns    801063b7 <sys_setSchedPolicy+0x22>
    return -1;
801063b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b5:	eb 31                	jmp    801063e8 <sys_setSchedPolicy+0x53>
  
  pushcli();
801063b7:	e8 87 e9 ff ff       	call   80104d43 <pushcli>
  mycpu()->sched_policy = policy;
801063bc:	e8 df d5 ff ff       	call   801039a0 <mycpu>
801063c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063c4:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
801063ca:	e8 c1 e9 ff ff       	call   80104d90 <popcli>

  cprintf("✅ sched_policy set to %d\n", policy);
801063cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d2:	83 ec 08             	sub    $0x8,%esp
801063d5:	50                   	push   %eax
801063d6:	68 38 ae 10 80       	push   $0x8010ae38
801063db:	e8 14 a0 ff ff       	call   801003f4 <cprintf>
801063e0:	83 c4 10             	add    $0x10,%esp
  return 0;
801063e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063e8:	c9                   	leave  
801063e9:	c3                   	ret    

801063ea <sys_yield>:

int
sys_yield(void)
{
801063ea:	55                   	push   %ebp
801063eb:	89 e5                	mov    %esp,%ebp
801063ed:	83 ec 08             	sub    $0x8,%esp
  yield();
801063f0:	e8 c8 e2 ff ff       	call   801046bd <yield>
  return 0;
801063f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063fa:	c9                   	leave  
801063fb:	c3                   	ret    

801063fc <print_user_page_table>:

void print_user_page_table(struct proc *p) {
801063fc:	55                   	push   %ebp
801063fd:	89 e5                	mov    %esp,%ebp
801063ff:	83 ec 28             	sub    $0x28,%esp
  cprintf("START PAGE TABLE (pid %d)\n", p->pid);
80106402:	8b 45 08             	mov    0x8(%ebp),%eax
80106405:	8b 40 10             	mov    0x10(%eax),%eax
80106408:	83 ec 08             	sub    $0x8,%esp
8010640b:	50                   	push   %eax
8010640c:	68 54 ae 10 80       	push   $0x8010ae54
80106411:	e8 de 9f ff ff       	call   801003f4 <cprintf>
80106416:	83 c4 10             	add    $0x10,%esp
  pde_t *pgdir = p->pgdir;
80106419:	8b 45 08             	mov    0x8(%ebp),%eax
8010641c:	8b 40 04             	mov    0x4(%eax),%eax
8010641f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(uint va = 0; va < KERNBASE; va += PGSIZE) {
80106422:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106429:	e9 a7 00 00 00       	jmp    801064d5 <print_user_page_table+0xd9>
    pte_t *pte = walkpgdir(pgdir, (void*)va, 0);
8010642e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106431:	83 ec 04             	sub    $0x4,%esp
80106434:	6a 00                	push   $0x0
80106436:	50                   	push   %eax
80106437:	ff 75 f0             	push   -0x10(%ebp)
8010643a:	e8 dd 16 00 00       	call   80107b1c <walkpgdir>
8010643f:	83 c4 10             	add    $0x10,%esp
80106442:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(!pte) continue;
80106445:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106449:	74 7f                	je     801064ca <print_user_page_table+0xce>
    if(!(*pte & PTE_P)) continue;
8010644b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010644e:	8b 00                	mov    (%eax),%eax
80106450:	83 e0 01             	and    $0x1,%eax
80106453:	85 c0                	test   %eax,%eax
80106455:	74 76                	je     801064cd <print_user_page_table+0xd1>
    uint vpn = va / PGSIZE;
80106457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010645a:	c1 e8 0c             	shr    $0xc,%eax
8010645d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    char *uork = (*pte & PTE_U) ? "U" : "K";
80106460:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106463:	8b 00                	mov    (%eax),%eax
80106465:	83 e0 04             	and    $0x4,%eax
80106468:	85 c0                	test   %eax,%eax
8010646a:	74 07                	je     80106473 <print_user_page_table+0x77>
8010646c:	b8 6f ae 10 80       	mov    $0x8010ae6f,%eax
80106471:	eb 05                	jmp    80106478 <print_user_page_table+0x7c>
80106473:	b8 71 ae 10 80       	mov    $0x8010ae71,%eax
80106478:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    char *w = (*pte & PTE_W) ? "W" : "-";
8010647b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010647e:	8b 00                	mov    (%eax),%eax
80106480:	83 e0 02             	and    $0x2,%eax
80106483:	85 c0                	test   %eax,%eax
80106485:	74 07                	je     8010648e <print_user_page_table+0x92>
80106487:	b8 73 ae 10 80       	mov    $0x8010ae73,%eax
8010648c:	eb 05                	jmp    80106493 <print_user_page_table+0x97>
8010648e:	b8 75 ae 10 80       	mov    $0x8010ae75,%eax
80106493:	89 45 e0             	mov    %eax,-0x20(%ebp)
    uint pa = PTE_ADDR(*pte);
80106496:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106499:	8b 00                	mov    (%eax),%eax
8010649b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801064a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
    uint ppn = pa >> 12;
801064a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801064a6:	c1 e8 0c             	shr    $0xc,%eax
801064a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    cprintf("%x P %s %s %x\n", vpn, uork, w, ppn);
801064ac:	83 ec 0c             	sub    $0xc,%esp
801064af:	ff 75 d8             	push   -0x28(%ebp)
801064b2:	ff 75 e0             	push   -0x20(%ebp)
801064b5:	ff 75 e4             	push   -0x1c(%ebp)
801064b8:	ff 75 e8             	push   -0x18(%ebp)
801064bb:	68 77 ae 10 80       	push   $0x8010ae77
801064c0:	e8 2f 9f ff ff       	call   801003f4 <cprintf>
801064c5:	83 c4 20             	add    $0x20,%esp
801064c8:	eb 04                	jmp    801064ce <print_user_page_table+0xd2>
    if(!pte) continue;
801064ca:	90                   	nop
801064cb:	eb 01                	jmp    801064ce <print_user_page_table+0xd2>
    if(!(*pte & PTE_P)) continue;
801064cd:	90                   	nop
  for(uint va = 0; va < KERNBASE; va += PGSIZE) {
801064ce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801064d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d8:	85 c0                	test   %eax,%eax
801064da:	0f 89 4e ff ff ff    	jns    8010642e <print_user_page_table+0x32>
  }
  cprintf("END PAGE TABLE\n");
801064e0:	83 ec 0c             	sub    $0xc,%esp
801064e3:	68 86 ae 10 80       	push   $0x8010ae86
801064e8:	e8 07 9f ff ff       	call   801003f4 <cprintf>
801064ed:	83 c4 10             	add    $0x10,%esp
}
801064f0:	90                   	nop
801064f1:	c9                   	leave  
801064f2:	c3                   	ret    

801064f3 <sys_printpt>:

int 
sys_printpt(void) {
801064f3:	55                   	push   %ebp
801064f4:	89 e5                	mov    %esp,%ebp
801064f6:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if(argint(0, &pid) < 0)
801064f9:	83 ec 08             	sub    $0x8,%esp
801064fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064ff:	50                   	push   %eax
80106500:	6a 00                	push   $0x0
80106502:	e8 56 ec ff ff       	call   8010515d <argint>
80106507:	83 c4 10             	add    $0x10,%esp
8010650a:	85 c0                	test   %eax,%eax
8010650c:	79 07                	jns    80106515 <sys_printpt+0x22>
    return -1;
8010650e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106513:	eb 32                	jmp    80106547 <sys_printpt+0x54>
  struct proc *p = find_proc_by_pid(pid);
80106515:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106518:	83 ec 0c             	sub    $0xc,%esp
8010651b:	50                   	push   %eax
8010651c:	e8 02 e5 ff ff       	call   80104a23 <find_proc_by_pid>
80106521:	83 c4 10             	add    $0x10,%esp
80106524:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!p)
80106527:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010652b:	75 07                	jne    80106534 <sys_printpt+0x41>
    return -1;
8010652d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106532:	eb 13                	jmp    80106547 <sys_printpt+0x54>
  print_user_page_table(p);
80106534:	83 ec 0c             	sub    $0xc,%esp
80106537:	ff 75 f4             	push   -0xc(%ebp)
8010653a:	e8 bd fe ff ff       	call   801063fc <print_user_page_table>
8010653f:	83 c4 10             	add    $0x10,%esp
  return 0;
80106542:	b8 00 00 00 00       	mov    $0x0,%eax
80106547:	c9                   	leave  
80106548:	c3                   	ret    

80106549 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106549:	1e                   	push   %ds
  pushl %es
8010654a:	06                   	push   %es
  pushl %fs
8010654b:	0f a0                	push   %fs
  pushl %gs
8010654d:	0f a8                	push   %gs
  pushal
8010654f:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106550:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106554:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106556:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106558:	54                   	push   %esp
  call trap
80106559:	e8 e3 01 00 00       	call   80106741 <trap>
  addl $4, %esp
8010655e:	83 c4 04             	add    $0x4,%esp

80106561 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106561:	61                   	popa   
  popl %gs
80106562:	0f a9                	pop    %gs
  popl %fs
80106564:	0f a1                	pop    %fs
  popl %es
80106566:	07                   	pop    %es
  popl %ds
80106567:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106568:	83 c4 08             	add    $0x8,%esp
  iret
8010656b:	cf                   	iret   

8010656c <lidt>:
{
8010656c:	55                   	push   %ebp
8010656d:	89 e5                	mov    %esp,%ebp
8010656f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106572:	8b 45 0c             	mov    0xc(%ebp),%eax
80106575:	83 e8 01             	sub    $0x1,%eax
80106578:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010657c:	8b 45 08             	mov    0x8(%ebp),%eax
8010657f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106583:	8b 45 08             	mov    0x8(%ebp),%eax
80106586:	c1 e8 10             	shr    $0x10,%eax
80106589:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010658d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106590:	0f 01 18             	lidtl  (%eax)
}
80106593:	90                   	nop
80106594:	c9                   	leave  
80106595:	c3                   	ret    

80106596 <rcr2>:

static inline uint
rcr2(void)
{
80106596:	55                   	push   %ebp
80106597:	89 e5                	mov    %esp,%ebp
80106599:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010659c:	0f 20 d0             	mov    %cr2,%eax
8010659f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801065a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801065a5:	c9                   	leave  
801065a6:	c3                   	ret    

801065a7 <lcr3>:

static inline void
lcr3(uint val)
{
801065a7:	55                   	push   %ebp
801065a8:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801065aa:	8b 45 08             	mov    0x8(%ebp),%eax
801065ad:	0f 22 d8             	mov    %eax,%cr3
}
801065b0:	90                   	nop
801065b1:	5d                   	pop    %ebp
801065b2:	c3                   	ret    

801065b3 <tvinit>:

pte_t *walkpgdir(pde_t *pgdir, const void *va, int alloc);
int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm);

void tvinit(void)
{
801065b3:	55                   	push   %ebp
801065b4:	89 e5                	mov    %esp,%ebp
801065b6:	83 ec 18             	sub    $0x18,%esp
  int i;

  for (i = 0; i < 256; i++)
801065b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801065c0:	e9 c3 00 00 00       	jmp    80106688 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
801065c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c8:	8b 04 85 90 f0 10 80 	mov    -0x7fef0f70(,%eax,4),%eax
801065cf:	89 c2                	mov    %eax,%edx
801065d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d4:	66 89 14 c5 40 dc 30 	mov    %dx,-0x7fcf23c0(,%eax,8)
801065db:	80 
801065dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065df:	66 c7 04 c5 42 dc 30 	movw   $0x8,-0x7fcf23be(,%eax,8)
801065e6:	80 08 00 
801065e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ec:	0f b6 14 c5 44 dc 30 	movzbl -0x7fcf23bc(,%eax,8),%edx
801065f3:	80 
801065f4:	83 e2 e0             	and    $0xffffffe0,%edx
801065f7:	88 14 c5 44 dc 30 80 	mov    %dl,-0x7fcf23bc(,%eax,8)
801065fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106601:	0f b6 14 c5 44 dc 30 	movzbl -0x7fcf23bc(,%eax,8),%edx
80106608:	80 
80106609:	83 e2 1f             	and    $0x1f,%edx
8010660c:	88 14 c5 44 dc 30 80 	mov    %dl,-0x7fcf23bc(,%eax,8)
80106613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106616:	0f b6 14 c5 45 dc 30 	movzbl -0x7fcf23bb(,%eax,8),%edx
8010661d:	80 
8010661e:	83 e2 f0             	and    $0xfffffff0,%edx
80106621:	83 ca 0e             	or     $0xe,%edx
80106624:	88 14 c5 45 dc 30 80 	mov    %dl,-0x7fcf23bb(,%eax,8)
8010662b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010662e:	0f b6 14 c5 45 dc 30 	movzbl -0x7fcf23bb(,%eax,8),%edx
80106635:	80 
80106636:	83 e2 ef             	and    $0xffffffef,%edx
80106639:	88 14 c5 45 dc 30 80 	mov    %dl,-0x7fcf23bb(,%eax,8)
80106640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106643:	0f b6 14 c5 45 dc 30 	movzbl -0x7fcf23bb(,%eax,8),%edx
8010664a:	80 
8010664b:	83 e2 9f             	and    $0xffffff9f,%edx
8010664e:	88 14 c5 45 dc 30 80 	mov    %dl,-0x7fcf23bb(,%eax,8)
80106655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106658:	0f b6 14 c5 45 dc 30 	movzbl -0x7fcf23bb(,%eax,8),%edx
8010665f:	80 
80106660:	83 ca 80             	or     $0xffffff80,%edx
80106663:	88 14 c5 45 dc 30 80 	mov    %dl,-0x7fcf23bb(,%eax,8)
8010666a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010666d:	8b 04 85 90 f0 10 80 	mov    -0x7fef0f70(,%eax,4),%eax
80106674:	c1 e8 10             	shr    $0x10,%eax
80106677:	89 c2                	mov    %eax,%edx
80106679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010667c:	66 89 14 c5 46 dc 30 	mov    %dx,-0x7fcf23ba(,%eax,8)
80106683:	80 
  for (i = 0; i < 256; i++)
80106684:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106688:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010668f:	0f 8e 30 ff ff ff    	jle    801065c5 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);
80106695:	a1 90 f1 10 80       	mov    0x8010f190,%eax
8010669a:	66 a3 40 de 30 80    	mov    %ax,0x8030de40
801066a0:	66 c7 05 42 de 30 80 	movw   $0x8,0x8030de42
801066a7:	08 00 
801066a9:	0f b6 05 44 de 30 80 	movzbl 0x8030de44,%eax
801066b0:	83 e0 e0             	and    $0xffffffe0,%eax
801066b3:	a2 44 de 30 80       	mov    %al,0x8030de44
801066b8:	0f b6 05 44 de 30 80 	movzbl 0x8030de44,%eax
801066bf:	83 e0 1f             	and    $0x1f,%eax
801066c2:	a2 44 de 30 80       	mov    %al,0x8030de44
801066c7:	0f b6 05 45 de 30 80 	movzbl 0x8030de45,%eax
801066ce:	83 c8 0f             	or     $0xf,%eax
801066d1:	a2 45 de 30 80       	mov    %al,0x8030de45
801066d6:	0f b6 05 45 de 30 80 	movzbl 0x8030de45,%eax
801066dd:	83 e0 ef             	and    $0xffffffef,%eax
801066e0:	a2 45 de 30 80       	mov    %al,0x8030de45
801066e5:	0f b6 05 45 de 30 80 	movzbl 0x8030de45,%eax
801066ec:	83 c8 60             	or     $0x60,%eax
801066ef:	a2 45 de 30 80       	mov    %al,0x8030de45
801066f4:	0f b6 05 45 de 30 80 	movzbl 0x8030de45,%eax
801066fb:	83 c8 80             	or     $0xffffff80,%eax
801066fe:	a2 45 de 30 80       	mov    %al,0x8030de45
80106703:	a1 90 f1 10 80       	mov    0x8010f190,%eax
80106708:	c1 e8 10             	shr    $0x10,%eax
8010670b:	66 a3 46 de 30 80    	mov    %ax,0x8030de46

  initlock(&tickslock, "time");
80106711:	83 ec 08             	sub    $0x8,%esp
80106714:	68 98 ae 10 80       	push   $0x8010ae98
80106719:	68 40 e4 30 80       	push   $0x8030e440
8010671e:	e8 93 e4 ff ff       	call   80104bb6 <initlock>
80106723:	83 c4 10             	add    $0x10,%esp
}
80106726:	90                   	nop
80106727:	c9                   	leave  
80106728:	c3                   	ret    

80106729 <idtinit>:

void idtinit(void)
{
80106729:	55                   	push   %ebp
8010672a:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010672c:	68 00 08 00 00       	push   $0x800
80106731:	68 40 dc 30 80       	push   $0x8030dc40
80106736:	e8 31 fe ff ff       	call   8010656c <lidt>
8010673b:	83 c4 08             	add    $0x8,%esp
}
8010673e:	90                   	nop
8010673f:	c9                   	leave  
80106740:	c3                   	ret    

80106741 <trap>:

// PAGEBREAK: 41
void trap(struct trapframe *tf)
{
80106741:	55                   	push   %ebp
80106742:	89 e5                	mov    %esp,%ebp
80106744:	57                   	push   %edi
80106745:	56                   	push   %esi
80106746:	53                   	push   %ebx
80106747:	83 ec 2c             	sub    $0x2c,%esp
  struct proc *p = myproc();
8010674a:	e8 c9 d2 ff ff       	call   80103a18 <myproc>
8010674f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (tf->trapno == T_SYSCALL)
80106752:	8b 45 08             	mov    0x8(%ebp),%eax
80106755:	8b 40 30             	mov    0x30(%eax),%eax
80106758:	83 f8 40             	cmp    $0x40,%eax
8010675b:	75 3b                	jne    80106798 <trap+0x57>
  {
    if (myproc()->killed)
8010675d:	e8 b6 d2 ff ff       	call   80103a18 <myproc>
80106762:	8b 40 24             	mov    0x24(%eax),%eax
80106765:	85 c0                	test   %eax,%eax
80106767:	74 05                	je     8010676e <trap+0x2d>
      exit();
80106769:	e8 48 d8 ff ff       	call   80103fb6 <exit>
    myproc()->tf = tf;
8010676e:	e8 a5 d2 ff ff       	call   80103a18 <myproc>
80106773:	8b 55 08             	mov    0x8(%ebp),%edx
80106776:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106779:	e8 9c ea ff ff       	call   8010521a <syscall>
    if (myproc()->killed)
8010677e:	e8 95 d2 ff ff       	call   80103a18 <myproc>
80106783:	8b 40 24             	mov    0x24(%eax),%eax
80106786:	85 c0                	test   %eax,%eax
80106788:	0f 84 8a 03 00 00    	je     80106b18 <trap+0x3d7>
      exit();
8010678e:	e8 23 d8 ff ff       	call   80103fb6 <exit>
    return;
80106793:	e9 80 03 00 00       	jmp    80106b18 <trap+0x3d7>
  }

  switch (tf->trapno)
80106798:	8b 45 08             	mov    0x8(%ebp),%eax
8010679b:	8b 40 30             	mov    0x30(%eax),%eax
8010679e:	83 e8 0e             	sub    $0xe,%eax
801067a1:	83 f8 31             	cmp    $0x31,%eax
801067a4:	0f 87 33 02 00 00    	ja     801069dd <trap+0x29c>
801067aa:	8b 04 85 58 af 10 80 	mov    -0x7fef50a8(,%eax,4),%eax
801067b1:	ff e0                	jmp    *%eax
  {
  case T_IRQ0 + IRQ_TIMER:
    if (cpuid() == 0)
801067b3:	e8 cd d1 ff ff       	call   80103985 <cpuid>
801067b8:	85 c0                	test   %eax,%eax
801067ba:	75 3d                	jne    801067f9 <trap+0xb8>
    {
      acquire(&tickslock);
801067bc:	83 ec 0c             	sub    $0xc,%esp
801067bf:	68 40 e4 30 80       	push   $0x8030e440
801067c4:	e8 0f e4 ff ff       	call   80104bd8 <acquire>
801067c9:	83 c4 10             	add    $0x10,%esp
      ticks++;
801067cc:	a1 74 e4 30 80       	mov    0x8030e474,%eax
801067d1:	83 c0 01             	add    $0x1,%eax
801067d4:	a3 74 e4 30 80       	mov    %eax,0x8030e474
      wakeup(&ticks);
801067d9:	83 ec 0c             	sub    $0xc,%esp
801067dc:	68 74 e4 30 80       	push   $0x8030e474
801067e1:	e8 82 e0 ff ff       	call   80104868 <wakeup>
801067e6:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801067e9:	83 ec 0c             	sub    $0xc,%esp
801067ec:	68 40 e4 30 80       	push   $0x8030e440
801067f1:	e8 50 e4 ff ff       	call   80104c46 <release>
801067f6:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801067f9:	e8 06 c3 ff ff       	call   80102b04 <lapiceoi>

    // 유저모드 + scheduler 설정된 경우만 실행
    if (p && p->state == RUNNING && p->scheduler)
801067fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106802:	0f 84 8c 02 00 00    	je     80106a94 <trap+0x353>
80106808:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010680b:	8b 40 0c             	mov    0xc(%eax),%eax
8010680e:	83 f8 04             	cmp    $0x4,%eax
80106811:	0f 85 7d 02 00 00    	jne    80106a94 <trap+0x353>
80106817:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010681a:	8b 40 7c             	mov    0x7c(%eax),%eax
8010681d:	85 c0                	test   %eax,%eax
8010681f:	0f 84 6f 02 00 00    	je     80106a94 <trap+0x353>
    {
      if (p->check_thread >= 2)
80106825:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106828:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010682e:	83 f8 01             	cmp    $0x1,%eax
80106831:	0f 8e 5d 02 00 00    	jle    80106a94 <trap+0x353>
      {
        p->tf->eip = p->scheduler;
80106837:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010683a:	8b 40 18             	mov    0x18(%eax),%eax
8010683d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106840:	8b 52 7c             	mov    0x7c(%edx),%edx
80106843:	89 50 38             	mov    %edx,0x38(%eax)
      }
    }

    break;
80106846:	e9 49 02 00 00       	jmp    80106a94 <trap+0x353>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010684b:	e8 ee 3f 00 00       	call   8010a83e <ideintr>
    lapiceoi();
80106850:	e8 af c2 ff ff       	call   80102b04 <lapiceoi>
    break;
80106855:	e9 3e 02 00 00       	jmp    80106a98 <trap+0x357>
  case T_IRQ0 + IRQ_IDE + 1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010685a:	e8 ea c0 ff ff       	call   80102949 <kbdintr>
    lapiceoi();
8010685f:	e8 a0 c2 ff ff       	call   80102b04 <lapiceoi>
    break;
80106864:	e9 2f 02 00 00       	jmp    80106a98 <trap+0x357>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106869:	e8 80 04 00 00       	call   80106cee <uartintr>
    lapiceoi();
8010686e:	e8 91 c2 ff ff       	call   80102b04 <lapiceoi>
    break;
80106873:	e9 20 02 00 00       	jmp    80106a98 <trap+0x357>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106878:	e8 74 2c 00 00       	call   801094f1 <i8254_intr>
    lapiceoi();
8010687d:	e8 82 c2 ff ff       	call   80102b04 <lapiceoi>
    break;
80106882:	e9 11 02 00 00       	jmp    80106a98 <trap+0x357>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106887:	8b 45 08             	mov    0x8(%ebp),%eax
8010688a:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010688d:	8b 45 08             	mov    0x8(%ebp),%eax
80106890:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106894:	0f b7 d8             	movzwl %ax,%ebx
80106897:	e8 e9 d0 ff ff       	call   80103985 <cpuid>
8010689c:	56                   	push   %esi
8010689d:	53                   	push   %ebx
8010689e:	50                   	push   %eax
8010689f:	68 a0 ae 10 80       	push   $0x8010aea0
801068a4:	e8 4b 9b ff ff       	call   801003f4 <cprintf>
801068a9:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801068ac:	e8 53 c2 ff ff       	call   80102b04 <lapiceoi>
    break;
801068b1:	e9 e2 01 00 00       	jmp    80106a98 <trap+0x357>

  case T_PGFLT:
    uint va = PGROUNDDOWN(rcr2());
801068b6:	e8 db fc ff ff       	call   80106596 <rcr2>
801068bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801068c0:	89 45 e0             	mov    %eax,-0x20(%ebp)

    if (!p)
801068c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801068c7:	0f 84 ca 01 00 00    	je     80106a97 <trap+0x356>
      break;

    if (va >= KERNBASE || (p->sz == 0))
801068cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801068d0:	85 c0                	test   %eax,%eax
801068d2:	78 09                	js     801068dd <trap+0x19c>
801068d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068d7:	8b 00                	mov    (%eax),%eax
801068d9:	85 c0                	test   %eax,%eax
801068db:	75 0f                	jne    801068ec <trap+0x1ab>
    {
      // 커널 영역, 혹은 전체 해제된 경우: 접근 금지
      p->killed = 1;
801068dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068e0:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
801068e7:	e9 ac 01 00 00       	jmp    80106a98 <trap+0x357>
    // if (!pte || (*pte & PTE_P)) {
    //     p->killed = 1;
    //     break;
    // }

    pte_t *pte = walkpgdir(p->pgdir, (char *)va, 0);
801068ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
801068ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068f2:	8b 40 04             	mov    0x4(%eax),%eax
801068f5:	83 ec 04             	sub    $0x4,%esp
801068f8:	6a 00                	push   $0x0
801068fa:	52                   	push   %edx
801068fb:	50                   	push   %eax
801068fc:	e8 1b 12 00 00       	call   80107b1c <walkpgdir>
80106901:	83 c4 10             	add    $0x10,%esp
80106904:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (!pte)
80106907:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010690b:	75 0f                	jne    8010691c <trap+0x1db>
    {
      p->killed = 1;
8010690d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106910:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
80106917:	e9 7c 01 00 00       	jmp    80106a98 <trap+0x357>
    }
    if (*pte & PTE_P)
8010691c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010691f:	8b 00                	mov    (%eax),%eax
80106921:	83 e0 01             	and    $0x1,%eax
80106924:	85 c0                	test   %eax,%eax
80106926:	74 0f                	je     80106937 <trap+0x1f6>
    {
      p->killed = 1;
80106928:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010692b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
80106932:	e9 61 01 00 00       	jmp    80106a98 <trap+0x357>
    }

    char *mem = kalloc();
80106937:	e8 4c be ff ff       	call   80102788 <kalloc>
8010693c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (mem == 0)
8010693f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80106943:	75 1f                	jne    80106964 <trap+0x223>
    {
      cprintf("allocuvm out of memory\n");
80106945:	83 ec 0c             	sub    $0xc,%esp
80106948:	68 c4 ae 10 80       	push   $0x8010aec4
8010694d:	e8 a2 9a ff ff       	call   801003f4 <cprintf>
80106952:	83 c4 10             	add    $0x10,%esp
      p->killed = 1;
80106955:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106958:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
8010695f:	e9 34 01 00 00       	jmp    80106a98 <trap+0x357>
    }
    memset(mem, 0, PGSIZE);
80106964:	83 ec 04             	sub    $0x4,%esp
80106967:	68 00 10 00 00       	push   $0x1000
8010696c:	6a 00                	push   $0x0
8010696e:	ff 75 d8             	push   -0x28(%ebp)
80106971:	e8 d8 e4 ff ff       	call   80104e4e <memset>
80106976:	83 c4 10             	add    $0x10,%esp
    if (mappages(p->pgdir, (char *)va, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0)
80106979:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010697c:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80106982:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106985:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106988:	8b 40 04             	mov    0x4(%eax),%eax
8010698b:	83 ec 0c             	sub    $0xc,%esp
8010698e:	6a 06                	push   $0x6
80106990:	51                   	push   %ecx
80106991:	68 00 10 00 00       	push   $0x1000
80106996:	52                   	push   %edx
80106997:	50                   	push   %eax
80106998:	e8 15 12 00 00       	call   80107bb2 <mappages>
8010699d:	83 c4 20             	add    $0x20,%esp
801069a0:	85 c0                	test   %eax,%eax
801069a2:	79 1d                	jns    801069c1 <trap+0x280>
    {
      kfree(mem);
801069a4:	83 ec 0c             	sub    $0xc,%esp
801069a7:	ff 75 d8             	push   -0x28(%ebp)
801069aa:	e8 3f bd ff ff       	call   801026ee <kfree>
801069af:	83 c4 10             	add    $0x10,%esp
      p->killed = 1;
801069b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069b5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
801069bc:	e9 d7 00 00 00       	jmp    80106a98 <trap+0x357>
    }

    lcr3(V2P(p->pgdir)); // TLB flush
801069c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069c4:	8b 40 04             	mov    0x4(%eax),%eax
801069c7:	05 00 00 00 80       	add    $0x80000000,%eax
801069cc:	83 ec 0c             	sub    $0xc,%esp
801069cf:	50                   	push   %eax
801069d0:	e8 d2 fb ff ff       	call   801065a7 <lcr3>
801069d5:	83 c4 10             	add    $0x10,%esp
    break;
801069d8:	e9 bb 00 00 00       	jmp    80106a98 <trap+0x357>

  // PAGEBREAK: 13
  default:
    if (myproc() == 0 || (tf->cs & 3) == 0)
801069dd:	e8 36 d0 ff ff       	call   80103a18 <myproc>
801069e2:	85 c0                	test   %eax,%eax
801069e4:	74 11                	je     801069f7 <trap+0x2b6>
801069e6:	8b 45 08             	mov    0x8(%ebp),%eax
801069e9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801069ed:	0f b7 c0             	movzwl %ax,%eax
801069f0:	83 e0 03             	and    $0x3,%eax
801069f3:	85 c0                	test   %eax,%eax
801069f5:	75 39                	jne    80106a30 <trap+0x2ef>
    {
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069f7:	e8 9a fb ff ff       	call   80106596 <rcr2>
801069fc:	89 c3                	mov    %eax,%ebx
801069fe:	8b 45 08             	mov    0x8(%ebp),%eax
80106a01:	8b 70 38             	mov    0x38(%eax),%esi
80106a04:	e8 7c cf ff ff       	call   80103985 <cpuid>
80106a09:	8b 55 08             	mov    0x8(%ebp),%edx
80106a0c:	8b 52 30             	mov    0x30(%edx),%edx
80106a0f:	83 ec 0c             	sub    $0xc,%esp
80106a12:	53                   	push   %ebx
80106a13:	56                   	push   %esi
80106a14:	50                   	push   %eax
80106a15:	52                   	push   %edx
80106a16:	68 dc ae 10 80       	push   $0x8010aedc
80106a1b:	e8 d4 99 ff ff       	call   801003f4 <cprintf>
80106a20:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106a23:	83 ec 0c             	sub    $0xc,%esp
80106a26:	68 0e af 10 80       	push   $0x8010af0e
80106a2b:	e8 79 9b ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a30:	e8 61 fb ff ff       	call   80106596 <rcr2>
80106a35:	89 c6                	mov    %eax,%esi
80106a37:	8b 45 08             	mov    0x8(%ebp),%eax
80106a3a:	8b 40 38             	mov    0x38(%eax),%eax
80106a3d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106a40:	e8 40 cf ff ff       	call   80103985 <cpuid>
80106a45:	89 c3                	mov    %eax,%ebx
80106a47:	8b 45 08             	mov    0x8(%ebp),%eax
80106a4a:	8b 48 34             	mov    0x34(%eax),%ecx
80106a4d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106a50:	8b 45 08             	mov    0x8(%ebp),%eax
80106a53:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106a56:	e8 bd cf ff ff       	call   80103a18 <myproc>
80106a5b:	8d 50 6c             	lea    0x6c(%eax),%edx
80106a5e:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106a61:	e8 b2 cf ff ff       	call   80103a18 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a66:	8b 40 10             	mov    0x10(%eax),%eax
80106a69:	56                   	push   %esi
80106a6a:	ff 75 d4             	push   -0x2c(%ebp)
80106a6d:	53                   	push   %ebx
80106a6e:	ff 75 d0             	push   -0x30(%ebp)
80106a71:	57                   	push   %edi
80106a72:	ff 75 cc             	push   -0x34(%ebp)
80106a75:	50                   	push   %eax
80106a76:	68 14 af 10 80       	push   $0x8010af14
80106a7b:	e8 74 99 ff ff       	call   801003f4 <cprintf>
80106a80:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106a83:	e8 90 cf ff ff       	call   80103a18 <myproc>
80106a88:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a8f:	eb 07                	jmp    80106a98 <trap+0x357>
    break;
80106a91:	90                   	nop
80106a92:	eb 04                	jmp    80106a98 <trap+0x357>
    break;
80106a94:	90                   	nop
80106a95:	eb 01                	jmp    80106a98 <trap+0x357>
      break;
80106a97:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106a98:	e8 7b cf ff ff       	call   80103a18 <myproc>
80106a9d:	85 c0                	test   %eax,%eax
80106a9f:	74 23                	je     80106ac4 <trap+0x383>
80106aa1:	e8 72 cf ff ff       	call   80103a18 <myproc>
80106aa6:	8b 40 24             	mov    0x24(%eax),%eax
80106aa9:	85 c0                	test   %eax,%eax
80106aab:	74 17                	je     80106ac4 <trap+0x383>
80106aad:	8b 45 08             	mov    0x8(%ebp),%eax
80106ab0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ab4:	0f b7 c0             	movzwl %ax,%eax
80106ab7:	83 e0 03             	and    $0x3,%eax
80106aba:	83 f8 03             	cmp    $0x3,%eax
80106abd:	75 05                	jne    80106ac4 <trap+0x383>
    exit();
80106abf:	e8 f2 d4 ff ff       	call   80103fb6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if (myproc() && myproc()->state == RUNNING &&
80106ac4:	e8 4f cf ff ff       	call   80103a18 <myproc>
80106ac9:	85 c0                	test   %eax,%eax
80106acb:	74 1d                	je     80106aea <trap+0x3a9>
80106acd:	e8 46 cf ff ff       	call   80103a18 <myproc>
80106ad2:	8b 40 0c             	mov    0xc(%eax),%eax
80106ad5:	83 f8 04             	cmp    $0x4,%eax
80106ad8:	75 10                	jne    80106aea <trap+0x3a9>
      tf->trapno == T_IRQ0 + IRQ_TIMER)
80106ada:	8b 45 08             	mov    0x8(%ebp),%eax
80106add:	8b 40 30             	mov    0x30(%eax),%eax
  if (myproc() && myproc()->state == RUNNING &&
80106ae0:	83 f8 20             	cmp    $0x20,%eax
80106ae3:	75 05                	jne    80106aea <trap+0x3a9>
    yield();
80106ae5:	e8 d3 db ff ff       	call   801046bd <yield>

  // Check if the process has been killed since we yielded
  if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106aea:	e8 29 cf ff ff       	call   80103a18 <myproc>
80106aef:	85 c0                	test   %eax,%eax
80106af1:	74 26                	je     80106b19 <trap+0x3d8>
80106af3:	e8 20 cf ff ff       	call   80103a18 <myproc>
80106af8:	8b 40 24             	mov    0x24(%eax),%eax
80106afb:	85 c0                	test   %eax,%eax
80106afd:	74 1a                	je     80106b19 <trap+0x3d8>
80106aff:	8b 45 08             	mov    0x8(%ebp),%eax
80106b02:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b06:	0f b7 c0             	movzwl %ax,%eax
80106b09:	83 e0 03             	and    $0x3,%eax
80106b0c:	83 f8 03             	cmp    $0x3,%eax
80106b0f:	75 08                	jne    80106b19 <trap+0x3d8>
    exit();
80106b11:	e8 a0 d4 ff ff       	call   80103fb6 <exit>
80106b16:	eb 01                	jmp    80106b19 <trap+0x3d8>
    return;
80106b18:	90                   	nop
}
80106b19:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b1c:	5b                   	pop    %ebx
80106b1d:	5e                   	pop    %esi
80106b1e:	5f                   	pop    %edi
80106b1f:	5d                   	pop    %ebp
80106b20:	c3                   	ret    

80106b21 <inb>:
{
80106b21:	55                   	push   %ebp
80106b22:	89 e5                	mov    %esp,%ebp
80106b24:	83 ec 14             	sub    $0x14,%esp
80106b27:	8b 45 08             	mov    0x8(%ebp),%eax
80106b2a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b2e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106b32:	89 c2                	mov    %eax,%edx
80106b34:	ec                   	in     (%dx),%al
80106b35:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106b38:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106b3c:	c9                   	leave  
80106b3d:	c3                   	ret    

80106b3e <outb>:
{
80106b3e:	55                   	push   %ebp
80106b3f:	89 e5                	mov    %esp,%ebp
80106b41:	83 ec 08             	sub    $0x8,%esp
80106b44:	8b 45 08             	mov    0x8(%ebp),%eax
80106b47:	8b 55 0c             	mov    0xc(%ebp),%edx
80106b4a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106b4e:	89 d0                	mov    %edx,%eax
80106b50:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b53:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b57:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106b5b:	ee                   	out    %al,(%dx)
}
80106b5c:	90                   	nop
80106b5d:	c9                   	leave  
80106b5e:	c3                   	ret    

80106b5f <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106b5f:	55                   	push   %ebp
80106b60:	89 e5                	mov    %esp,%ebp
80106b62:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106b65:	6a 00                	push   $0x0
80106b67:	68 fa 03 00 00       	push   $0x3fa
80106b6c:	e8 cd ff ff ff       	call   80106b3e <outb>
80106b71:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106b74:	68 80 00 00 00       	push   $0x80
80106b79:	68 fb 03 00 00       	push   $0x3fb
80106b7e:	e8 bb ff ff ff       	call   80106b3e <outb>
80106b83:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106b86:	6a 0c                	push   $0xc
80106b88:	68 f8 03 00 00       	push   $0x3f8
80106b8d:	e8 ac ff ff ff       	call   80106b3e <outb>
80106b92:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106b95:	6a 00                	push   $0x0
80106b97:	68 f9 03 00 00       	push   $0x3f9
80106b9c:	e8 9d ff ff ff       	call   80106b3e <outb>
80106ba1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106ba4:	6a 03                	push   $0x3
80106ba6:	68 fb 03 00 00       	push   $0x3fb
80106bab:	e8 8e ff ff ff       	call   80106b3e <outb>
80106bb0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106bb3:	6a 00                	push   $0x0
80106bb5:	68 fc 03 00 00       	push   $0x3fc
80106bba:	e8 7f ff ff ff       	call   80106b3e <outb>
80106bbf:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106bc2:	6a 01                	push   $0x1
80106bc4:	68 f9 03 00 00       	push   $0x3f9
80106bc9:	e8 70 ff ff ff       	call   80106b3e <outb>
80106bce:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106bd1:	68 fd 03 00 00       	push   $0x3fd
80106bd6:	e8 46 ff ff ff       	call   80106b21 <inb>
80106bdb:	83 c4 04             	add    $0x4,%esp
80106bde:	3c ff                	cmp    $0xff,%al
80106be0:	74 61                	je     80106c43 <uartinit+0xe4>
    return;
  uart = 1;
80106be2:	c7 05 78 e4 30 80 01 	movl   $0x1,0x8030e478
80106be9:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106bec:	68 fa 03 00 00       	push   $0x3fa
80106bf1:	e8 2b ff ff ff       	call   80106b21 <inb>
80106bf6:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106bf9:	68 f8 03 00 00       	push   $0x3f8
80106bfe:	e8 1e ff ff ff       	call   80106b21 <inb>
80106c03:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106c06:	83 ec 08             	sub    $0x8,%esp
80106c09:	6a 00                	push   $0x0
80106c0b:	6a 04                	push   $0x4
80106c0d:	e8 04 ba ff ff       	call   80102616 <ioapicenable>
80106c12:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c15:	c7 45 f4 20 b0 10 80 	movl   $0x8010b020,-0xc(%ebp)
80106c1c:	eb 19                	jmp    80106c37 <uartinit+0xd8>
    uartputc(*p);
80106c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c21:	0f b6 00             	movzbl (%eax),%eax
80106c24:	0f be c0             	movsbl %al,%eax
80106c27:	83 ec 0c             	sub    $0xc,%esp
80106c2a:	50                   	push   %eax
80106c2b:	e8 16 00 00 00       	call   80106c46 <uartputc>
80106c30:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106c33:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c3a:	0f b6 00             	movzbl (%eax),%eax
80106c3d:	84 c0                	test   %al,%al
80106c3f:	75 dd                	jne    80106c1e <uartinit+0xbf>
80106c41:	eb 01                	jmp    80106c44 <uartinit+0xe5>
    return;
80106c43:	90                   	nop
}
80106c44:	c9                   	leave  
80106c45:	c3                   	ret    

80106c46 <uartputc>:

void
uartputc(int c)
{
80106c46:	55                   	push   %ebp
80106c47:	89 e5                	mov    %esp,%ebp
80106c49:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106c4c:	a1 78 e4 30 80       	mov    0x8030e478,%eax
80106c51:	85 c0                	test   %eax,%eax
80106c53:	74 53                	je     80106ca8 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c5c:	eb 11                	jmp    80106c6f <uartputc+0x29>
    microdelay(10);
80106c5e:	83 ec 0c             	sub    $0xc,%esp
80106c61:	6a 0a                	push   $0xa
80106c63:	e8 b7 be ff ff       	call   80102b1f <microdelay>
80106c68:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c6b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c6f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106c73:	7f 1a                	jg     80106c8f <uartputc+0x49>
80106c75:	83 ec 0c             	sub    $0xc,%esp
80106c78:	68 fd 03 00 00       	push   $0x3fd
80106c7d:	e8 9f fe ff ff       	call   80106b21 <inb>
80106c82:	83 c4 10             	add    $0x10,%esp
80106c85:	0f b6 c0             	movzbl %al,%eax
80106c88:	83 e0 20             	and    $0x20,%eax
80106c8b:	85 c0                	test   %eax,%eax
80106c8d:	74 cf                	je     80106c5e <uartputc+0x18>
  outb(COM1+0, c);
80106c8f:	8b 45 08             	mov    0x8(%ebp),%eax
80106c92:	0f b6 c0             	movzbl %al,%eax
80106c95:	83 ec 08             	sub    $0x8,%esp
80106c98:	50                   	push   %eax
80106c99:	68 f8 03 00 00       	push   $0x3f8
80106c9e:	e8 9b fe ff ff       	call   80106b3e <outb>
80106ca3:	83 c4 10             	add    $0x10,%esp
80106ca6:	eb 01                	jmp    80106ca9 <uartputc+0x63>
    return;
80106ca8:	90                   	nop
}
80106ca9:	c9                   	leave  
80106caa:	c3                   	ret    

80106cab <uartgetc>:

static int
uartgetc(void)
{
80106cab:	55                   	push   %ebp
80106cac:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106cae:	a1 78 e4 30 80       	mov    0x8030e478,%eax
80106cb3:	85 c0                	test   %eax,%eax
80106cb5:	75 07                	jne    80106cbe <uartgetc+0x13>
    return -1;
80106cb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cbc:	eb 2e                	jmp    80106cec <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106cbe:	68 fd 03 00 00       	push   $0x3fd
80106cc3:	e8 59 fe ff ff       	call   80106b21 <inb>
80106cc8:	83 c4 04             	add    $0x4,%esp
80106ccb:	0f b6 c0             	movzbl %al,%eax
80106cce:	83 e0 01             	and    $0x1,%eax
80106cd1:	85 c0                	test   %eax,%eax
80106cd3:	75 07                	jne    80106cdc <uartgetc+0x31>
    return -1;
80106cd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cda:	eb 10                	jmp    80106cec <uartgetc+0x41>
  return inb(COM1+0);
80106cdc:	68 f8 03 00 00       	push   $0x3f8
80106ce1:	e8 3b fe ff ff       	call   80106b21 <inb>
80106ce6:	83 c4 04             	add    $0x4,%esp
80106ce9:	0f b6 c0             	movzbl %al,%eax
}
80106cec:	c9                   	leave  
80106ced:	c3                   	ret    

80106cee <uartintr>:

void
uartintr(void)
{
80106cee:	55                   	push   %ebp
80106cef:	89 e5                	mov    %esp,%ebp
80106cf1:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106cf4:	83 ec 0c             	sub    $0xc,%esp
80106cf7:	68 ab 6c 10 80       	push   $0x80106cab
80106cfc:	e8 d5 9a ff ff       	call   801007d6 <consoleintr>
80106d01:	83 c4 10             	add    $0x10,%esp
}
80106d04:	90                   	nop
80106d05:	c9                   	leave  
80106d06:	c3                   	ret    

80106d07 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106d07:	6a 00                	push   $0x0
  pushl $0
80106d09:	6a 00                	push   $0x0
  jmp alltraps
80106d0b:	e9 39 f8 ff ff       	jmp    80106549 <alltraps>

80106d10 <vector1>:
.globl vector1
vector1:
  pushl $0
80106d10:	6a 00                	push   $0x0
  pushl $1
80106d12:	6a 01                	push   $0x1
  jmp alltraps
80106d14:	e9 30 f8 ff ff       	jmp    80106549 <alltraps>

80106d19 <vector2>:
.globl vector2
vector2:
  pushl $0
80106d19:	6a 00                	push   $0x0
  pushl $2
80106d1b:	6a 02                	push   $0x2
  jmp alltraps
80106d1d:	e9 27 f8 ff ff       	jmp    80106549 <alltraps>

80106d22 <vector3>:
.globl vector3
vector3:
  pushl $0
80106d22:	6a 00                	push   $0x0
  pushl $3
80106d24:	6a 03                	push   $0x3
  jmp alltraps
80106d26:	e9 1e f8 ff ff       	jmp    80106549 <alltraps>

80106d2b <vector4>:
.globl vector4
vector4:
  pushl $0
80106d2b:	6a 00                	push   $0x0
  pushl $4
80106d2d:	6a 04                	push   $0x4
  jmp alltraps
80106d2f:	e9 15 f8 ff ff       	jmp    80106549 <alltraps>

80106d34 <vector5>:
.globl vector5
vector5:
  pushl $0
80106d34:	6a 00                	push   $0x0
  pushl $5
80106d36:	6a 05                	push   $0x5
  jmp alltraps
80106d38:	e9 0c f8 ff ff       	jmp    80106549 <alltraps>

80106d3d <vector6>:
.globl vector6
vector6:
  pushl $0
80106d3d:	6a 00                	push   $0x0
  pushl $6
80106d3f:	6a 06                	push   $0x6
  jmp alltraps
80106d41:	e9 03 f8 ff ff       	jmp    80106549 <alltraps>

80106d46 <vector7>:
.globl vector7
vector7:
  pushl $0
80106d46:	6a 00                	push   $0x0
  pushl $7
80106d48:	6a 07                	push   $0x7
  jmp alltraps
80106d4a:	e9 fa f7 ff ff       	jmp    80106549 <alltraps>

80106d4f <vector8>:
.globl vector8
vector8:
  pushl $8
80106d4f:	6a 08                	push   $0x8
  jmp alltraps
80106d51:	e9 f3 f7 ff ff       	jmp    80106549 <alltraps>

80106d56 <vector9>:
.globl vector9
vector9:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $9
80106d58:	6a 09                	push   $0x9
  jmp alltraps
80106d5a:	e9 ea f7 ff ff       	jmp    80106549 <alltraps>

80106d5f <vector10>:
.globl vector10
vector10:
  pushl $10
80106d5f:	6a 0a                	push   $0xa
  jmp alltraps
80106d61:	e9 e3 f7 ff ff       	jmp    80106549 <alltraps>

80106d66 <vector11>:
.globl vector11
vector11:
  pushl $11
80106d66:	6a 0b                	push   $0xb
  jmp alltraps
80106d68:	e9 dc f7 ff ff       	jmp    80106549 <alltraps>

80106d6d <vector12>:
.globl vector12
vector12:
  pushl $12
80106d6d:	6a 0c                	push   $0xc
  jmp alltraps
80106d6f:	e9 d5 f7 ff ff       	jmp    80106549 <alltraps>

80106d74 <vector13>:
.globl vector13
vector13:
  pushl $13
80106d74:	6a 0d                	push   $0xd
  jmp alltraps
80106d76:	e9 ce f7 ff ff       	jmp    80106549 <alltraps>

80106d7b <vector14>:
.globl vector14
vector14:
  pushl $14
80106d7b:	6a 0e                	push   $0xe
  jmp alltraps
80106d7d:	e9 c7 f7 ff ff       	jmp    80106549 <alltraps>

80106d82 <vector15>:
.globl vector15
vector15:
  pushl $0
80106d82:	6a 00                	push   $0x0
  pushl $15
80106d84:	6a 0f                	push   $0xf
  jmp alltraps
80106d86:	e9 be f7 ff ff       	jmp    80106549 <alltraps>

80106d8b <vector16>:
.globl vector16
vector16:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $16
80106d8d:	6a 10                	push   $0x10
  jmp alltraps
80106d8f:	e9 b5 f7 ff ff       	jmp    80106549 <alltraps>

80106d94 <vector17>:
.globl vector17
vector17:
  pushl $17
80106d94:	6a 11                	push   $0x11
  jmp alltraps
80106d96:	e9 ae f7 ff ff       	jmp    80106549 <alltraps>

80106d9b <vector18>:
.globl vector18
vector18:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $18
80106d9d:	6a 12                	push   $0x12
  jmp alltraps
80106d9f:	e9 a5 f7 ff ff       	jmp    80106549 <alltraps>

80106da4 <vector19>:
.globl vector19
vector19:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $19
80106da6:	6a 13                	push   $0x13
  jmp alltraps
80106da8:	e9 9c f7 ff ff       	jmp    80106549 <alltraps>

80106dad <vector20>:
.globl vector20
vector20:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $20
80106daf:	6a 14                	push   $0x14
  jmp alltraps
80106db1:	e9 93 f7 ff ff       	jmp    80106549 <alltraps>

80106db6 <vector21>:
.globl vector21
vector21:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $21
80106db8:	6a 15                	push   $0x15
  jmp alltraps
80106dba:	e9 8a f7 ff ff       	jmp    80106549 <alltraps>

80106dbf <vector22>:
.globl vector22
vector22:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $22
80106dc1:	6a 16                	push   $0x16
  jmp alltraps
80106dc3:	e9 81 f7 ff ff       	jmp    80106549 <alltraps>

80106dc8 <vector23>:
.globl vector23
vector23:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $23
80106dca:	6a 17                	push   $0x17
  jmp alltraps
80106dcc:	e9 78 f7 ff ff       	jmp    80106549 <alltraps>

80106dd1 <vector24>:
.globl vector24
vector24:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $24
80106dd3:	6a 18                	push   $0x18
  jmp alltraps
80106dd5:	e9 6f f7 ff ff       	jmp    80106549 <alltraps>

80106dda <vector25>:
.globl vector25
vector25:
  pushl $0
80106dda:	6a 00                	push   $0x0
  pushl $25
80106ddc:	6a 19                	push   $0x19
  jmp alltraps
80106dde:	e9 66 f7 ff ff       	jmp    80106549 <alltraps>

80106de3 <vector26>:
.globl vector26
vector26:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $26
80106de5:	6a 1a                	push   $0x1a
  jmp alltraps
80106de7:	e9 5d f7 ff ff       	jmp    80106549 <alltraps>

80106dec <vector27>:
.globl vector27
vector27:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $27
80106dee:	6a 1b                	push   $0x1b
  jmp alltraps
80106df0:	e9 54 f7 ff ff       	jmp    80106549 <alltraps>

80106df5 <vector28>:
.globl vector28
vector28:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $28
80106df7:	6a 1c                	push   $0x1c
  jmp alltraps
80106df9:	e9 4b f7 ff ff       	jmp    80106549 <alltraps>

80106dfe <vector29>:
.globl vector29
vector29:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $29
80106e00:	6a 1d                	push   $0x1d
  jmp alltraps
80106e02:	e9 42 f7 ff ff       	jmp    80106549 <alltraps>

80106e07 <vector30>:
.globl vector30
vector30:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $30
80106e09:	6a 1e                	push   $0x1e
  jmp alltraps
80106e0b:	e9 39 f7 ff ff       	jmp    80106549 <alltraps>

80106e10 <vector31>:
.globl vector31
vector31:
  pushl $0
80106e10:	6a 00                	push   $0x0
  pushl $31
80106e12:	6a 1f                	push   $0x1f
  jmp alltraps
80106e14:	e9 30 f7 ff ff       	jmp    80106549 <alltraps>

80106e19 <vector32>:
.globl vector32
vector32:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $32
80106e1b:	6a 20                	push   $0x20
  jmp alltraps
80106e1d:	e9 27 f7 ff ff       	jmp    80106549 <alltraps>

80106e22 <vector33>:
.globl vector33
vector33:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $33
80106e24:	6a 21                	push   $0x21
  jmp alltraps
80106e26:	e9 1e f7 ff ff       	jmp    80106549 <alltraps>

80106e2b <vector34>:
.globl vector34
vector34:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $34
80106e2d:	6a 22                	push   $0x22
  jmp alltraps
80106e2f:	e9 15 f7 ff ff       	jmp    80106549 <alltraps>

80106e34 <vector35>:
.globl vector35
vector35:
  pushl $0
80106e34:	6a 00                	push   $0x0
  pushl $35
80106e36:	6a 23                	push   $0x23
  jmp alltraps
80106e38:	e9 0c f7 ff ff       	jmp    80106549 <alltraps>

80106e3d <vector36>:
.globl vector36
vector36:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $36
80106e3f:	6a 24                	push   $0x24
  jmp alltraps
80106e41:	e9 03 f7 ff ff       	jmp    80106549 <alltraps>

80106e46 <vector37>:
.globl vector37
vector37:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $37
80106e48:	6a 25                	push   $0x25
  jmp alltraps
80106e4a:	e9 fa f6 ff ff       	jmp    80106549 <alltraps>

80106e4f <vector38>:
.globl vector38
vector38:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $38
80106e51:	6a 26                	push   $0x26
  jmp alltraps
80106e53:	e9 f1 f6 ff ff       	jmp    80106549 <alltraps>

80106e58 <vector39>:
.globl vector39
vector39:
  pushl $0
80106e58:	6a 00                	push   $0x0
  pushl $39
80106e5a:	6a 27                	push   $0x27
  jmp alltraps
80106e5c:	e9 e8 f6 ff ff       	jmp    80106549 <alltraps>

80106e61 <vector40>:
.globl vector40
vector40:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $40
80106e63:	6a 28                	push   $0x28
  jmp alltraps
80106e65:	e9 df f6 ff ff       	jmp    80106549 <alltraps>

80106e6a <vector41>:
.globl vector41
vector41:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $41
80106e6c:	6a 29                	push   $0x29
  jmp alltraps
80106e6e:	e9 d6 f6 ff ff       	jmp    80106549 <alltraps>

80106e73 <vector42>:
.globl vector42
vector42:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $42
80106e75:	6a 2a                	push   $0x2a
  jmp alltraps
80106e77:	e9 cd f6 ff ff       	jmp    80106549 <alltraps>

80106e7c <vector43>:
.globl vector43
vector43:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $43
80106e7e:	6a 2b                	push   $0x2b
  jmp alltraps
80106e80:	e9 c4 f6 ff ff       	jmp    80106549 <alltraps>

80106e85 <vector44>:
.globl vector44
vector44:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $44
80106e87:	6a 2c                	push   $0x2c
  jmp alltraps
80106e89:	e9 bb f6 ff ff       	jmp    80106549 <alltraps>

80106e8e <vector45>:
.globl vector45
vector45:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $45
80106e90:	6a 2d                	push   $0x2d
  jmp alltraps
80106e92:	e9 b2 f6 ff ff       	jmp    80106549 <alltraps>

80106e97 <vector46>:
.globl vector46
vector46:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $46
80106e99:	6a 2e                	push   $0x2e
  jmp alltraps
80106e9b:	e9 a9 f6 ff ff       	jmp    80106549 <alltraps>

80106ea0 <vector47>:
.globl vector47
vector47:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $47
80106ea2:	6a 2f                	push   $0x2f
  jmp alltraps
80106ea4:	e9 a0 f6 ff ff       	jmp    80106549 <alltraps>

80106ea9 <vector48>:
.globl vector48
vector48:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $48
80106eab:	6a 30                	push   $0x30
  jmp alltraps
80106ead:	e9 97 f6 ff ff       	jmp    80106549 <alltraps>

80106eb2 <vector49>:
.globl vector49
vector49:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $49
80106eb4:	6a 31                	push   $0x31
  jmp alltraps
80106eb6:	e9 8e f6 ff ff       	jmp    80106549 <alltraps>

80106ebb <vector50>:
.globl vector50
vector50:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $50
80106ebd:	6a 32                	push   $0x32
  jmp alltraps
80106ebf:	e9 85 f6 ff ff       	jmp    80106549 <alltraps>

80106ec4 <vector51>:
.globl vector51
vector51:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $51
80106ec6:	6a 33                	push   $0x33
  jmp alltraps
80106ec8:	e9 7c f6 ff ff       	jmp    80106549 <alltraps>

80106ecd <vector52>:
.globl vector52
vector52:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $52
80106ecf:	6a 34                	push   $0x34
  jmp alltraps
80106ed1:	e9 73 f6 ff ff       	jmp    80106549 <alltraps>

80106ed6 <vector53>:
.globl vector53
vector53:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $53
80106ed8:	6a 35                	push   $0x35
  jmp alltraps
80106eda:	e9 6a f6 ff ff       	jmp    80106549 <alltraps>

80106edf <vector54>:
.globl vector54
vector54:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $54
80106ee1:	6a 36                	push   $0x36
  jmp alltraps
80106ee3:	e9 61 f6 ff ff       	jmp    80106549 <alltraps>

80106ee8 <vector55>:
.globl vector55
vector55:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $55
80106eea:	6a 37                	push   $0x37
  jmp alltraps
80106eec:	e9 58 f6 ff ff       	jmp    80106549 <alltraps>

80106ef1 <vector56>:
.globl vector56
vector56:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $56
80106ef3:	6a 38                	push   $0x38
  jmp alltraps
80106ef5:	e9 4f f6 ff ff       	jmp    80106549 <alltraps>

80106efa <vector57>:
.globl vector57
vector57:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $57
80106efc:	6a 39                	push   $0x39
  jmp alltraps
80106efe:	e9 46 f6 ff ff       	jmp    80106549 <alltraps>

80106f03 <vector58>:
.globl vector58
vector58:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $58
80106f05:	6a 3a                	push   $0x3a
  jmp alltraps
80106f07:	e9 3d f6 ff ff       	jmp    80106549 <alltraps>

80106f0c <vector59>:
.globl vector59
vector59:
  pushl $0
80106f0c:	6a 00                	push   $0x0
  pushl $59
80106f0e:	6a 3b                	push   $0x3b
  jmp alltraps
80106f10:	e9 34 f6 ff ff       	jmp    80106549 <alltraps>

80106f15 <vector60>:
.globl vector60
vector60:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $60
80106f17:	6a 3c                	push   $0x3c
  jmp alltraps
80106f19:	e9 2b f6 ff ff       	jmp    80106549 <alltraps>

80106f1e <vector61>:
.globl vector61
vector61:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $61
80106f20:	6a 3d                	push   $0x3d
  jmp alltraps
80106f22:	e9 22 f6 ff ff       	jmp    80106549 <alltraps>

80106f27 <vector62>:
.globl vector62
vector62:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $62
80106f29:	6a 3e                	push   $0x3e
  jmp alltraps
80106f2b:	e9 19 f6 ff ff       	jmp    80106549 <alltraps>

80106f30 <vector63>:
.globl vector63
vector63:
  pushl $0
80106f30:	6a 00                	push   $0x0
  pushl $63
80106f32:	6a 3f                	push   $0x3f
  jmp alltraps
80106f34:	e9 10 f6 ff ff       	jmp    80106549 <alltraps>

80106f39 <vector64>:
.globl vector64
vector64:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $64
80106f3b:	6a 40                	push   $0x40
  jmp alltraps
80106f3d:	e9 07 f6 ff ff       	jmp    80106549 <alltraps>

80106f42 <vector65>:
.globl vector65
vector65:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $65
80106f44:	6a 41                	push   $0x41
  jmp alltraps
80106f46:	e9 fe f5 ff ff       	jmp    80106549 <alltraps>

80106f4b <vector66>:
.globl vector66
vector66:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $66
80106f4d:	6a 42                	push   $0x42
  jmp alltraps
80106f4f:	e9 f5 f5 ff ff       	jmp    80106549 <alltraps>

80106f54 <vector67>:
.globl vector67
vector67:
  pushl $0
80106f54:	6a 00                	push   $0x0
  pushl $67
80106f56:	6a 43                	push   $0x43
  jmp alltraps
80106f58:	e9 ec f5 ff ff       	jmp    80106549 <alltraps>

80106f5d <vector68>:
.globl vector68
vector68:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $68
80106f5f:	6a 44                	push   $0x44
  jmp alltraps
80106f61:	e9 e3 f5 ff ff       	jmp    80106549 <alltraps>

80106f66 <vector69>:
.globl vector69
vector69:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $69
80106f68:	6a 45                	push   $0x45
  jmp alltraps
80106f6a:	e9 da f5 ff ff       	jmp    80106549 <alltraps>

80106f6f <vector70>:
.globl vector70
vector70:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $70
80106f71:	6a 46                	push   $0x46
  jmp alltraps
80106f73:	e9 d1 f5 ff ff       	jmp    80106549 <alltraps>

80106f78 <vector71>:
.globl vector71
vector71:
  pushl $0
80106f78:	6a 00                	push   $0x0
  pushl $71
80106f7a:	6a 47                	push   $0x47
  jmp alltraps
80106f7c:	e9 c8 f5 ff ff       	jmp    80106549 <alltraps>

80106f81 <vector72>:
.globl vector72
vector72:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $72
80106f83:	6a 48                	push   $0x48
  jmp alltraps
80106f85:	e9 bf f5 ff ff       	jmp    80106549 <alltraps>

80106f8a <vector73>:
.globl vector73
vector73:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $73
80106f8c:	6a 49                	push   $0x49
  jmp alltraps
80106f8e:	e9 b6 f5 ff ff       	jmp    80106549 <alltraps>

80106f93 <vector74>:
.globl vector74
vector74:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $74
80106f95:	6a 4a                	push   $0x4a
  jmp alltraps
80106f97:	e9 ad f5 ff ff       	jmp    80106549 <alltraps>

80106f9c <vector75>:
.globl vector75
vector75:
  pushl $0
80106f9c:	6a 00                	push   $0x0
  pushl $75
80106f9e:	6a 4b                	push   $0x4b
  jmp alltraps
80106fa0:	e9 a4 f5 ff ff       	jmp    80106549 <alltraps>

80106fa5 <vector76>:
.globl vector76
vector76:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $76
80106fa7:	6a 4c                	push   $0x4c
  jmp alltraps
80106fa9:	e9 9b f5 ff ff       	jmp    80106549 <alltraps>

80106fae <vector77>:
.globl vector77
vector77:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $77
80106fb0:	6a 4d                	push   $0x4d
  jmp alltraps
80106fb2:	e9 92 f5 ff ff       	jmp    80106549 <alltraps>

80106fb7 <vector78>:
.globl vector78
vector78:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $78
80106fb9:	6a 4e                	push   $0x4e
  jmp alltraps
80106fbb:	e9 89 f5 ff ff       	jmp    80106549 <alltraps>

80106fc0 <vector79>:
.globl vector79
vector79:
  pushl $0
80106fc0:	6a 00                	push   $0x0
  pushl $79
80106fc2:	6a 4f                	push   $0x4f
  jmp alltraps
80106fc4:	e9 80 f5 ff ff       	jmp    80106549 <alltraps>

80106fc9 <vector80>:
.globl vector80
vector80:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $80
80106fcb:	6a 50                	push   $0x50
  jmp alltraps
80106fcd:	e9 77 f5 ff ff       	jmp    80106549 <alltraps>

80106fd2 <vector81>:
.globl vector81
vector81:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $81
80106fd4:	6a 51                	push   $0x51
  jmp alltraps
80106fd6:	e9 6e f5 ff ff       	jmp    80106549 <alltraps>

80106fdb <vector82>:
.globl vector82
vector82:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $82
80106fdd:	6a 52                	push   $0x52
  jmp alltraps
80106fdf:	e9 65 f5 ff ff       	jmp    80106549 <alltraps>

80106fe4 <vector83>:
.globl vector83
vector83:
  pushl $0
80106fe4:	6a 00                	push   $0x0
  pushl $83
80106fe6:	6a 53                	push   $0x53
  jmp alltraps
80106fe8:	e9 5c f5 ff ff       	jmp    80106549 <alltraps>

80106fed <vector84>:
.globl vector84
vector84:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $84
80106fef:	6a 54                	push   $0x54
  jmp alltraps
80106ff1:	e9 53 f5 ff ff       	jmp    80106549 <alltraps>

80106ff6 <vector85>:
.globl vector85
vector85:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $85
80106ff8:	6a 55                	push   $0x55
  jmp alltraps
80106ffa:	e9 4a f5 ff ff       	jmp    80106549 <alltraps>

80106fff <vector86>:
.globl vector86
vector86:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $86
80107001:	6a 56                	push   $0x56
  jmp alltraps
80107003:	e9 41 f5 ff ff       	jmp    80106549 <alltraps>

80107008 <vector87>:
.globl vector87
vector87:
  pushl $0
80107008:	6a 00                	push   $0x0
  pushl $87
8010700a:	6a 57                	push   $0x57
  jmp alltraps
8010700c:	e9 38 f5 ff ff       	jmp    80106549 <alltraps>

80107011 <vector88>:
.globl vector88
vector88:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $88
80107013:	6a 58                	push   $0x58
  jmp alltraps
80107015:	e9 2f f5 ff ff       	jmp    80106549 <alltraps>

8010701a <vector89>:
.globl vector89
vector89:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $89
8010701c:	6a 59                	push   $0x59
  jmp alltraps
8010701e:	e9 26 f5 ff ff       	jmp    80106549 <alltraps>

80107023 <vector90>:
.globl vector90
vector90:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $90
80107025:	6a 5a                	push   $0x5a
  jmp alltraps
80107027:	e9 1d f5 ff ff       	jmp    80106549 <alltraps>

8010702c <vector91>:
.globl vector91
vector91:
  pushl $0
8010702c:	6a 00                	push   $0x0
  pushl $91
8010702e:	6a 5b                	push   $0x5b
  jmp alltraps
80107030:	e9 14 f5 ff ff       	jmp    80106549 <alltraps>

80107035 <vector92>:
.globl vector92
vector92:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $92
80107037:	6a 5c                	push   $0x5c
  jmp alltraps
80107039:	e9 0b f5 ff ff       	jmp    80106549 <alltraps>

8010703e <vector93>:
.globl vector93
vector93:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $93
80107040:	6a 5d                	push   $0x5d
  jmp alltraps
80107042:	e9 02 f5 ff ff       	jmp    80106549 <alltraps>

80107047 <vector94>:
.globl vector94
vector94:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $94
80107049:	6a 5e                	push   $0x5e
  jmp alltraps
8010704b:	e9 f9 f4 ff ff       	jmp    80106549 <alltraps>

80107050 <vector95>:
.globl vector95
vector95:
  pushl $0
80107050:	6a 00                	push   $0x0
  pushl $95
80107052:	6a 5f                	push   $0x5f
  jmp alltraps
80107054:	e9 f0 f4 ff ff       	jmp    80106549 <alltraps>

80107059 <vector96>:
.globl vector96
vector96:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $96
8010705b:	6a 60                	push   $0x60
  jmp alltraps
8010705d:	e9 e7 f4 ff ff       	jmp    80106549 <alltraps>

80107062 <vector97>:
.globl vector97
vector97:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $97
80107064:	6a 61                	push   $0x61
  jmp alltraps
80107066:	e9 de f4 ff ff       	jmp    80106549 <alltraps>

8010706b <vector98>:
.globl vector98
vector98:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $98
8010706d:	6a 62                	push   $0x62
  jmp alltraps
8010706f:	e9 d5 f4 ff ff       	jmp    80106549 <alltraps>

80107074 <vector99>:
.globl vector99
vector99:
  pushl $0
80107074:	6a 00                	push   $0x0
  pushl $99
80107076:	6a 63                	push   $0x63
  jmp alltraps
80107078:	e9 cc f4 ff ff       	jmp    80106549 <alltraps>

8010707d <vector100>:
.globl vector100
vector100:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $100
8010707f:	6a 64                	push   $0x64
  jmp alltraps
80107081:	e9 c3 f4 ff ff       	jmp    80106549 <alltraps>

80107086 <vector101>:
.globl vector101
vector101:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $101
80107088:	6a 65                	push   $0x65
  jmp alltraps
8010708a:	e9 ba f4 ff ff       	jmp    80106549 <alltraps>

8010708f <vector102>:
.globl vector102
vector102:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $102
80107091:	6a 66                	push   $0x66
  jmp alltraps
80107093:	e9 b1 f4 ff ff       	jmp    80106549 <alltraps>

80107098 <vector103>:
.globl vector103
vector103:
  pushl $0
80107098:	6a 00                	push   $0x0
  pushl $103
8010709a:	6a 67                	push   $0x67
  jmp alltraps
8010709c:	e9 a8 f4 ff ff       	jmp    80106549 <alltraps>

801070a1 <vector104>:
.globl vector104
vector104:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $104
801070a3:	6a 68                	push   $0x68
  jmp alltraps
801070a5:	e9 9f f4 ff ff       	jmp    80106549 <alltraps>

801070aa <vector105>:
.globl vector105
vector105:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $105
801070ac:	6a 69                	push   $0x69
  jmp alltraps
801070ae:	e9 96 f4 ff ff       	jmp    80106549 <alltraps>

801070b3 <vector106>:
.globl vector106
vector106:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $106
801070b5:	6a 6a                	push   $0x6a
  jmp alltraps
801070b7:	e9 8d f4 ff ff       	jmp    80106549 <alltraps>

801070bc <vector107>:
.globl vector107
vector107:
  pushl $0
801070bc:	6a 00                	push   $0x0
  pushl $107
801070be:	6a 6b                	push   $0x6b
  jmp alltraps
801070c0:	e9 84 f4 ff ff       	jmp    80106549 <alltraps>

801070c5 <vector108>:
.globl vector108
vector108:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $108
801070c7:	6a 6c                	push   $0x6c
  jmp alltraps
801070c9:	e9 7b f4 ff ff       	jmp    80106549 <alltraps>

801070ce <vector109>:
.globl vector109
vector109:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $109
801070d0:	6a 6d                	push   $0x6d
  jmp alltraps
801070d2:	e9 72 f4 ff ff       	jmp    80106549 <alltraps>

801070d7 <vector110>:
.globl vector110
vector110:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $110
801070d9:	6a 6e                	push   $0x6e
  jmp alltraps
801070db:	e9 69 f4 ff ff       	jmp    80106549 <alltraps>

801070e0 <vector111>:
.globl vector111
vector111:
  pushl $0
801070e0:	6a 00                	push   $0x0
  pushl $111
801070e2:	6a 6f                	push   $0x6f
  jmp alltraps
801070e4:	e9 60 f4 ff ff       	jmp    80106549 <alltraps>

801070e9 <vector112>:
.globl vector112
vector112:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $112
801070eb:	6a 70                	push   $0x70
  jmp alltraps
801070ed:	e9 57 f4 ff ff       	jmp    80106549 <alltraps>

801070f2 <vector113>:
.globl vector113
vector113:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $113
801070f4:	6a 71                	push   $0x71
  jmp alltraps
801070f6:	e9 4e f4 ff ff       	jmp    80106549 <alltraps>

801070fb <vector114>:
.globl vector114
vector114:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $114
801070fd:	6a 72                	push   $0x72
  jmp alltraps
801070ff:	e9 45 f4 ff ff       	jmp    80106549 <alltraps>

80107104 <vector115>:
.globl vector115
vector115:
  pushl $0
80107104:	6a 00                	push   $0x0
  pushl $115
80107106:	6a 73                	push   $0x73
  jmp alltraps
80107108:	e9 3c f4 ff ff       	jmp    80106549 <alltraps>

8010710d <vector116>:
.globl vector116
vector116:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $116
8010710f:	6a 74                	push   $0x74
  jmp alltraps
80107111:	e9 33 f4 ff ff       	jmp    80106549 <alltraps>

80107116 <vector117>:
.globl vector117
vector117:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $117
80107118:	6a 75                	push   $0x75
  jmp alltraps
8010711a:	e9 2a f4 ff ff       	jmp    80106549 <alltraps>

8010711f <vector118>:
.globl vector118
vector118:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $118
80107121:	6a 76                	push   $0x76
  jmp alltraps
80107123:	e9 21 f4 ff ff       	jmp    80106549 <alltraps>

80107128 <vector119>:
.globl vector119
vector119:
  pushl $0
80107128:	6a 00                	push   $0x0
  pushl $119
8010712a:	6a 77                	push   $0x77
  jmp alltraps
8010712c:	e9 18 f4 ff ff       	jmp    80106549 <alltraps>

80107131 <vector120>:
.globl vector120
vector120:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $120
80107133:	6a 78                	push   $0x78
  jmp alltraps
80107135:	e9 0f f4 ff ff       	jmp    80106549 <alltraps>

8010713a <vector121>:
.globl vector121
vector121:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $121
8010713c:	6a 79                	push   $0x79
  jmp alltraps
8010713e:	e9 06 f4 ff ff       	jmp    80106549 <alltraps>

80107143 <vector122>:
.globl vector122
vector122:
  pushl $0
80107143:	6a 00                	push   $0x0
  pushl $122
80107145:	6a 7a                	push   $0x7a
  jmp alltraps
80107147:	e9 fd f3 ff ff       	jmp    80106549 <alltraps>

8010714c <vector123>:
.globl vector123
vector123:
  pushl $0
8010714c:	6a 00                	push   $0x0
  pushl $123
8010714e:	6a 7b                	push   $0x7b
  jmp alltraps
80107150:	e9 f4 f3 ff ff       	jmp    80106549 <alltraps>

80107155 <vector124>:
.globl vector124
vector124:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $124
80107157:	6a 7c                	push   $0x7c
  jmp alltraps
80107159:	e9 eb f3 ff ff       	jmp    80106549 <alltraps>

8010715e <vector125>:
.globl vector125
vector125:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $125
80107160:	6a 7d                	push   $0x7d
  jmp alltraps
80107162:	e9 e2 f3 ff ff       	jmp    80106549 <alltraps>

80107167 <vector126>:
.globl vector126
vector126:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $126
80107169:	6a 7e                	push   $0x7e
  jmp alltraps
8010716b:	e9 d9 f3 ff ff       	jmp    80106549 <alltraps>

80107170 <vector127>:
.globl vector127
vector127:
  pushl $0
80107170:	6a 00                	push   $0x0
  pushl $127
80107172:	6a 7f                	push   $0x7f
  jmp alltraps
80107174:	e9 d0 f3 ff ff       	jmp    80106549 <alltraps>

80107179 <vector128>:
.globl vector128
vector128:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $128
8010717b:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107180:	e9 c4 f3 ff ff       	jmp    80106549 <alltraps>

80107185 <vector129>:
.globl vector129
vector129:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $129
80107187:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010718c:	e9 b8 f3 ff ff       	jmp    80106549 <alltraps>

80107191 <vector130>:
.globl vector130
vector130:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $130
80107193:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107198:	e9 ac f3 ff ff       	jmp    80106549 <alltraps>

8010719d <vector131>:
.globl vector131
vector131:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $131
8010719f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801071a4:	e9 a0 f3 ff ff       	jmp    80106549 <alltraps>

801071a9 <vector132>:
.globl vector132
vector132:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $132
801071ab:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801071b0:	e9 94 f3 ff ff       	jmp    80106549 <alltraps>

801071b5 <vector133>:
.globl vector133
vector133:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $133
801071b7:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801071bc:	e9 88 f3 ff ff       	jmp    80106549 <alltraps>

801071c1 <vector134>:
.globl vector134
vector134:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $134
801071c3:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801071c8:	e9 7c f3 ff ff       	jmp    80106549 <alltraps>

801071cd <vector135>:
.globl vector135
vector135:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $135
801071cf:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801071d4:	e9 70 f3 ff ff       	jmp    80106549 <alltraps>

801071d9 <vector136>:
.globl vector136
vector136:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $136
801071db:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801071e0:	e9 64 f3 ff ff       	jmp    80106549 <alltraps>

801071e5 <vector137>:
.globl vector137
vector137:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $137
801071e7:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801071ec:	e9 58 f3 ff ff       	jmp    80106549 <alltraps>

801071f1 <vector138>:
.globl vector138
vector138:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $138
801071f3:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801071f8:	e9 4c f3 ff ff       	jmp    80106549 <alltraps>

801071fd <vector139>:
.globl vector139
vector139:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $139
801071ff:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107204:	e9 40 f3 ff ff       	jmp    80106549 <alltraps>

80107209 <vector140>:
.globl vector140
vector140:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $140
8010720b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107210:	e9 34 f3 ff ff       	jmp    80106549 <alltraps>

80107215 <vector141>:
.globl vector141
vector141:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $141
80107217:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010721c:	e9 28 f3 ff ff       	jmp    80106549 <alltraps>

80107221 <vector142>:
.globl vector142
vector142:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $142
80107223:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107228:	e9 1c f3 ff ff       	jmp    80106549 <alltraps>

8010722d <vector143>:
.globl vector143
vector143:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $143
8010722f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107234:	e9 10 f3 ff ff       	jmp    80106549 <alltraps>

80107239 <vector144>:
.globl vector144
vector144:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $144
8010723b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107240:	e9 04 f3 ff ff       	jmp    80106549 <alltraps>

80107245 <vector145>:
.globl vector145
vector145:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $145
80107247:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010724c:	e9 f8 f2 ff ff       	jmp    80106549 <alltraps>

80107251 <vector146>:
.globl vector146
vector146:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $146
80107253:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107258:	e9 ec f2 ff ff       	jmp    80106549 <alltraps>

8010725d <vector147>:
.globl vector147
vector147:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $147
8010725f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107264:	e9 e0 f2 ff ff       	jmp    80106549 <alltraps>

80107269 <vector148>:
.globl vector148
vector148:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $148
8010726b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107270:	e9 d4 f2 ff ff       	jmp    80106549 <alltraps>

80107275 <vector149>:
.globl vector149
vector149:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $149
80107277:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010727c:	e9 c8 f2 ff ff       	jmp    80106549 <alltraps>

80107281 <vector150>:
.globl vector150
vector150:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $150
80107283:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107288:	e9 bc f2 ff ff       	jmp    80106549 <alltraps>

8010728d <vector151>:
.globl vector151
vector151:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $151
8010728f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107294:	e9 b0 f2 ff ff       	jmp    80106549 <alltraps>

80107299 <vector152>:
.globl vector152
vector152:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $152
8010729b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801072a0:	e9 a4 f2 ff ff       	jmp    80106549 <alltraps>

801072a5 <vector153>:
.globl vector153
vector153:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $153
801072a7:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801072ac:	e9 98 f2 ff ff       	jmp    80106549 <alltraps>

801072b1 <vector154>:
.globl vector154
vector154:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $154
801072b3:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801072b8:	e9 8c f2 ff ff       	jmp    80106549 <alltraps>

801072bd <vector155>:
.globl vector155
vector155:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $155
801072bf:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801072c4:	e9 80 f2 ff ff       	jmp    80106549 <alltraps>

801072c9 <vector156>:
.globl vector156
vector156:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $156
801072cb:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801072d0:	e9 74 f2 ff ff       	jmp    80106549 <alltraps>

801072d5 <vector157>:
.globl vector157
vector157:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $157
801072d7:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801072dc:	e9 68 f2 ff ff       	jmp    80106549 <alltraps>

801072e1 <vector158>:
.globl vector158
vector158:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $158
801072e3:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801072e8:	e9 5c f2 ff ff       	jmp    80106549 <alltraps>

801072ed <vector159>:
.globl vector159
vector159:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $159
801072ef:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801072f4:	e9 50 f2 ff ff       	jmp    80106549 <alltraps>

801072f9 <vector160>:
.globl vector160
vector160:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $160
801072fb:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107300:	e9 44 f2 ff ff       	jmp    80106549 <alltraps>

80107305 <vector161>:
.globl vector161
vector161:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $161
80107307:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010730c:	e9 38 f2 ff ff       	jmp    80106549 <alltraps>

80107311 <vector162>:
.globl vector162
vector162:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $162
80107313:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107318:	e9 2c f2 ff ff       	jmp    80106549 <alltraps>

8010731d <vector163>:
.globl vector163
vector163:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $163
8010731f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107324:	e9 20 f2 ff ff       	jmp    80106549 <alltraps>

80107329 <vector164>:
.globl vector164
vector164:
  pushl $0
80107329:	6a 00                	push   $0x0
  pushl $164
8010732b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107330:	e9 14 f2 ff ff       	jmp    80106549 <alltraps>

80107335 <vector165>:
.globl vector165
vector165:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $165
80107337:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010733c:	e9 08 f2 ff ff       	jmp    80106549 <alltraps>

80107341 <vector166>:
.globl vector166
vector166:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $166
80107343:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107348:	e9 fc f1 ff ff       	jmp    80106549 <alltraps>

8010734d <vector167>:
.globl vector167
vector167:
  pushl $0
8010734d:	6a 00                	push   $0x0
  pushl $167
8010734f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107354:	e9 f0 f1 ff ff       	jmp    80106549 <alltraps>

80107359 <vector168>:
.globl vector168
vector168:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $168
8010735b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107360:	e9 e4 f1 ff ff       	jmp    80106549 <alltraps>

80107365 <vector169>:
.globl vector169
vector169:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $169
80107367:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010736c:	e9 d8 f1 ff ff       	jmp    80106549 <alltraps>

80107371 <vector170>:
.globl vector170
vector170:
  pushl $0
80107371:	6a 00                	push   $0x0
  pushl $170
80107373:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107378:	e9 cc f1 ff ff       	jmp    80106549 <alltraps>

8010737d <vector171>:
.globl vector171
vector171:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $171
8010737f:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107384:	e9 c0 f1 ff ff       	jmp    80106549 <alltraps>

80107389 <vector172>:
.globl vector172
vector172:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $172
8010738b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107390:	e9 b4 f1 ff ff       	jmp    80106549 <alltraps>

80107395 <vector173>:
.globl vector173
vector173:
  pushl $0
80107395:	6a 00                	push   $0x0
  pushl $173
80107397:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010739c:	e9 a8 f1 ff ff       	jmp    80106549 <alltraps>

801073a1 <vector174>:
.globl vector174
vector174:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $174
801073a3:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801073a8:	e9 9c f1 ff ff       	jmp    80106549 <alltraps>

801073ad <vector175>:
.globl vector175
vector175:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $175
801073af:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801073b4:	e9 90 f1 ff ff       	jmp    80106549 <alltraps>

801073b9 <vector176>:
.globl vector176
vector176:
  pushl $0
801073b9:	6a 00                	push   $0x0
  pushl $176
801073bb:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801073c0:	e9 84 f1 ff ff       	jmp    80106549 <alltraps>

801073c5 <vector177>:
.globl vector177
vector177:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $177
801073c7:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801073cc:	e9 78 f1 ff ff       	jmp    80106549 <alltraps>

801073d1 <vector178>:
.globl vector178
vector178:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $178
801073d3:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801073d8:	e9 6c f1 ff ff       	jmp    80106549 <alltraps>

801073dd <vector179>:
.globl vector179
vector179:
  pushl $0
801073dd:	6a 00                	push   $0x0
  pushl $179
801073df:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801073e4:	e9 60 f1 ff ff       	jmp    80106549 <alltraps>

801073e9 <vector180>:
.globl vector180
vector180:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $180
801073eb:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801073f0:	e9 54 f1 ff ff       	jmp    80106549 <alltraps>

801073f5 <vector181>:
.globl vector181
vector181:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $181
801073f7:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801073fc:	e9 48 f1 ff ff       	jmp    80106549 <alltraps>

80107401 <vector182>:
.globl vector182
vector182:
  pushl $0
80107401:	6a 00                	push   $0x0
  pushl $182
80107403:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107408:	e9 3c f1 ff ff       	jmp    80106549 <alltraps>

8010740d <vector183>:
.globl vector183
vector183:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $183
8010740f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107414:	e9 30 f1 ff ff       	jmp    80106549 <alltraps>

80107419 <vector184>:
.globl vector184
vector184:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $184
8010741b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107420:	e9 24 f1 ff ff       	jmp    80106549 <alltraps>

80107425 <vector185>:
.globl vector185
vector185:
  pushl $0
80107425:	6a 00                	push   $0x0
  pushl $185
80107427:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010742c:	e9 18 f1 ff ff       	jmp    80106549 <alltraps>

80107431 <vector186>:
.globl vector186
vector186:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $186
80107433:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107438:	e9 0c f1 ff ff       	jmp    80106549 <alltraps>

8010743d <vector187>:
.globl vector187
vector187:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $187
8010743f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107444:	e9 00 f1 ff ff       	jmp    80106549 <alltraps>

80107449 <vector188>:
.globl vector188
vector188:
  pushl $0
80107449:	6a 00                	push   $0x0
  pushl $188
8010744b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107450:	e9 f4 f0 ff ff       	jmp    80106549 <alltraps>

80107455 <vector189>:
.globl vector189
vector189:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $189
80107457:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010745c:	e9 e8 f0 ff ff       	jmp    80106549 <alltraps>

80107461 <vector190>:
.globl vector190
vector190:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $190
80107463:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107468:	e9 dc f0 ff ff       	jmp    80106549 <alltraps>

8010746d <vector191>:
.globl vector191
vector191:
  pushl $0
8010746d:	6a 00                	push   $0x0
  pushl $191
8010746f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107474:	e9 d0 f0 ff ff       	jmp    80106549 <alltraps>

80107479 <vector192>:
.globl vector192
vector192:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $192
8010747b:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107480:	e9 c4 f0 ff ff       	jmp    80106549 <alltraps>

80107485 <vector193>:
.globl vector193
vector193:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $193
80107487:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010748c:	e9 b8 f0 ff ff       	jmp    80106549 <alltraps>

80107491 <vector194>:
.globl vector194
vector194:
  pushl $0
80107491:	6a 00                	push   $0x0
  pushl $194
80107493:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107498:	e9 ac f0 ff ff       	jmp    80106549 <alltraps>

8010749d <vector195>:
.globl vector195
vector195:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $195
8010749f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801074a4:	e9 a0 f0 ff ff       	jmp    80106549 <alltraps>

801074a9 <vector196>:
.globl vector196
vector196:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $196
801074ab:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801074b0:	e9 94 f0 ff ff       	jmp    80106549 <alltraps>

801074b5 <vector197>:
.globl vector197
vector197:
  pushl $0
801074b5:	6a 00                	push   $0x0
  pushl $197
801074b7:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801074bc:	e9 88 f0 ff ff       	jmp    80106549 <alltraps>

801074c1 <vector198>:
.globl vector198
vector198:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $198
801074c3:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801074c8:	e9 7c f0 ff ff       	jmp    80106549 <alltraps>

801074cd <vector199>:
.globl vector199
vector199:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $199
801074cf:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801074d4:	e9 70 f0 ff ff       	jmp    80106549 <alltraps>

801074d9 <vector200>:
.globl vector200
vector200:
  pushl $0
801074d9:	6a 00                	push   $0x0
  pushl $200
801074db:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801074e0:	e9 64 f0 ff ff       	jmp    80106549 <alltraps>

801074e5 <vector201>:
.globl vector201
vector201:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $201
801074e7:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801074ec:	e9 58 f0 ff ff       	jmp    80106549 <alltraps>

801074f1 <vector202>:
.globl vector202
vector202:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $202
801074f3:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801074f8:	e9 4c f0 ff ff       	jmp    80106549 <alltraps>

801074fd <vector203>:
.globl vector203
vector203:
  pushl $0
801074fd:	6a 00                	push   $0x0
  pushl $203
801074ff:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107504:	e9 40 f0 ff ff       	jmp    80106549 <alltraps>

80107509 <vector204>:
.globl vector204
vector204:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $204
8010750b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107510:	e9 34 f0 ff ff       	jmp    80106549 <alltraps>

80107515 <vector205>:
.globl vector205
vector205:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $205
80107517:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010751c:	e9 28 f0 ff ff       	jmp    80106549 <alltraps>

80107521 <vector206>:
.globl vector206
vector206:
  pushl $0
80107521:	6a 00                	push   $0x0
  pushl $206
80107523:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107528:	e9 1c f0 ff ff       	jmp    80106549 <alltraps>

8010752d <vector207>:
.globl vector207
vector207:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $207
8010752f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107534:	e9 10 f0 ff ff       	jmp    80106549 <alltraps>

80107539 <vector208>:
.globl vector208
vector208:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $208
8010753b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107540:	e9 04 f0 ff ff       	jmp    80106549 <alltraps>

80107545 <vector209>:
.globl vector209
vector209:
  pushl $0
80107545:	6a 00                	push   $0x0
  pushl $209
80107547:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010754c:	e9 f8 ef ff ff       	jmp    80106549 <alltraps>

80107551 <vector210>:
.globl vector210
vector210:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $210
80107553:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107558:	e9 ec ef ff ff       	jmp    80106549 <alltraps>

8010755d <vector211>:
.globl vector211
vector211:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $211
8010755f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107564:	e9 e0 ef ff ff       	jmp    80106549 <alltraps>

80107569 <vector212>:
.globl vector212
vector212:
  pushl $0
80107569:	6a 00                	push   $0x0
  pushl $212
8010756b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107570:	e9 d4 ef ff ff       	jmp    80106549 <alltraps>

80107575 <vector213>:
.globl vector213
vector213:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $213
80107577:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010757c:	e9 c8 ef ff ff       	jmp    80106549 <alltraps>

80107581 <vector214>:
.globl vector214
vector214:
  pushl $0
80107581:	6a 00                	push   $0x0
  pushl $214
80107583:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107588:	e9 bc ef ff ff       	jmp    80106549 <alltraps>

8010758d <vector215>:
.globl vector215
vector215:
  pushl $0
8010758d:	6a 00                	push   $0x0
  pushl $215
8010758f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107594:	e9 b0 ef ff ff       	jmp    80106549 <alltraps>

80107599 <vector216>:
.globl vector216
vector216:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $216
8010759b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801075a0:	e9 a4 ef ff ff       	jmp    80106549 <alltraps>

801075a5 <vector217>:
.globl vector217
vector217:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $217
801075a7:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801075ac:	e9 98 ef ff ff       	jmp    80106549 <alltraps>

801075b1 <vector218>:
.globl vector218
vector218:
  pushl $0
801075b1:	6a 00                	push   $0x0
  pushl $218
801075b3:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801075b8:	e9 8c ef ff ff       	jmp    80106549 <alltraps>

801075bd <vector219>:
.globl vector219
vector219:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $219
801075bf:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801075c4:	e9 80 ef ff ff       	jmp    80106549 <alltraps>

801075c9 <vector220>:
.globl vector220
vector220:
  pushl $0
801075c9:	6a 00                	push   $0x0
  pushl $220
801075cb:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801075d0:	e9 74 ef ff ff       	jmp    80106549 <alltraps>

801075d5 <vector221>:
.globl vector221
vector221:
  pushl $0
801075d5:	6a 00                	push   $0x0
  pushl $221
801075d7:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801075dc:	e9 68 ef ff ff       	jmp    80106549 <alltraps>

801075e1 <vector222>:
.globl vector222
vector222:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $222
801075e3:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801075e8:	e9 5c ef ff ff       	jmp    80106549 <alltraps>

801075ed <vector223>:
.globl vector223
vector223:
  pushl $0
801075ed:	6a 00                	push   $0x0
  pushl $223
801075ef:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801075f4:	e9 50 ef ff ff       	jmp    80106549 <alltraps>

801075f9 <vector224>:
.globl vector224
vector224:
  pushl $0
801075f9:	6a 00                	push   $0x0
  pushl $224
801075fb:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107600:	e9 44 ef ff ff       	jmp    80106549 <alltraps>

80107605 <vector225>:
.globl vector225
vector225:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $225
80107607:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010760c:	e9 38 ef ff ff       	jmp    80106549 <alltraps>

80107611 <vector226>:
.globl vector226
vector226:
  pushl $0
80107611:	6a 00                	push   $0x0
  pushl $226
80107613:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107618:	e9 2c ef ff ff       	jmp    80106549 <alltraps>

8010761d <vector227>:
.globl vector227
vector227:
  pushl $0
8010761d:	6a 00                	push   $0x0
  pushl $227
8010761f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107624:	e9 20 ef ff ff       	jmp    80106549 <alltraps>

80107629 <vector228>:
.globl vector228
vector228:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $228
8010762b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107630:	e9 14 ef ff ff       	jmp    80106549 <alltraps>

80107635 <vector229>:
.globl vector229
vector229:
  pushl $0
80107635:	6a 00                	push   $0x0
  pushl $229
80107637:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010763c:	e9 08 ef ff ff       	jmp    80106549 <alltraps>

80107641 <vector230>:
.globl vector230
vector230:
  pushl $0
80107641:	6a 00                	push   $0x0
  pushl $230
80107643:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107648:	e9 fc ee ff ff       	jmp    80106549 <alltraps>

8010764d <vector231>:
.globl vector231
vector231:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $231
8010764f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107654:	e9 f0 ee ff ff       	jmp    80106549 <alltraps>

80107659 <vector232>:
.globl vector232
vector232:
  pushl $0
80107659:	6a 00                	push   $0x0
  pushl $232
8010765b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107660:	e9 e4 ee ff ff       	jmp    80106549 <alltraps>

80107665 <vector233>:
.globl vector233
vector233:
  pushl $0
80107665:	6a 00                	push   $0x0
  pushl $233
80107667:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010766c:	e9 d8 ee ff ff       	jmp    80106549 <alltraps>

80107671 <vector234>:
.globl vector234
vector234:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $234
80107673:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107678:	e9 cc ee ff ff       	jmp    80106549 <alltraps>

8010767d <vector235>:
.globl vector235
vector235:
  pushl $0
8010767d:	6a 00                	push   $0x0
  pushl $235
8010767f:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107684:	e9 c0 ee ff ff       	jmp    80106549 <alltraps>

80107689 <vector236>:
.globl vector236
vector236:
  pushl $0
80107689:	6a 00                	push   $0x0
  pushl $236
8010768b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107690:	e9 b4 ee ff ff       	jmp    80106549 <alltraps>

80107695 <vector237>:
.globl vector237
vector237:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $237
80107697:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010769c:	e9 a8 ee ff ff       	jmp    80106549 <alltraps>

801076a1 <vector238>:
.globl vector238
vector238:
  pushl $0
801076a1:	6a 00                	push   $0x0
  pushl $238
801076a3:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801076a8:	e9 9c ee ff ff       	jmp    80106549 <alltraps>

801076ad <vector239>:
.globl vector239
vector239:
  pushl $0
801076ad:	6a 00                	push   $0x0
  pushl $239
801076af:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801076b4:	e9 90 ee ff ff       	jmp    80106549 <alltraps>

801076b9 <vector240>:
.globl vector240
vector240:
  pushl $0
801076b9:	6a 00                	push   $0x0
  pushl $240
801076bb:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801076c0:	e9 84 ee ff ff       	jmp    80106549 <alltraps>

801076c5 <vector241>:
.globl vector241
vector241:
  pushl $0
801076c5:	6a 00                	push   $0x0
  pushl $241
801076c7:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801076cc:	e9 78 ee ff ff       	jmp    80106549 <alltraps>

801076d1 <vector242>:
.globl vector242
vector242:
  pushl $0
801076d1:	6a 00                	push   $0x0
  pushl $242
801076d3:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801076d8:	e9 6c ee ff ff       	jmp    80106549 <alltraps>

801076dd <vector243>:
.globl vector243
vector243:
  pushl $0
801076dd:	6a 00                	push   $0x0
  pushl $243
801076df:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801076e4:	e9 60 ee ff ff       	jmp    80106549 <alltraps>

801076e9 <vector244>:
.globl vector244
vector244:
  pushl $0
801076e9:	6a 00                	push   $0x0
  pushl $244
801076eb:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801076f0:	e9 54 ee ff ff       	jmp    80106549 <alltraps>

801076f5 <vector245>:
.globl vector245
vector245:
  pushl $0
801076f5:	6a 00                	push   $0x0
  pushl $245
801076f7:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801076fc:	e9 48 ee ff ff       	jmp    80106549 <alltraps>

80107701 <vector246>:
.globl vector246
vector246:
  pushl $0
80107701:	6a 00                	push   $0x0
  pushl $246
80107703:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107708:	e9 3c ee ff ff       	jmp    80106549 <alltraps>

8010770d <vector247>:
.globl vector247
vector247:
  pushl $0
8010770d:	6a 00                	push   $0x0
  pushl $247
8010770f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107714:	e9 30 ee ff ff       	jmp    80106549 <alltraps>

80107719 <vector248>:
.globl vector248
vector248:
  pushl $0
80107719:	6a 00                	push   $0x0
  pushl $248
8010771b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107720:	e9 24 ee ff ff       	jmp    80106549 <alltraps>

80107725 <vector249>:
.globl vector249
vector249:
  pushl $0
80107725:	6a 00                	push   $0x0
  pushl $249
80107727:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010772c:	e9 18 ee ff ff       	jmp    80106549 <alltraps>

80107731 <vector250>:
.globl vector250
vector250:
  pushl $0
80107731:	6a 00                	push   $0x0
  pushl $250
80107733:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107738:	e9 0c ee ff ff       	jmp    80106549 <alltraps>

8010773d <vector251>:
.globl vector251
vector251:
  pushl $0
8010773d:	6a 00                	push   $0x0
  pushl $251
8010773f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107744:	e9 00 ee ff ff       	jmp    80106549 <alltraps>

80107749 <vector252>:
.globl vector252
vector252:
  pushl $0
80107749:	6a 00                	push   $0x0
  pushl $252
8010774b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107750:	e9 f4 ed ff ff       	jmp    80106549 <alltraps>

80107755 <vector253>:
.globl vector253
vector253:
  pushl $0
80107755:	6a 00                	push   $0x0
  pushl $253
80107757:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010775c:	e9 e8 ed ff ff       	jmp    80106549 <alltraps>

80107761 <vector254>:
.globl vector254
vector254:
  pushl $0
80107761:	6a 00                	push   $0x0
  pushl $254
80107763:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107768:	e9 dc ed ff ff       	jmp    80106549 <alltraps>

8010776d <vector255>:
.globl vector255
vector255:
  pushl $0
8010776d:	6a 00                	push   $0x0
  pushl $255
8010776f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107774:	e9 d0 ed ff ff       	jmp    80106549 <alltraps>

80107779 <lgdt>:
{
80107779:	55                   	push   %ebp
8010777a:	89 e5                	mov    %esp,%ebp
8010777c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010777f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107782:	83 e8 01             	sub    $0x1,%eax
80107785:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107789:	8b 45 08             	mov    0x8(%ebp),%eax
8010778c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107790:	8b 45 08             	mov    0x8(%ebp),%eax
80107793:	c1 e8 10             	shr    $0x10,%eax
80107796:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010779a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010779d:	0f 01 10             	lgdtl  (%eax)
}
801077a0:	90                   	nop
801077a1:	c9                   	leave  
801077a2:	c3                   	ret    

801077a3 <ltr>:
{
801077a3:	55                   	push   %ebp
801077a4:	89 e5                	mov    %esp,%ebp
801077a6:	83 ec 04             	sub    $0x4,%esp
801077a9:	8b 45 08             	mov    0x8(%ebp),%eax
801077ac:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801077b0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801077b4:	0f 00 d8             	ltr    %ax
}
801077b7:	90                   	nop
801077b8:	c9                   	leave  
801077b9:	c3                   	ret    

801077ba <lcr3>:
{
801077ba:	55                   	push   %ebp
801077bb:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801077bd:	8b 45 08             	mov    0x8(%ebp),%eax
801077c0:	0f 22 d8             	mov    %eax,%cr3
}
801077c3:	90                   	nop
801077c4:	5d                   	pop    %ebp
801077c5:	c3                   	ret    

801077c6 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801077c6:	55                   	push   %ebp
801077c7:	89 e5                	mov    %esp,%ebp
801077c9:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801077cc:	e8 b4 c1 ff ff       	call   80103985 <cpuid>
801077d1:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801077d7:	05 80 e4 30 80       	add    $0x8030e480,%eax
801077dc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801077df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e2:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801077e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077eb:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801077f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f4:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801077f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077ff:	83 e2 f0             	and    $0xfffffff0,%edx
80107802:	83 ca 0a             	or     $0xa,%edx
80107805:	88 50 7d             	mov    %dl,0x7d(%eax)
80107808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010780f:	83 ca 10             	or     $0x10,%edx
80107812:	88 50 7d             	mov    %dl,0x7d(%eax)
80107815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107818:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010781c:	83 e2 9f             	and    $0xffffff9f,%edx
8010781f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107825:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107829:	83 ca 80             	or     $0xffffff80,%edx
8010782c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010782f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107832:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107836:	83 ca 0f             	or     $0xf,%edx
80107839:	88 50 7e             	mov    %dl,0x7e(%eax)
8010783c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107843:	83 e2 ef             	and    $0xffffffef,%edx
80107846:	88 50 7e             	mov    %dl,0x7e(%eax)
80107849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107850:	83 e2 df             	and    $0xffffffdf,%edx
80107853:	88 50 7e             	mov    %dl,0x7e(%eax)
80107856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107859:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010785d:	83 ca 40             	or     $0x40,%edx
80107860:	88 50 7e             	mov    %dl,0x7e(%eax)
80107863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107866:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010786a:	83 ca 80             	or     $0xffffff80,%edx
8010786d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107873:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107881:	ff ff 
80107883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107886:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010788d:	00 00 
8010788f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107892:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078a3:	83 e2 f0             	and    $0xfffffff0,%edx
801078a6:	83 ca 02             	or     $0x2,%edx
801078a9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078b9:	83 ca 10             	or     $0x10,%edx
801078bc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078cc:	83 e2 9f             	and    $0xffffff9f,%edx
801078cf:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078df:	83 ca 80             	or     $0xffffff80,%edx
801078e2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078eb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078f2:	83 ca 0f             	or     $0xf,%edx
801078f5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fe:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107905:	83 e2 ef             	and    $0xffffffef,%edx
80107908:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010790e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107911:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107918:	83 e2 df             	and    $0xffffffdf,%edx
8010791b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107924:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010792b:	83 ca 40             	or     $0x40,%edx
8010792e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107937:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010793e:	83 ca 80             	or     $0xffffff80,%edx
80107941:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107951:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107954:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010795b:	ff ff 
8010795d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107960:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107967:	00 00 
80107969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796c:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107976:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010797d:	83 e2 f0             	and    $0xfffffff0,%edx
80107980:	83 ca 0a             	or     $0xa,%edx
80107983:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107993:	83 ca 10             	or     $0x10,%edx
80107996:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010799c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801079a6:	83 ca 60             	or     $0x60,%edx
801079a9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801079b9:	83 ca 80             	or     $0xffffff80,%edx
801079bc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079cc:	83 ca 0f             	or     $0xf,%edx
801079cf:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079df:	83 e2 ef             	and    $0xffffffef,%edx
801079e2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079eb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079f2:	83 e2 df             	and    $0xffffffdf,%edx
801079f5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fe:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a05:	83 ca 40             	or     $0x40,%edx
80107a08:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a11:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a18:	83 ca 80             	or     $0xffffff80,%edx
80107a1b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a24:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107a35:	ff ff 
80107a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107a41:	00 00 
80107a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a46:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a50:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a57:	83 e2 f0             	and    $0xfffffff0,%edx
80107a5a:	83 ca 02             	or     $0x2,%edx
80107a5d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a66:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a6d:	83 ca 10             	or     $0x10,%edx
80107a70:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a79:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a80:	83 ca 60             	or     $0x60,%edx
80107a83:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a93:	83 ca 80             	or     $0xffffff80,%edx
80107a96:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107aa6:	83 ca 0f             	or     $0xf,%edx
80107aa9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ab9:	83 e2 ef             	and    $0xffffffef,%edx
80107abc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107acc:	83 e2 df             	and    $0xffffffdf,%edx
80107acf:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107adf:	83 ca 40             	or     $0x40,%edx
80107ae2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aeb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107af2:	83 ca 80             	or     $0xffffff80,%edx
80107af5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afe:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b08:	83 c0 70             	add    $0x70,%eax
80107b0b:	83 ec 08             	sub    $0x8,%esp
80107b0e:	6a 30                	push   $0x30
80107b10:	50                   	push   %eax
80107b11:	e8 63 fc ff ff       	call   80107779 <lgdt>
80107b16:	83 c4 10             	add    $0x10,%esp
}
80107b19:	90                   	nop
80107b1a:	c9                   	leave  
80107b1b:	c3                   	ret    

80107b1c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107b1c:	55                   	push   %ebp
80107b1d:	89 e5                	mov    %esp,%ebp
80107b1f:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107b22:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b25:	c1 e8 16             	shr    $0x16,%eax
80107b28:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80107b32:	01 d0                	add    %edx,%eax
80107b34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b3a:	8b 00                	mov    (%eax),%eax
80107b3c:	83 e0 01             	and    $0x1,%eax
80107b3f:	85 c0                	test   %eax,%eax
80107b41:	74 14                	je     80107b57 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b46:	8b 00                	mov    (%eax),%eax
80107b48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b4d:	05 00 00 00 80       	add    $0x80000000,%eax
80107b52:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b55:	eb 42                	jmp    80107b99 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107b57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107b5b:	74 0e                	je     80107b6b <walkpgdir+0x4f>
80107b5d:	e8 26 ac ff ff       	call   80102788 <kalloc>
80107b62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b69:	75 07                	jne    80107b72 <walkpgdir+0x56>
      return 0;
80107b6b:	b8 00 00 00 00       	mov    $0x0,%eax
80107b70:	eb 3e                	jmp    80107bb0 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107b72:	83 ec 04             	sub    $0x4,%esp
80107b75:	68 00 10 00 00       	push   $0x1000
80107b7a:	6a 00                	push   $0x0
80107b7c:	ff 75 f4             	push   -0xc(%ebp)
80107b7f:	e8 ca d2 ff ff       	call   80104e4e <memset>
80107b84:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8a:	05 00 00 00 80       	add    $0x80000000,%eax
80107b8f:	83 c8 07             	or     $0x7,%eax
80107b92:	89 c2                	mov    %eax,%edx
80107b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b97:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107b99:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b9c:	c1 e8 0c             	shr    $0xc,%eax
80107b9f:	25 ff 03 00 00       	and    $0x3ff,%eax
80107ba4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bae:	01 d0                	add    %edx,%eax
}
80107bb0:	c9                   	leave  
80107bb1:	c3                   	ret    

80107bb2 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107bb2:	55                   	push   %ebp
80107bb3:	89 e5                	mov    %esp,%ebp
80107bb5:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bbb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107bc3:	8b 55 0c             	mov    0xc(%ebp),%edx
80107bc6:	8b 45 10             	mov    0x10(%ebp),%eax
80107bc9:	01 d0                	add    %edx,%eax
80107bcb:	83 e8 01             	sub    $0x1,%eax
80107bce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107bd6:	83 ec 04             	sub    $0x4,%esp
80107bd9:	6a 01                	push   $0x1
80107bdb:	ff 75 f4             	push   -0xc(%ebp)
80107bde:	ff 75 08             	push   0x8(%ebp)
80107be1:	e8 36 ff ff ff       	call   80107b1c <walkpgdir>
80107be6:	83 c4 10             	add    $0x10,%esp
80107be9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107bec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107bf0:	75 07                	jne    80107bf9 <mappages+0x47>
      return -1;
80107bf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bf7:	eb 47                	jmp    80107c40 <mappages+0x8e>
    if(*pte & PTE_P)
80107bf9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bfc:	8b 00                	mov    (%eax),%eax
80107bfe:	83 e0 01             	and    $0x1,%eax
80107c01:	85 c0                	test   %eax,%eax
80107c03:	74 0d                	je     80107c12 <mappages+0x60>
      panic("remap");
80107c05:	83 ec 0c             	sub    $0xc,%esp
80107c08:	68 28 b0 10 80       	push   $0x8010b028
80107c0d:	e8 97 89 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107c12:	8b 45 18             	mov    0x18(%ebp),%eax
80107c15:	0b 45 14             	or     0x14(%ebp),%eax
80107c18:	83 c8 01             	or     $0x1,%eax
80107c1b:	89 c2                	mov    %eax,%edx
80107c1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c20:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c25:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107c28:	74 10                	je     80107c3a <mappages+0x88>
      break;
    a += PGSIZE;
80107c2a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107c31:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107c38:	eb 9c                	jmp    80107bd6 <mappages+0x24>
      break;
80107c3a:	90                   	nop
  }
  return 0;
80107c3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c40:	c9                   	leave  
80107c41:	c3                   	ret    

80107c42 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107c42:	55                   	push   %ebp
80107c43:	89 e5                	mov    %esp,%ebp
80107c45:	53                   	push   %ebx
80107c46:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107c49:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107c50:	8b 15 60 e7 30 80    	mov    0x8030e760,%edx
80107c56:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107c5b:	29 d0                	sub    %edx,%eax
80107c5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107c60:	a1 58 e7 30 80       	mov    0x8030e758,%eax
80107c65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107c68:	8b 15 58 e7 30 80    	mov    0x8030e758,%edx
80107c6e:	a1 60 e7 30 80       	mov    0x8030e760,%eax
80107c73:	01 d0                	add    %edx,%eax
80107c75:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107c78:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c82:	83 c0 30             	add    $0x30,%eax
80107c85:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107c88:	89 10                	mov    %edx,(%eax)
80107c8a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107c8d:	89 50 04             	mov    %edx,0x4(%eax)
80107c90:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107c93:	89 50 08             	mov    %edx,0x8(%eax)
80107c96:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107c99:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107c9c:	e8 e7 aa ff ff       	call   80102788 <kalloc>
80107ca1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ca4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ca8:	75 07                	jne    80107cb1 <setupkvm+0x6f>
    return 0;
80107caa:	b8 00 00 00 00       	mov    $0x0,%eax
80107caf:	eb 78                	jmp    80107d29 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107cb1:	83 ec 04             	sub    $0x4,%esp
80107cb4:	68 00 10 00 00       	push   $0x1000
80107cb9:	6a 00                	push   $0x0
80107cbb:	ff 75 f0             	push   -0x10(%ebp)
80107cbe:	e8 8b d1 ff ff       	call   80104e4e <memset>
80107cc3:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107cc6:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107ccd:	eb 4e                	jmp    80107d1d <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd2:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd8:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cde:	8b 58 08             	mov    0x8(%eax),%ebx
80107ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce4:	8b 40 04             	mov    0x4(%eax),%eax
80107ce7:	29 c3                	sub    %eax,%ebx
80107ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cec:	8b 00                	mov    (%eax),%eax
80107cee:	83 ec 0c             	sub    $0xc,%esp
80107cf1:	51                   	push   %ecx
80107cf2:	52                   	push   %edx
80107cf3:	53                   	push   %ebx
80107cf4:	50                   	push   %eax
80107cf5:	ff 75 f0             	push   -0x10(%ebp)
80107cf8:	e8 b5 fe ff ff       	call   80107bb2 <mappages>
80107cfd:	83 c4 20             	add    $0x20,%esp
80107d00:	85 c0                	test   %eax,%eax
80107d02:	79 15                	jns    80107d19 <setupkvm+0xd7>
      freevm(pgdir);
80107d04:	83 ec 0c             	sub    $0xc,%esp
80107d07:	ff 75 f0             	push   -0x10(%ebp)
80107d0a:	e8 d6 04 00 00       	call   801081e5 <freevm>
80107d0f:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d12:	b8 00 00 00 00       	mov    $0x0,%eax
80107d17:	eb 10                	jmp    80107d29 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d19:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107d1d:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107d24:	72 a9                	jb     80107ccf <setupkvm+0x8d>
    }
  return pgdir;
80107d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107d29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107d2c:	c9                   	leave  
80107d2d:	c3                   	ret    

80107d2e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107d2e:	55                   	push   %ebp
80107d2f:	89 e5                	mov    %esp,%ebp
80107d31:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107d34:	e8 09 ff ff ff       	call   80107c42 <setupkvm>
80107d39:	a3 7c e4 30 80       	mov    %eax,0x8030e47c
  switchkvm();
80107d3e:	e8 03 00 00 00       	call   80107d46 <switchkvm>
}
80107d43:	90                   	nop
80107d44:	c9                   	leave  
80107d45:	c3                   	ret    

80107d46 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107d46:	55                   	push   %ebp
80107d47:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107d49:	a1 7c e4 30 80       	mov    0x8030e47c,%eax
80107d4e:	05 00 00 00 80       	add    $0x80000000,%eax
80107d53:	50                   	push   %eax
80107d54:	e8 61 fa ff ff       	call   801077ba <lcr3>
80107d59:	83 c4 04             	add    $0x4,%esp
}
80107d5c:	90                   	nop
80107d5d:	c9                   	leave  
80107d5e:	c3                   	ret    

80107d5f <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107d5f:	55                   	push   %ebp
80107d60:	89 e5                	mov    %esp,%ebp
80107d62:	56                   	push   %esi
80107d63:	53                   	push   %ebx
80107d64:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107d67:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107d6b:	75 0d                	jne    80107d7a <switchuvm+0x1b>
    panic("switchuvm: no process");
80107d6d:	83 ec 0c             	sub    $0xc,%esp
80107d70:	68 2e b0 10 80       	push   $0x8010b02e
80107d75:	e8 2f 88 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80107d7d:	8b 40 08             	mov    0x8(%eax),%eax
80107d80:	85 c0                	test   %eax,%eax
80107d82:	75 0d                	jne    80107d91 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107d84:	83 ec 0c             	sub    $0xc,%esp
80107d87:	68 44 b0 10 80       	push   $0x8010b044
80107d8c:	e8 18 88 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107d91:	8b 45 08             	mov    0x8(%ebp),%eax
80107d94:	8b 40 04             	mov    0x4(%eax),%eax
80107d97:	85 c0                	test   %eax,%eax
80107d99:	75 0d                	jne    80107da8 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107d9b:	83 ec 0c             	sub    $0xc,%esp
80107d9e:	68 59 b0 10 80       	push   $0x8010b059
80107da3:	e8 01 88 ff ff       	call   801005a9 <panic>

  pushcli();
80107da8:	e8 96 cf ff ff       	call   80104d43 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107dad:	e8 ee bb ff ff       	call   801039a0 <mycpu>
80107db2:	89 c3                	mov    %eax,%ebx
80107db4:	e8 e7 bb ff ff       	call   801039a0 <mycpu>
80107db9:	83 c0 08             	add    $0x8,%eax
80107dbc:	89 c6                	mov    %eax,%esi
80107dbe:	e8 dd bb ff ff       	call   801039a0 <mycpu>
80107dc3:	83 c0 08             	add    $0x8,%eax
80107dc6:	c1 e8 10             	shr    $0x10,%eax
80107dc9:	88 45 f7             	mov    %al,-0x9(%ebp)
80107dcc:	e8 cf bb ff ff       	call   801039a0 <mycpu>
80107dd1:	83 c0 08             	add    $0x8,%eax
80107dd4:	c1 e8 18             	shr    $0x18,%eax
80107dd7:	89 c2                	mov    %eax,%edx
80107dd9:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107de0:	67 00 
80107de2:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107de9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107ded:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107df3:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107dfa:	83 e0 f0             	and    $0xfffffff0,%eax
80107dfd:	83 c8 09             	or     $0x9,%eax
80107e00:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e06:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e0d:	83 c8 10             	or     $0x10,%eax
80107e10:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e16:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e1d:	83 e0 9f             	and    $0xffffff9f,%eax
80107e20:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e26:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e2d:	83 c8 80             	or     $0xffffff80,%eax
80107e30:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e36:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e3d:	83 e0 f0             	and    $0xfffffff0,%eax
80107e40:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e46:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e4d:	83 e0 ef             	and    $0xffffffef,%eax
80107e50:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e56:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e5d:	83 e0 df             	and    $0xffffffdf,%eax
80107e60:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e66:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e6d:	83 c8 40             	or     $0x40,%eax
80107e70:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e76:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e7d:	83 e0 7f             	and    $0x7f,%eax
80107e80:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e86:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107e8c:	e8 0f bb ff ff       	call   801039a0 <mycpu>
80107e91:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107e98:	83 e2 ef             	and    $0xffffffef,%edx
80107e9b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107ea1:	e8 fa ba ff ff       	call   801039a0 <mycpu>
80107ea6:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107eac:	8b 45 08             	mov    0x8(%ebp),%eax
80107eaf:	8b 40 08             	mov    0x8(%eax),%eax
80107eb2:	89 c3                	mov    %eax,%ebx
80107eb4:	e8 e7 ba ff ff       	call   801039a0 <mycpu>
80107eb9:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107ebf:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107ec2:	e8 d9 ba ff ff       	call   801039a0 <mycpu>
80107ec7:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107ecd:	83 ec 0c             	sub    $0xc,%esp
80107ed0:	6a 28                	push   $0x28
80107ed2:	e8 cc f8 ff ff       	call   801077a3 <ltr>
80107ed7:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107eda:	8b 45 08             	mov    0x8(%ebp),%eax
80107edd:	8b 40 04             	mov    0x4(%eax),%eax
80107ee0:	05 00 00 00 80       	add    $0x80000000,%eax
80107ee5:	83 ec 0c             	sub    $0xc,%esp
80107ee8:	50                   	push   %eax
80107ee9:	e8 cc f8 ff ff       	call   801077ba <lcr3>
80107eee:	83 c4 10             	add    $0x10,%esp
  popcli();
80107ef1:	e8 9a ce ff ff       	call   80104d90 <popcli>
}
80107ef6:	90                   	nop
80107ef7:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107efa:	5b                   	pop    %ebx
80107efb:	5e                   	pop    %esi
80107efc:	5d                   	pop    %ebp
80107efd:	c3                   	ret    

80107efe <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107efe:	55                   	push   %ebp
80107eff:	89 e5                	mov    %esp,%ebp
80107f01:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107f04:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107f0b:	76 0d                	jbe    80107f1a <inituvm+0x1c>
    panic("inituvm: more than a page");
80107f0d:	83 ec 0c             	sub    $0xc,%esp
80107f10:	68 6d b0 10 80       	push   $0x8010b06d
80107f15:	e8 8f 86 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107f1a:	e8 69 a8 ff ff       	call   80102788 <kalloc>
80107f1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107f22:	83 ec 04             	sub    $0x4,%esp
80107f25:	68 00 10 00 00       	push   $0x1000
80107f2a:	6a 00                	push   $0x0
80107f2c:	ff 75 f4             	push   -0xc(%ebp)
80107f2f:	e8 1a cf ff ff       	call   80104e4e <memset>
80107f34:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3a:	05 00 00 00 80       	add    $0x80000000,%eax
80107f3f:	83 ec 0c             	sub    $0xc,%esp
80107f42:	6a 06                	push   $0x6
80107f44:	50                   	push   %eax
80107f45:	68 00 10 00 00       	push   $0x1000
80107f4a:	6a 00                	push   $0x0
80107f4c:	ff 75 08             	push   0x8(%ebp)
80107f4f:	e8 5e fc ff ff       	call   80107bb2 <mappages>
80107f54:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107f57:	83 ec 04             	sub    $0x4,%esp
80107f5a:	ff 75 10             	push   0x10(%ebp)
80107f5d:	ff 75 0c             	push   0xc(%ebp)
80107f60:	ff 75 f4             	push   -0xc(%ebp)
80107f63:	e8 a5 cf ff ff       	call   80104f0d <memmove>
80107f68:	83 c4 10             	add    $0x10,%esp
}
80107f6b:	90                   	nop
80107f6c:	c9                   	leave  
80107f6d:	c3                   	ret    

80107f6e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107f6e:	55                   	push   %ebp
80107f6f:	89 e5                	mov    %esp,%ebp
80107f71:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107f74:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f77:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f7c:	85 c0                	test   %eax,%eax
80107f7e:	74 0d                	je     80107f8d <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107f80:	83 ec 0c             	sub    $0xc,%esp
80107f83:	68 88 b0 10 80       	push   $0x8010b088
80107f88:	e8 1c 86 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107f8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f94:	e9 8f 00 00 00       	jmp    80108028 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107f99:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9f:	01 d0                	add    %edx,%eax
80107fa1:	83 ec 04             	sub    $0x4,%esp
80107fa4:	6a 00                	push   $0x0
80107fa6:	50                   	push   %eax
80107fa7:	ff 75 08             	push   0x8(%ebp)
80107faa:	e8 6d fb ff ff       	call   80107b1c <walkpgdir>
80107faf:	83 c4 10             	add    $0x10,%esp
80107fb2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fb5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fb9:	75 0d                	jne    80107fc8 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107fbb:	83 ec 0c             	sub    $0xc,%esp
80107fbe:	68 ab b0 10 80       	push   $0x8010b0ab
80107fc3:	e8 e1 85 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107fc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fcb:	8b 00                	mov    (%eax),%eax
80107fcd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fd2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107fd5:	8b 45 18             	mov    0x18(%ebp),%eax
80107fd8:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107fdb:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107fe0:	77 0b                	ja     80107fed <loaduvm+0x7f>
      n = sz - i;
80107fe2:	8b 45 18             	mov    0x18(%ebp),%eax
80107fe5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107fe8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107feb:	eb 07                	jmp    80107ff4 <loaduvm+0x86>
    else
      n = PGSIZE;
80107fed:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107ff4:	8b 55 14             	mov    0x14(%ebp),%edx
80107ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffa:	01 d0                	add    %edx,%eax
80107ffc:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107fff:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108005:	ff 75 f0             	push   -0x10(%ebp)
80108008:	50                   	push   %eax
80108009:	52                   	push   %edx
8010800a:	ff 75 10             	push   0x10(%ebp)
8010800d:	e8 ac 9e ff ff       	call   80101ebe <readi>
80108012:	83 c4 10             	add    $0x10,%esp
80108015:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108018:	74 07                	je     80108021 <loaduvm+0xb3>
      return -1;
8010801a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010801f:	eb 18                	jmp    80108039 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80108021:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802b:	3b 45 18             	cmp    0x18(%ebp),%eax
8010802e:	0f 82 65 ff ff ff    	jb     80107f99 <loaduvm+0x2b>
  }
  return 0;
80108034:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108039:	c9                   	leave  
8010803a:	c3                   	ret    

8010803b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010803b:	55                   	push   %ebp
8010803c:	89 e5                	mov    %esp,%ebp
8010803e:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108041:	8b 45 10             	mov    0x10(%ebp),%eax
80108044:	85 c0                	test   %eax,%eax
80108046:	79 0a                	jns    80108052 <allocuvm+0x17>
    return 0;
80108048:	b8 00 00 00 00       	mov    $0x0,%eax
8010804d:	e9 ec 00 00 00       	jmp    8010813e <allocuvm+0x103>
  if(newsz < oldsz)
80108052:	8b 45 10             	mov    0x10(%ebp),%eax
80108055:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108058:	73 08                	jae    80108062 <allocuvm+0x27>
    return oldsz;
8010805a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010805d:	e9 dc 00 00 00       	jmp    8010813e <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80108062:	8b 45 0c             	mov    0xc(%ebp),%eax
80108065:	05 ff 0f 00 00       	add    $0xfff,%eax
8010806a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010806f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108072:	e9 b8 00 00 00       	jmp    8010812f <allocuvm+0xf4>
    mem = kalloc();
80108077:	e8 0c a7 ff ff       	call   80102788 <kalloc>
8010807c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010807f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108083:	75 2e                	jne    801080b3 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80108085:	83 ec 0c             	sub    $0xc,%esp
80108088:	68 c9 b0 10 80       	push   $0x8010b0c9
8010808d:	e8 62 83 ff ff       	call   801003f4 <cprintf>
80108092:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108095:	83 ec 04             	sub    $0x4,%esp
80108098:	ff 75 0c             	push   0xc(%ebp)
8010809b:	ff 75 10             	push   0x10(%ebp)
8010809e:	ff 75 08             	push   0x8(%ebp)
801080a1:	e8 9a 00 00 00       	call   80108140 <deallocuvm>
801080a6:	83 c4 10             	add    $0x10,%esp
      return 0;
801080a9:	b8 00 00 00 00       	mov    $0x0,%eax
801080ae:	e9 8b 00 00 00       	jmp    8010813e <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
801080b3:	83 ec 04             	sub    $0x4,%esp
801080b6:	68 00 10 00 00       	push   $0x1000
801080bb:	6a 00                	push   $0x0
801080bd:	ff 75 f0             	push   -0x10(%ebp)
801080c0:	e8 89 cd ff ff       	call   80104e4e <memset>
801080c5:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801080c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080cb:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801080d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d4:	83 ec 0c             	sub    $0xc,%esp
801080d7:	6a 06                	push   $0x6
801080d9:	52                   	push   %edx
801080da:	68 00 10 00 00       	push   $0x1000
801080df:	50                   	push   %eax
801080e0:	ff 75 08             	push   0x8(%ebp)
801080e3:	e8 ca fa ff ff       	call   80107bb2 <mappages>
801080e8:	83 c4 20             	add    $0x20,%esp
801080eb:	85 c0                	test   %eax,%eax
801080ed:	79 39                	jns    80108128 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801080ef:	83 ec 0c             	sub    $0xc,%esp
801080f2:	68 e1 b0 10 80       	push   $0x8010b0e1
801080f7:	e8 f8 82 ff ff       	call   801003f4 <cprintf>
801080fc:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801080ff:	83 ec 04             	sub    $0x4,%esp
80108102:	ff 75 0c             	push   0xc(%ebp)
80108105:	ff 75 10             	push   0x10(%ebp)
80108108:	ff 75 08             	push   0x8(%ebp)
8010810b:	e8 30 00 00 00       	call   80108140 <deallocuvm>
80108110:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108113:	83 ec 0c             	sub    $0xc,%esp
80108116:	ff 75 f0             	push   -0x10(%ebp)
80108119:	e8 d0 a5 ff ff       	call   801026ee <kfree>
8010811e:	83 c4 10             	add    $0x10,%esp
      return 0;
80108121:	b8 00 00 00 00       	mov    $0x0,%eax
80108126:	eb 16                	jmp    8010813e <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80108128:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010812f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108132:	3b 45 10             	cmp    0x10(%ebp),%eax
80108135:	0f 82 3c ff ff ff    	jb     80108077 <allocuvm+0x3c>
    }
  }
  return newsz;
8010813b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010813e:	c9                   	leave  
8010813f:	c3                   	ret    

80108140 <deallocuvm>:
//   return newsz;
// }

int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108140:	55                   	push   %ebp
80108141:	89 e5                	mov    %esp,%ebp
80108143:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108146:	8b 45 10             	mov    0x10(%ebp),%eax
80108149:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010814c:	72 08                	jb     80108156 <deallocuvm+0x16>
    return oldsz;
8010814e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108151:	e9 8d 00 00 00       	jmp    801081e3 <deallocuvm+0xa3>

  a = PGROUNDDOWN(newsz); // 0이면 0에서 시작!
80108156:	8b 45 10             	mov    0x10(%ebp),%eax
80108159:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010815e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < oldsz; a += PGSIZE){
80108161:	eb 75                	jmp    801081d8 <deallocuvm+0x98>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108166:	83 ec 04             	sub    $0x4,%esp
80108169:	6a 00                	push   $0x0
8010816b:	50                   	push   %eax
8010816c:	ff 75 08             	push   0x8(%ebp)
8010816f:	e8 a8 f9 ff ff       	call   80107b1c <walkpgdir>
80108174:	83 c4 10             	add    $0x10,%esp
80108177:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 기존: if(!pte) a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
    // 수정: 무조건 4KB 단위로 꼼꼼히 돌기!
    if(!pte)
8010817a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010817e:	74 50                	je     801081d0 <deallocuvm+0x90>
      continue; // 4KB 단위로 반드시 다 체크
    if((*pte & PTE_P) != 0){
80108180:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108183:	8b 00                	mov    (%eax),%eax
80108185:	83 e0 01             	and    $0x1,%eax
80108188:	85 c0                	test   %eax,%eax
8010818a:	74 45                	je     801081d1 <deallocuvm+0x91>
      pa = PTE_ADDR(*pte);
8010818c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010818f:	8b 00                	mov    (%eax),%eax
80108191:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108196:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108199:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010819d:	75 0d                	jne    801081ac <deallocuvm+0x6c>
        panic("kfree");
8010819f:	83 ec 0c             	sub    $0xc,%esp
801081a2:	68 fd b0 10 80       	push   $0x8010b0fd
801081a7:	e8 fd 83 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
801081ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081af:	05 00 00 00 80       	add    $0x80000000,%eax
801081b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801081b7:	83 ec 0c             	sub    $0xc,%esp
801081ba:	ff 75 e8             	push   -0x18(%ebp)
801081bd:	e8 2c a5 ff ff       	call   801026ee <kfree>
801081c2:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801081c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801081ce:	eb 01                	jmp    801081d1 <deallocuvm+0x91>
      continue; // 4KB 단위로 반드시 다 체크
801081d0:	90                   	nop
  for(; a < oldsz; a += PGSIZE){
801081d1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081db:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081de:	72 83                	jb     80108163 <deallocuvm+0x23>
    }
  }
  return newsz;
801081e0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801081e3:	c9                   	leave  
801081e4:	c3                   	ret    

801081e5 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801081e5:	55                   	push   %ebp
801081e6:	89 e5                	mov    %esp,%ebp
801081e8:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801081eb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801081ef:	75 0d                	jne    801081fe <freevm+0x19>
    panic("freevm: no pgdir");
801081f1:	83 ec 0c             	sub    $0xc,%esp
801081f4:	68 03 b1 10 80       	push   $0x8010b103
801081f9:	e8 ab 83 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801081fe:	83 ec 04             	sub    $0x4,%esp
80108201:	6a 00                	push   $0x0
80108203:	68 00 00 00 80       	push   $0x80000000
80108208:	ff 75 08             	push   0x8(%ebp)
8010820b:	e8 30 ff ff ff       	call   80108140 <deallocuvm>
80108210:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108213:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010821a:	eb 48                	jmp    80108264 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
8010821c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108226:	8b 45 08             	mov    0x8(%ebp),%eax
80108229:	01 d0                	add    %edx,%eax
8010822b:	8b 00                	mov    (%eax),%eax
8010822d:	83 e0 01             	and    $0x1,%eax
80108230:	85 c0                	test   %eax,%eax
80108232:	74 2c                	je     80108260 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108237:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010823e:	8b 45 08             	mov    0x8(%ebp),%eax
80108241:	01 d0                	add    %edx,%eax
80108243:	8b 00                	mov    (%eax),%eax
80108245:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010824a:	05 00 00 00 80       	add    $0x80000000,%eax
8010824f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108252:	83 ec 0c             	sub    $0xc,%esp
80108255:	ff 75 f0             	push   -0x10(%ebp)
80108258:	e8 91 a4 ff ff       	call   801026ee <kfree>
8010825d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108260:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108264:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010826b:	76 af                	jbe    8010821c <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010826d:	83 ec 0c             	sub    $0xc,%esp
80108270:	ff 75 08             	push   0x8(%ebp)
80108273:	e8 76 a4 ff ff       	call   801026ee <kfree>
80108278:	83 c4 10             	add    $0x10,%esp
}
8010827b:	90                   	nop
8010827c:	c9                   	leave  
8010827d:	c3                   	ret    

8010827e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010827e:	55                   	push   %ebp
8010827f:	89 e5                	mov    %esp,%ebp
80108281:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108284:	83 ec 04             	sub    $0x4,%esp
80108287:	6a 00                	push   $0x0
80108289:	ff 75 0c             	push   0xc(%ebp)
8010828c:	ff 75 08             	push   0x8(%ebp)
8010828f:	e8 88 f8 ff ff       	call   80107b1c <walkpgdir>
80108294:	83 c4 10             	add    $0x10,%esp
80108297:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010829a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010829e:	75 0d                	jne    801082ad <clearpteu+0x2f>
    panic("clearpteu");
801082a0:	83 ec 0c             	sub    $0xc,%esp
801082a3:	68 14 b1 10 80       	push   $0x8010b114
801082a8:	e8 fc 82 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
801082ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b0:	8b 00                	mov    (%eax),%eax
801082b2:	83 e0 fb             	and    $0xfffffffb,%eax
801082b5:	89 c2                	mov    %eax,%edx
801082b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ba:	89 10                	mov    %edx,(%eax)
}
801082bc:	90                   	nop
801082bd:	c9                   	leave  
801082be:	c3                   	ret    

801082bf <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801082bf:	55                   	push   %ebp
801082c0:	89 e5                	mov    %esp,%ebp
801082c2:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801082c5:	e8 78 f9 ff ff       	call   80107c42 <setupkvm>
801082ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
801082cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082d1:	75 0a                	jne    801082dd <copyuvm+0x1e>
    return 0;
801082d3:	b8 00 00 00 00       	mov    $0x0,%eax
801082d8:	e9 d6 00 00 00       	jmp    801083b3 <copyuvm+0xf4>
  for(i = 0; i < /*sp*/KERNBASE; i += PGSIZE){
801082dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082e4:	e9 a3 00 00 00       	jmp    8010838c <copyuvm+0xcd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801082e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ec:	83 ec 04             	sub    $0x4,%esp
801082ef:	6a 00                	push   $0x0
801082f1:	50                   	push   %eax
801082f2:	ff 75 08             	push   0x8(%ebp)
801082f5:	e8 22 f8 ff ff       	call   80107b1c <walkpgdir>
801082fa:	83 c4 10             	add    $0x10,%esp
801082fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108300:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108304:	74 7b                	je     80108381 <copyuvm+0xc2>
      //panic("copyuvm: pte should exist");
      continue;
    if(!(*pte & PTE_P))
80108306:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108309:	8b 00                	mov    (%eax),%eax
8010830b:	83 e0 01             	and    $0x1,%eax
8010830e:	85 c0                	test   %eax,%eax
80108310:	74 72                	je     80108384 <copyuvm+0xc5>
      //panic("copyuvm: page not present");
      continue;
    pa = PTE_ADDR(*pte);
80108312:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108315:	8b 00                	mov    (%eax),%eax
80108317:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010831c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010831f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108322:	8b 00                	mov    (%eax),%eax
80108324:	25 ff 0f 00 00       	and    $0xfff,%eax
80108329:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010832c:	e8 57 a4 ff ff       	call   80102788 <kalloc>
80108331:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108334:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108338:	74 62                	je     8010839c <copyuvm+0xdd>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010833a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010833d:	05 00 00 00 80       	add    $0x80000000,%eax
80108342:	83 ec 04             	sub    $0x4,%esp
80108345:	68 00 10 00 00       	push   $0x1000
8010834a:	50                   	push   %eax
8010834b:	ff 75 e0             	push   -0x20(%ebp)
8010834e:	e8 ba cb ff ff       	call   80104f0d <memmove>
80108353:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108356:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108359:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010835c:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108365:	83 ec 0c             	sub    $0xc,%esp
80108368:	52                   	push   %edx
80108369:	51                   	push   %ecx
8010836a:	68 00 10 00 00       	push   $0x1000
8010836f:	50                   	push   %eax
80108370:	ff 75 f0             	push   -0x10(%ebp)
80108373:	e8 3a f8 ff ff       	call   80107bb2 <mappages>
80108378:	83 c4 20             	add    $0x20,%esp
8010837b:	85 c0                	test   %eax,%eax
8010837d:	78 20                	js     8010839f <copyuvm+0xe0>
8010837f:	eb 04                	jmp    80108385 <copyuvm+0xc6>
      continue;
80108381:	90                   	nop
80108382:	eb 01                	jmp    80108385 <copyuvm+0xc6>
      continue;
80108384:	90                   	nop
  for(i = 0; i < /*sp*/KERNBASE; i += PGSIZE){
80108385:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010838c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838f:	85 c0                	test   %eax,%eax
80108391:	0f 89 52 ff ff ff    	jns    801082e9 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80108397:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010839a:	eb 17                	jmp    801083b3 <copyuvm+0xf4>
      goto bad;
8010839c:	90                   	nop
8010839d:	eb 01                	jmp    801083a0 <copyuvm+0xe1>
      goto bad;
8010839f:	90                   	nop

bad:
  freevm(d);
801083a0:	83 ec 0c             	sub    $0xc,%esp
801083a3:	ff 75 f0             	push   -0x10(%ebp)
801083a6:	e8 3a fe ff ff       	call   801081e5 <freevm>
801083ab:	83 c4 10             	add    $0x10,%esp
  return 0;
801083ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083b3:	c9                   	leave  
801083b4:	c3                   	ret    

801083b5 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801083b5:	55                   	push   %ebp
801083b6:	89 e5                	mov    %esp,%ebp
801083b8:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801083bb:	83 ec 04             	sub    $0x4,%esp
801083be:	6a 00                	push   $0x0
801083c0:	ff 75 0c             	push   0xc(%ebp)
801083c3:	ff 75 08             	push   0x8(%ebp)
801083c6:	e8 51 f7 ff ff       	call   80107b1c <walkpgdir>
801083cb:	83 c4 10             	add    $0x10,%esp
801083ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801083d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d4:	8b 00                	mov    (%eax),%eax
801083d6:	83 e0 01             	and    $0x1,%eax
801083d9:	85 c0                	test   %eax,%eax
801083db:	75 07                	jne    801083e4 <uva2ka+0x2f>
    return 0;
801083dd:	b8 00 00 00 00       	mov    $0x0,%eax
801083e2:	eb 22                	jmp    80108406 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
801083e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e7:	8b 00                	mov    (%eax),%eax
801083e9:	83 e0 04             	and    $0x4,%eax
801083ec:	85 c0                	test   %eax,%eax
801083ee:	75 07                	jne    801083f7 <uva2ka+0x42>
    return 0;
801083f0:	b8 00 00 00 00       	mov    $0x0,%eax
801083f5:	eb 0f                	jmp    80108406 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
801083f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fa:	8b 00                	mov    (%eax),%eax
801083fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108401:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108406:	c9                   	leave  
80108407:	c3                   	ret    

80108408 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108408:	55                   	push   %ebp
80108409:	89 e5                	mov    %esp,%ebp
8010840b:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010840e:	8b 45 10             	mov    0x10(%ebp),%eax
80108411:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108414:	eb 7f                	jmp    80108495 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108416:	8b 45 0c             	mov    0xc(%ebp),%eax
80108419:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010841e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108421:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108424:	83 ec 08             	sub    $0x8,%esp
80108427:	50                   	push   %eax
80108428:	ff 75 08             	push   0x8(%ebp)
8010842b:	e8 85 ff ff ff       	call   801083b5 <uva2ka>
80108430:	83 c4 10             	add    $0x10,%esp
80108433:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108436:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010843a:	75 07                	jne    80108443 <copyout+0x3b>
      return -1;
8010843c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108441:	eb 61                	jmp    801084a4 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108443:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108446:	2b 45 0c             	sub    0xc(%ebp),%eax
80108449:	05 00 10 00 00       	add    $0x1000,%eax
8010844e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108451:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108454:	3b 45 14             	cmp    0x14(%ebp),%eax
80108457:	76 06                	jbe    8010845f <copyout+0x57>
      n = len;
80108459:	8b 45 14             	mov    0x14(%ebp),%eax
8010845c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010845f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108462:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108465:	89 c2                	mov    %eax,%edx
80108467:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010846a:	01 d0                	add    %edx,%eax
8010846c:	83 ec 04             	sub    $0x4,%esp
8010846f:	ff 75 f0             	push   -0x10(%ebp)
80108472:	ff 75 f4             	push   -0xc(%ebp)
80108475:	50                   	push   %eax
80108476:	e8 92 ca ff ff       	call   80104f0d <memmove>
8010847b:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010847e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108481:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108484:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108487:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010848a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010848d:	05 00 10 00 00       	add    $0x1000,%eax
80108492:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108495:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108499:	0f 85 77 ff ff ff    	jne    80108416 <copyout+0xe>
  }
  return 0;
8010849f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084a4:	c9                   	leave  
801084a5:	c3                   	ret    

801084a6 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801084a6:	55                   	push   %ebp
801084a7:	89 e5                	mov    %esp,%ebp
801084a9:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801084ac:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801084b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801084b6:	8b 40 08             	mov    0x8(%eax),%eax
801084b9:	05 00 00 00 80       	add    $0x80000000,%eax
801084be:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801084c1:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801084c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cb:	8b 40 24             	mov    0x24(%eax),%eax
801084ce:	a3 00 b1 30 80       	mov    %eax,0x8030b100
  ncpu = 0;
801084d3:	c7 05 50 e7 30 80 00 	movl   $0x0,0x8030e750
801084da:	00 00 00 

  while(i<madt->len){
801084dd:	90                   	nop
801084de:	e9 bd 00 00 00       	jmp    801085a0 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
801084e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084e9:	01 d0                	add    %edx,%eax
801084eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801084ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084f1:	0f b6 00             	movzbl (%eax),%eax
801084f4:	0f b6 c0             	movzbl %al,%eax
801084f7:	83 f8 05             	cmp    $0x5,%eax
801084fa:	0f 87 a0 00 00 00    	ja     801085a0 <mpinit_uefi+0xfa>
80108500:	8b 04 85 20 b1 10 80 	mov    -0x7fef4ee0(,%eax,4),%eax
80108507:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010850c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
8010850f:	a1 50 e7 30 80       	mov    0x8030e750,%eax
80108514:	83 f8 03             	cmp    $0x3,%eax
80108517:	7f 28                	jg     80108541 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108519:	8b 15 50 e7 30 80    	mov    0x8030e750,%edx
8010851f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108522:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108526:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
8010852c:	81 c2 80 e4 30 80    	add    $0x8030e480,%edx
80108532:	88 02                	mov    %al,(%edx)
          ncpu++;
80108534:	a1 50 e7 30 80       	mov    0x8030e750,%eax
80108539:	83 c0 01             	add    $0x1,%eax
8010853c:	a3 50 e7 30 80       	mov    %eax,0x8030e750
        }
        i += lapic_entry->record_len;
80108541:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108544:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108548:	0f b6 c0             	movzbl %al,%eax
8010854b:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010854e:	eb 50                	jmp    801085a0 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108550:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108553:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108556:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108559:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010855d:	a2 54 e7 30 80       	mov    %al,0x8030e754
        i += ioapic->record_len;
80108562:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108565:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108569:	0f b6 c0             	movzbl %al,%eax
8010856c:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010856f:	eb 2f                	jmp    801085a0 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108571:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108574:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108577:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010857a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010857e:	0f b6 c0             	movzbl %al,%eax
80108581:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108584:	eb 1a                	jmp    801085a0 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108586:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108589:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
8010858c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010858f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108593:	0f b6 c0             	movzbl %al,%eax
80108596:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108599:	eb 05                	jmp    801085a0 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
8010859b:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010859f:	90                   	nop
  while(i<madt->len){
801085a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a3:	8b 40 04             	mov    0x4(%eax),%eax
801085a6:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801085a9:	0f 82 34 ff ff ff    	jb     801084e3 <mpinit_uefi+0x3d>
    }
  }

}
801085af:	90                   	nop
801085b0:	90                   	nop
801085b1:	c9                   	leave  
801085b2:	c3                   	ret    

801085b3 <inb>:
{
801085b3:	55                   	push   %ebp
801085b4:	89 e5                	mov    %esp,%ebp
801085b6:	83 ec 14             	sub    $0x14,%esp
801085b9:	8b 45 08             	mov    0x8(%ebp),%eax
801085bc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801085c0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801085c4:	89 c2                	mov    %eax,%edx
801085c6:	ec                   	in     (%dx),%al
801085c7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801085ca:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801085ce:	c9                   	leave  
801085cf:	c3                   	ret    

801085d0 <outb>:
{
801085d0:	55                   	push   %ebp
801085d1:	89 e5                	mov    %esp,%ebp
801085d3:	83 ec 08             	sub    $0x8,%esp
801085d6:	8b 45 08             	mov    0x8(%ebp),%eax
801085d9:	8b 55 0c             	mov    0xc(%ebp),%edx
801085dc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801085e0:	89 d0                	mov    %edx,%eax
801085e2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801085e5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801085e9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801085ed:	ee                   	out    %al,(%dx)
}
801085ee:	90                   	nop
801085ef:	c9                   	leave  
801085f0:	c3                   	ret    

801085f1 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801085f1:	55                   	push   %ebp
801085f2:	89 e5                	mov    %esp,%ebp
801085f4:	83 ec 28             	sub    $0x28,%esp
801085f7:	8b 45 08             	mov    0x8(%ebp),%eax
801085fa:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801085fd:	6a 00                	push   $0x0
801085ff:	68 fa 03 00 00       	push   $0x3fa
80108604:	e8 c7 ff ff ff       	call   801085d0 <outb>
80108609:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010860c:	68 80 00 00 00       	push   $0x80
80108611:	68 fb 03 00 00       	push   $0x3fb
80108616:	e8 b5 ff ff ff       	call   801085d0 <outb>
8010861b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010861e:	6a 0c                	push   $0xc
80108620:	68 f8 03 00 00       	push   $0x3f8
80108625:	e8 a6 ff ff ff       	call   801085d0 <outb>
8010862a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010862d:	6a 00                	push   $0x0
8010862f:	68 f9 03 00 00       	push   $0x3f9
80108634:	e8 97 ff ff ff       	call   801085d0 <outb>
80108639:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010863c:	6a 03                	push   $0x3
8010863e:	68 fb 03 00 00       	push   $0x3fb
80108643:	e8 88 ff ff ff       	call   801085d0 <outb>
80108648:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010864b:	6a 00                	push   $0x0
8010864d:	68 fc 03 00 00       	push   $0x3fc
80108652:	e8 79 ff ff ff       	call   801085d0 <outb>
80108657:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010865a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108661:	eb 11                	jmp    80108674 <uart_debug+0x83>
80108663:	83 ec 0c             	sub    $0xc,%esp
80108666:	6a 0a                	push   $0xa
80108668:	e8 b2 a4 ff ff       	call   80102b1f <microdelay>
8010866d:	83 c4 10             	add    $0x10,%esp
80108670:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108674:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108678:	7f 1a                	jg     80108694 <uart_debug+0xa3>
8010867a:	83 ec 0c             	sub    $0xc,%esp
8010867d:	68 fd 03 00 00       	push   $0x3fd
80108682:	e8 2c ff ff ff       	call   801085b3 <inb>
80108687:	83 c4 10             	add    $0x10,%esp
8010868a:	0f b6 c0             	movzbl %al,%eax
8010868d:	83 e0 20             	and    $0x20,%eax
80108690:	85 c0                	test   %eax,%eax
80108692:	74 cf                	je     80108663 <uart_debug+0x72>
  outb(COM1+0, p);
80108694:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108698:	0f b6 c0             	movzbl %al,%eax
8010869b:	83 ec 08             	sub    $0x8,%esp
8010869e:	50                   	push   %eax
8010869f:	68 f8 03 00 00       	push   $0x3f8
801086a4:	e8 27 ff ff ff       	call   801085d0 <outb>
801086a9:	83 c4 10             	add    $0x10,%esp
}
801086ac:	90                   	nop
801086ad:	c9                   	leave  
801086ae:	c3                   	ret    

801086af <uart_debugs>:

void uart_debugs(char *p){
801086af:	55                   	push   %ebp
801086b0:	89 e5                	mov    %esp,%ebp
801086b2:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801086b5:	eb 1b                	jmp    801086d2 <uart_debugs+0x23>
    uart_debug(*p++);
801086b7:	8b 45 08             	mov    0x8(%ebp),%eax
801086ba:	8d 50 01             	lea    0x1(%eax),%edx
801086bd:	89 55 08             	mov    %edx,0x8(%ebp)
801086c0:	0f b6 00             	movzbl (%eax),%eax
801086c3:	0f be c0             	movsbl %al,%eax
801086c6:	83 ec 0c             	sub    $0xc,%esp
801086c9:	50                   	push   %eax
801086ca:	e8 22 ff ff ff       	call   801085f1 <uart_debug>
801086cf:	83 c4 10             	add    $0x10,%esp
  while(*p){
801086d2:	8b 45 08             	mov    0x8(%ebp),%eax
801086d5:	0f b6 00             	movzbl (%eax),%eax
801086d8:	84 c0                	test   %al,%al
801086da:	75 db                	jne    801086b7 <uart_debugs+0x8>
  }
}
801086dc:	90                   	nop
801086dd:	90                   	nop
801086de:	c9                   	leave  
801086df:	c3                   	ret    

801086e0 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801086e0:	55                   	push   %ebp
801086e1:	89 e5                	mov    %esp,%ebp
801086e3:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801086e6:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801086ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086f0:	8b 50 14             	mov    0x14(%eax),%edx
801086f3:	8b 40 10             	mov    0x10(%eax),%eax
801086f6:	a3 58 e7 30 80       	mov    %eax,0x8030e758
  gpu.vram_size = boot_param->graphic_config.frame_size;
801086fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086fe:	8b 50 1c             	mov    0x1c(%eax),%edx
80108701:	8b 40 18             	mov    0x18(%eax),%eax
80108704:	a3 60 e7 30 80       	mov    %eax,0x8030e760
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108709:	8b 15 60 e7 30 80    	mov    0x8030e760,%edx
8010870f:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80108714:	29 d0                	sub    %edx,%eax
80108716:	a3 5c e7 30 80       	mov    %eax,0x8030e75c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010871b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010871e:	8b 50 24             	mov    0x24(%eax),%edx
80108721:	8b 40 20             	mov    0x20(%eax),%eax
80108724:	a3 64 e7 30 80       	mov    %eax,0x8030e764
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108729:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010872c:	8b 50 2c             	mov    0x2c(%eax),%edx
8010872f:	8b 40 28             	mov    0x28(%eax),%eax
80108732:	a3 68 e7 30 80       	mov    %eax,0x8030e768
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108737:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010873a:	8b 50 34             	mov    0x34(%eax),%edx
8010873d:	8b 40 30             	mov    0x30(%eax),%eax
80108740:	a3 6c e7 30 80       	mov    %eax,0x8030e76c
}
80108745:	90                   	nop
80108746:	c9                   	leave  
80108747:	c3                   	ret    

80108748 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108748:	55                   	push   %ebp
80108749:	89 e5                	mov    %esp,%ebp
8010874b:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
8010874e:	8b 15 6c e7 30 80    	mov    0x8030e76c,%edx
80108754:	8b 45 0c             	mov    0xc(%ebp),%eax
80108757:	0f af d0             	imul   %eax,%edx
8010875a:	8b 45 08             	mov    0x8(%ebp),%eax
8010875d:	01 d0                	add    %edx,%eax
8010875f:	c1 e0 02             	shl    $0x2,%eax
80108762:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108765:	8b 15 5c e7 30 80    	mov    0x8030e75c,%edx
8010876b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010876e:	01 d0                	add    %edx,%eax
80108770:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108773:	8b 45 10             	mov    0x10(%ebp),%eax
80108776:	0f b6 10             	movzbl (%eax),%edx
80108779:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010877c:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
8010877e:	8b 45 10             	mov    0x10(%ebp),%eax
80108781:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108785:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108788:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010878b:	8b 45 10             	mov    0x10(%ebp),%eax
8010878e:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108792:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108795:	88 50 02             	mov    %dl,0x2(%eax)
}
80108798:	90                   	nop
80108799:	c9                   	leave  
8010879a:	c3                   	ret    

8010879b <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010879b:	55                   	push   %ebp
8010879c:	89 e5                	mov    %esp,%ebp
8010879e:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801087a1:	8b 15 6c e7 30 80    	mov    0x8030e76c,%edx
801087a7:	8b 45 08             	mov    0x8(%ebp),%eax
801087aa:	0f af c2             	imul   %edx,%eax
801087ad:	c1 e0 02             	shl    $0x2,%eax
801087b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801087b3:	a1 60 e7 30 80       	mov    0x8030e760,%eax
801087b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801087bb:	29 d0                	sub    %edx,%eax
801087bd:	8b 0d 5c e7 30 80    	mov    0x8030e75c,%ecx
801087c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801087c6:	01 ca                	add    %ecx,%edx
801087c8:	89 d1                	mov    %edx,%ecx
801087ca:	8b 15 5c e7 30 80    	mov    0x8030e75c,%edx
801087d0:	83 ec 04             	sub    $0x4,%esp
801087d3:	50                   	push   %eax
801087d4:	51                   	push   %ecx
801087d5:	52                   	push   %edx
801087d6:	e8 32 c7 ff ff       	call   80104f0d <memmove>
801087db:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801087de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e1:	8b 0d 5c e7 30 80    	mov    0x8030e75c,%ecx
801087e7:	8b 15 60 e7 30 80    	mov    0x8030e760,%edx
801087ed:	01 ca                	add    %ecx,%edx
801087ef:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801087f2:	29 ca                	sub    %ecx,%edx
801087f4:	83 ec 04             	sub    $0x4,%esp
801087f7:	50                   	push   %eax
801087f8:	6a 00                	push   $0x0
801087fa:	52                   	push   %edx
801087fb:	e8 4e c6 ff ff       	call   80104e4e <memset>
80108800:	83 c4 10             	add    $0x10,%esp
}
80108803:	90                   	nop
80108804:	c9                   	leave  
80108805:	c3                   	ret    

80108806 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108806:	55                   	push   %ebp
80108807:	89 e5                	mov    %esp,%ebp
80108809:	53                   	push   %ebx
8010880a:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010880d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108814:	e9 b1 00 00 00       	jmp    801088ca <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108819:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108820:	e9 97 00 00 00       	jmp    801088bc <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108825:	8b 45 10             	mov    0x10(%ebp),%eax
80108828:	83 e8 20             	sub    $0x20,%eax
8010882b:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010882e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108831:	01 d0                	add    %edx,%eax
80108833:	0f b7 84 00 40 b1 10 	movzwl -0x7fef4ec0(%eax,%eax,1),%eax
8010883a:	80 
8010883b:	0f b7 d0             	movzwl %ax,%edx
8010883e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108841:	bb 01 00 00 00       	mov    $0x1,%ebx
80108846:	89 c1                	mov    %eax,%ecx
80108848:	d3 e3                	shl    %cl,%ebx
8010884a:	89 d8                	mov    %ebx,%eax
8010884c:	21 d0                	and    %edx,%eax
8010884e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108854:	ba 01 00 00 00       	mov    $0x1,%edx
80108859:	89 c1                	mov    %eax,%ecx
8010885b:	d3 e2                	shl    %cl,%edx
8010885d:	89 d0                	mov    %edx,%eax
8010885f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108862:	75 2b                	jne    8010888f <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108864:	8b 55 0c             	mov    0xc(%ebp),%edx
80108867:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886a:	01 c2                	add    %eax,%edx
8010886c:	b8 0e 00 00 00       	mov    $0xe,%eax
80108871:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108874:	89 c1                	mov    %eax,%ecx
80108876:	8b 45 08             	mov    0x8(%ebp),%eax
80108879:	01 c8                	add    %ecx,%eax
8010887b:	83 ec 04             	sub    $0x4,%esp
8010887e:	68 00 f5 10 80       	push   $0x8010f500
80108883:	52                   	push   %edx
80108884:	50                   	push   %eax
80108885:	e8 be fe ff ff       	call   80108748 <graphic_draw_pixel>
8010888a:	83 c4 10             	add    $0x10,%esp
8010888d:	eb 29                	jmp    801088b8 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010888f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108895:	01 c2                	add    %eax,%edx
80108897:	b8 0e 00 00 00       	mov    $0xe,%eax
8010889c:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010889f:	89 c1                	mov    %eax,%ecx
801088a1:	8b 45 08             	mov    0x8(%ebp),%eax
801088a4:	01 c8                	add    %ecx,%eax
801088a6:	83 ec 04             	sub    $0x4,%esp
801088a9:	68 70 e7 30 80       	push   $0x8030e770
801088ae:	52                   	push   %edx
801088af:	50                   	push   %eax
801088b0:	e8 93 fe ff ff       	call   80108748 <graphic_draw_pixel>
801088b5:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801088b8:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801088bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801088c0:	0f 89 5f ff ff ff    	jns    80108825 <font_render+0x1f>
  for(int i=0;i<30;i++){
801088c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801088ca:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801088ce:	0f 8e 45 ff ff ff    	jle    80108819 <font_render+0x13>
      }
    }
  }
}
801088d4:	90                   	nop
801088d5:	90                   	nop
801088d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088d9:	c9                   	leave  
801088da:	c3                   	ret    

801088db <font_render_string>:

void font_render_string(char *string,int row){
801088db:	55                   	push   %ebp
801088dc:	89 e5                	mov    %esp,%ebp
801088de:	53                   	push   %ebx
801088df:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801088e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801088e9:	eb 33                	jmp    8010891e <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801088eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088ee:	8b 45 08             	mov    0x8(%ebp),%eax
801088f1:	01 d0                	add    %edx,%eax
801088f3:	0f b6 00             	movzbl (%eax),%eax
801088f6:	0f be c8             	movsbl %al,%ecx
801088f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801088fc:	6b d0 1e             	imul   $0x1e,%eax,%edx
801088ff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108902:	89 d8                	mov    %ebx,%eax
80108904:	c1 e0 04             	shl    $0x4,%eax
80108907:	29 d8                	sub    %ebx,%eax
80108909:	83 c0 02             	add    $0x2,%eax
8010890c:	83 ec 04             	sub    $0x4,%esp
8010890f:	51                   	push   %ecx
80108910:	52                   	push   %edx
80108911:	50                   	push   %eax
80108912:	e8 ef fe ff ff       	call   80108806 <font_render>
80108917:	83 c4 10             	add    $0x10,%esp
    i++;
8010891a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
8010891e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108921:	8b 45 08             	mov    0x8(%ebp),%eax
80108924:	01 d0                	add    %edx,%eax
80108926:	0f b6 00             	movzbl (%eax),%eax
80108929:	84 c0                	test   %al,%al
8010892b:	74 06                	je     80108933 <font_render_string+0x58>
8010892d:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108931:	7e b8                	jle    801088eb <font_render_string+0x10>
  }
}
80108933:	90                   	nop
80108934:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108937:	c9                   	leave  
80108938:	c3                   	ret    

80108939 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108939:	55                   	push   %ebp
8010893a:	89 e5                	mov    %esp,%ebp
8010893c:	53                   	push   %ebx
8010893d:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108940:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108947:	eb 6b                	jmp    801089b4 <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108949:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108950:	eb 58                	jmp    801089aa <pci_init+0x71>
      for(int k=0;k<8;k++){
80108952:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108959:	eb 45                	jmp    801089a0 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
8010895b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010895e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108964:	83 ec 0c             	sub    $0xc,%esp
80108967:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010896a:	53                   	push   %ebx
8010896b:	6a 00                	push   $0x0
8010896d:	51                   	push   %ecx
8010896e:	52                   	push   %edx
8010896f:	50                   	push   %eax
80108970:	e8 b0 00 00 00       	call   80108a25 <pci_access_config>
80108975:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108978:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010897b:	0f b7 c0             	movzwl %ax,%eax
8010897e:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108983:	74 17                	je     8010899c <pci_init+0x63>
        pci_init_device(i,j,k);
80108985:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108988:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010898b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898e:	83 ec 04             	sub    $0x4,%esp
80108991:	51                   	push   %ecx
80108992:	52                   	push   %edx
80108993:	50                   	push   %eax
80108994:	e8 37 01 00 00       	call   80108ad0 <pci_init_device>
80108999:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
8010899c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801089a0:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801089a4:	7e b5                	jle    8010895b <pci_init+0x22>
    for(int j=0;j<32;j++){
801089a6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801089aa:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801089ae:	7e a2                	jle    80108952 <pci_init+0x19>
  for(int i=0;i<256;i++){
801089b0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801089b4:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801089bb:	7e 8c                	jle    80108949 <pci_init+0x10>
      }
      }
    }
  }
}
801089bd:	90                   	nop
801089be:	90                   	nop
801089bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089c2:	c9                   	leave  
801089c3:	c3                   	ret    

801089c4 <pci_write_config>:

void pci_write_config(uint config){
801089c4:	55                   	push   %ebp
801089c5:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801089c7:	8b 45 08             	mov    0x8(%ebp),%eax
801089ca:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801089cf:	89 c0                	mov    %eax,%eax
801089d1:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801089d2:	90                   	nop
801089d3:	5d                   	pop    %ebp
801089d4:	c3                   	ret    

801089d5 <pci_write_data>:

void pci_write_data(uint config){
801089d5:	55                   	push   %ebp
801089d6:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801089d8:	8b 45 08             	mov    0x8(%ebp),%eax
801089db:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801089e0:	89 c0                	mov    %eax,%eax
801089e2:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801089e3:	90                   	nop
801089e4:	5d                   	pop    %ebp
801089e5:	c3                   	ret    

801089e6 <pci_read_config>:
uint pci_read_config(){
801089e6:	55                   	push   %ebp
801089e7:	89 e5                	mov    %esp,%ebp
801089e9:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801089ec:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801089f1:	ed                   	in     (%dx),%eax
801089f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801089f5:	83 ec 0c             	sub    $0xc,%esp
801089f8:	68 c8 00 00 00       	push   $0xc8
801089fd:	e8 1d a1 ff ff       	call   80102b1f <microdelay>
80108a02:	83 c4 10             	add    $0x10,%esp
  return data;
80108a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108a08:	c9                   	leave  
80108a09:	c3                   	ret    

80108a0a <pci_test>:


void pci_test(){
80108a0a:	55                   	push   %ebp
80108a0b:	89 e5                	mov    %esp,%ebp
80108a0d:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108a10:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108a17:	ff 75 fc             	push   -0x4(%ebp)
80108a1a:	e8 a5 ff ff ff       	call   801089c4 <pci_write_config>
80108a1f:	83 c4 04             	add    $0x4,%esp
}
80108a22:	90                   	nop
80108a23:	c9                   	leave  
80108a24:	c3                   	ret    

80108a25 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108a25:	55                   	push   %ebp
80108a26:	89 e5                	mov    %esp,%ebp
80108a28:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80108a2e:	c1 e0 10             	shl    $0x10,%eax
80108a31:	25 00 00 ff 00       	and    $0xff0000,%eax
80108a36:	89 c2                	mov    %eax,%edx
80108a38:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a3b:	c1 e0 0b             	shl    $0xb,%eax
80108a3e:	0f b7 c0             	movzwl %ax,%eax
80108a41:	09 c2                	or     %eax,%edx
80108a43:	8b 45 10             	mov    0x10(%ebp),%eax
80108a46:	c1 e0 08             	shl    $0x8,%eax
80108a49:	25 00 07 00 00       	and    $0x700,%eax
80108a4e:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108a50:	8b 45 14             	mov    0x14(%ebp),%eax
80108a53:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a58:	09 d0                	or     %edx,%eax
80108a5a:	0d 00 00 00 80       	or     $0x80000000,%eax
80108a5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108a62:	ff 75 f4             	push   -0xc(%ebp)
80108a65:	e8 5a ff ff ff       	call   801089c4 <pci_write_config>
80108a6a:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108a6d:	e8 74 ff ff ff       	call   801089e6 <pci_read_config>
80108a72:	8b 55 18             	mov    0x18(%ebp),%edx
80108a75:	89 02                	mov    %eax,(%edx)
}
80108a77:	90                   	nop
80108a78:	c9                   	leave  
80108a79:	c3                   	ret    

80108a7a <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108a7a:	55                   	push   %ebp
80108a7b:	89 e5                	mov    %esp,%ebp
80108a7d:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a80:	8b 45 08             	mov    0x8(%ebp),%eax
80108a83:	c1 e0 10             	shl    $0x10,%eax
80108a86:	25 00 00 ff 00       	and    $0xff0000,%eax
80108a8b:	89 c2                	mov    %eax,%edx
80108a8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a90:	c1 e0 0b             	shl    $0xb,%eax
80108a93:	0f b7 c0             	movzwl %ax,%eax
80108a96:	09 c2                	or     %eax,%edx
80108a98:	8b 45 10             	mov    0x10(%ebp),%eax
80108a9b:	c1 e0 08             	shl    $0x8,%eax
80108a9e:	25 00 07 00 00       	and    $0x700,%eax
80108aa3:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108aa5:	8b 45 14             	mov    0x14(%ebp),%eax
80108aa8:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108aad:	09 d0                	or     %edx,%eax
80108aaf:	0d 00 00 00 80       	or     $0x80000000,%eax
80108ab4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108ab7:	ff 75 fc             	push   -0x4(%ebp)
80108aba:	e8 05 ff ff ff       	call   801089c4 <pci_write_config>
80108abf:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108ac2:	ff 75 18             	push   0x18(%ebp)
80108ac5:	e8 0b ff ff ff       	call   801089d5 <pci_write_data>
80108aca:	83 c4 04             	add    $0x4,%esp
}
80108acd:	90                   	nop
80108ace:	c9                   	leave  
80108acf:	c3                   	ret    

80108ad0 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108ad0:	55                   	push   %ebp
80108ad1:	89 e5                	mov    %esp,%ebp
80108ad3:	53                   	push   %ebx
80108ad4:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80108ada:	a2 74 e7 30 80       	mov    %al,0x8030e774
  dev.device_num = device_num;
80108adf:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ae2:	a2 75 e7 30 80       	mov    %al,0x8030e775
  dev.function_num = function_num;
80108ae7:	8b 45 10             	mov    0x10(%ebp),%eax
80108aea:	a2 76 e7 30 80       	mov    %al,0x8030e776
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108aef:	ff 75 10             	push   0x10(%ebp)
80108af2:	ff 75 0c             	push   0xc(%ebp)
80108af5:	ff 75 08             	push   0x8(%ebp)
80108af8:	68 84 c7 10 80       	push   $0x8010c784
80108afd:	e8 f2 78 ff ff       	call   801003f4 <cprintf>
80108b02:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108b05:	83 ec 0c             	sub    $0xc,%esp
80108b08:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108b0b:	50                   	push   %eax
80108b0c:	6a 00                	push   $0x0
80108b0e:	ff 75 10             	push   0x10(%ebp)
80108b11:	ff 75 0c             	push   0xc(%ebp)
80108b14:	ff 75 08             	push   0x8(%ebp)
80108b17:	e8 09 ff ff ff       	call   80108a25 <pci_access_config>
80108b1c:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108b1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b22:	c1 e8 10             	shr    $0x10,%eax
80108b25:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108b28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b2b:	25 ff ff 00 00       	and    $0xffff,%eax
80108b30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b36:	a3 78 e7 30 80       	mov    %eax,0x8030e778
  dev.vendor_id = vendor_id;
80108b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b3e:	a3 7c e7 30 80       	mov    %eax,0x8030e77c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108b43:	83 ec 04             	sub    $0x4,%esp
80108b46:	ff 75 f0             	push   -0x10(%ebp)
80108b49:	ff 75 f4             	push   -0xc(%ebp)
80108b4c:	68 b8 c7 10 80       	push   $0x8010c7b8
80108b51:	e8 9e 78 ff ff       	call   801003f4 <cprintf>
80108b56:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108b59:	83 ec 0c             	sub    $0xc,%esp
80108b5c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108b5f:	50                   	push   %eax
80108b60:	6a 08                	push   $0x8
80108b62:	ff 75 10             	push   0x10(%ebp)
80108b65:	ff 75 0c             	push   0xc(%ebp)
80108b68:	ff 75 08             	push   0x8(%ebp)
80108b6b:	e8 b5 fe ff ff       	call   80108a25 <pci_access_config>
80108b70:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b76:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108b79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b7c:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b7f:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108b82:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b85:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b88:	0f b6 c0             	movzbl %al,%eax
80108b8b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108b8e:	c1 eb 18             	shr    $0x18,%ebx
80108b91:	83 ec 0c             	sub    $0xc,%esp
80108b94:	51                   	push   %ecx
80108b95:	52                   	push   %edx
80108b96:	50                   	push   %eax
80108b97:	53                   	push   %ebx
80108b98:	68 dc c7 10 80       	push   $0x8010c7dc
80108b9d:	e8 52 78 ff ff       	call   801003f4 <cprintf>
80108ba2:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108ba5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ba8:	c1 e8 18             	shr    $0x18,%eax
80108bab:	a2 80 e7 30 80       	mov    %al,0x8030e780
  dev.sub_class = (data>>16)&0xFF;
80108bb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bb3:	c1 e8 10             	shr    $0x10,%eax
80108bb6:	a2 81 e7 30 80       	mov    %al,0x8030e781
  dev.interface = (data>>8)&0xFF;
80108bbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bbe:	c1 e8 08             	shr    $0x8,%eax
80108bc1:	a2 82 e7 30 80       	mov    %al,0x8030e782
  dev.revision_id = data&0xFF;
80108bc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bc9:	a2 83 e7 30 80       	mov    %al,0x8030e783
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108bce:	83 ec 0c             	sub    $0xc,%esp
80108bd1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108bd4:	50                   	push   %eax
80108bd5:	6a 10                	push   $0x10
80108bd7:	ff 75 10             	push   0x10(%ebp)
80108bda:	ff 75 0c             	push   0xc(%ebp)
80108bdd:	ff 75 08             	push   0x8(%ebp)
80108be0:	e8 40 fe ff ff       	call   80108a25 <pci_access_config>
80108be5:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108be8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108beb:	a3 84 e7 30 80       	mov    %eax,0x8030e784
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108bf0:	83 ec 0c             	sub    $0xc,%esp
80108bf3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108bf6:	50                   	push   %eax
80108bf7:	6a 14                	push   $0x14
80108bf9:	ff 75 10             	push   0x10(%ebp)
80108bfc:	ff 75 0c             	push   0xc(%ebp)
80108bff:	ff 75 08             	push   0x8(%ebp)
80108c02:	e8 1e fe ff ff       	call   80108a25 <pci_access_config>
80108c07:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108c0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c0d:	a3 88 e7 30 80       	mov    %eax,0x8030e788
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108c12:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108c19:	75 5a                	jne    80108c75 <pci_init_device+0x1a5>
80108c1b:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108c22:	75 51                	jne    80108c75 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108c24:	83 ec 0c             	sub    $0xc,%esp
80108c27:	68 21 c8 10 80       	push   $0x8010c821
80108c2c:	e8 c3 77 ff ff       	call   801003f4 <cprintf>
80108c31:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108c34:	83 ec 0c             	sub    $0xc,%esp
80108c37:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108c3a:	50                   	push   %eax
80108c3b:	68 f0 00 00 00       	push   $0xf0
80108c40:	ff 75 10             	push   0x10(%ebp)
80108c43:	ff 75 0c             	push   0xc(%ebp)
80108c46:	ff 75 08             	push   0x8(%ebp)
80108c49:	e8 d7 fd ff ff       	call   80108a25 <pci_access_config>
80108c4e:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108c51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c54:	83 ec 08             	sub    $0x8,%esp
80108c57:	50                   	push   %eax
80108c58:	68 3b c8 10 80       	push   $0x8010c83b
80108c5d:	e8 92 77 ff ff       	call   801003f4 <cprintf>
80108c62:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108c65:	83 ec 0c             	sub    $0xc,%esp
80108c68:	68 74 e7 30 80       	push   $0x8030e774
80108c6d:	e8 09 00 00 00       	call   80108c7b <i8254_init>
80108c72:	83 c4 10             	add    $0x10,%esp
  }
}
80108c75:	90                   	nop
80108c76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c79:	c9                   	leave  
80108c7a:	c3                   	ret    

80108c7b <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108c7b:	55                   	push   %ebp
80108c7c:	89 e5                	mov    %esp,%ebp
80108c7e:	53                   	push   %ebx
80108c7f:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108c82:	8b 45 08             	mov    0x8(%ebp),%eax
80108c85:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108c89:	0f b6 c8             	movzbl %al,%ecx
80108c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80108c8f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108c93:	0f b6 d0             	movzbl %al,%edx
80108c96:	8b 45 08             	mov    0x8(%ebp),%eax
80108c99:	0f b6 00             	movzbl (%eax),%eax
80108c9c:	0f b6 c0             	movzbl %al,%eax
80108c9f:	83 ec 0c             	sub    $0xc,%esp
80108ca2:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108ca5:	53                   	push   %ebx
80108ca6:	6a 04                	push   $0x4
80108ca8:	51                   	push   %ecx
80108ca9:	52                   	push   %edx
80108caa:	50                   	push   %eax
80108cab:	e8 75 fd ff ff       	call   80108a25 <pci_access_config>
80108cb0:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108cb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cb6:	83 c8 04             	or     $0x4,%eax
80108cb9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108cbc:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108cbf:	8b 45 08             	mov    0x8(%ebp),%eax
80108cc2:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108cc6:	0f b6 c8             	movzbl %al,%ecx
80108cc9:	8b 45 08             	mov    0x8(%ebp),%eax
80108ccc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108cd0:	0f b6 d0             	movzbl %al,%edx
80108cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd6:	0f b6 00             	movzbl (%eax),%eax
80108cd9:	0f b6 c0             	movzbl %al,%eax
80108cdc:	83 ec 0c             	sub    $0xc,%esp
80108cdf:	53                   	push   %ebx
80108ce0:	6a 04                	push   $0x4
80108ce2:	51                   	push   %ecx
80108ce3:	52                   	push   %edx
80108ce4:	50                   	push   %eax
80108ce5:	e8 90 fd ff ff       	call   80108a7a <pci_write_config_register>
80108cea:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108ced:	8b 45 08             	mov    0x8(%ebp),%eax
80108cf0:	8b 40 10             	mov    0x10(%eax),%eax
80108cf3:	05 00 00 00 40       	add    $0x40000000,%eax
80108cf8:	a3 8c e7 30 80       	mov    %eax,0x8030e78c
  uint *ctrl = (uint *)base_addr;
80108cfd:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108d05:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108d0a:	05 d8 00 00 00       	add    $0xd8,%eax
80108d0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d15:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d1e:	8b 00                	mov    (%eax),%eax
80108d20:	0d 00 00 00 04       	or     $0x4000000,%eax
80108d25:	89 c2                	mov    %eax,%edx
80108d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d2a:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d2f:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d38:	8b 00                	mov    (%eax),%eax
80108d3a:	83 c8 40             	or     $0x40,%eax
80108d3d:	89 c2                	mov    %eax,%edx
80108d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d42:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d47:	8b 10                	mov    (%eax),%edx
80108d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d4c:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108d4e:	83 ec 0c             	sub    $0xc,%esp
80108d51:	68 50 c8 10 80       	push   $0x8010c850
80108d56:	e8 99 76 ff ff       	call   801003f4 <cprintf>
80108d5b:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108d5e:	e8 25 9a ff ff       	call   80102788 <kalloc>
80108d63:	a3 98 e7 30 80       	mov    %eax,0x8030e798
  *intr_addr = 0;
80108d68:	a1 98 e7 30 80       	mov    0x8030e798,%eax
80108d6d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108d73:	a1 98 e7 30 80       	mov    0x8030e798,%eax
80108d78:	83 ec 08             	sub    $0x8,%esp
80108d7b:	50                   	push   %eax
80108d7c:	68 72 c8 10 80       	push   $0x8010c872
80108d81:	e8 6e 76 ff ff       	call   801003f4 <cprintf>
80108d86:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108d89:	e8 50 00 00 00       	call   80108dde <i8254_init_recv>
  i8254_init_send();
80108d8e:	e8 69 03 00 00       	call   801090fc <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108d93:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d9a:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108d9d:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108da4:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108da7:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108dae:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108db1:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108db8:	0f b6 c0             	movzbl %al,%eax
80108dbb:	83 ec 0c             	sub    $0xc,%esp
80108dbe:	53                   	push   %ebx
80108dbf:	51                   	push   %ecx
80108dc0:	52                   	push   %edx
80108dc1:	50                   	push   %eax
80108dc2:	68 80 c8 10 80       	push   $0x8010c880
80108dc7:	e8 28 76 ff ff       	call   801003f4 <cprintf>
80108dcc:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dd2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108dd8:	90                   	nop
80108dd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ddc:	c9                   	leave  
80108ddd:	c3                   	ret    

80108dde <i8254_init_recv>:

void i8254_init_recv(){
80108dde:	55                   	push   %ebp
80108ddf:	89 e5                	mov    %esp,%ebp
80108de1:	57                   	push   %edi
80108de2:	56                   	push   %esi
80108de3:	53                   	push   %ebx
80108de4:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108de7:	83 ec 0c             	sub    $0xc,%esp
80108dea:	6a 00                	push   $0x0
80108dec:	e8 e8 04 00 00       	call   801092d9 <i8254_read_eeprom>
80108df1:	83 c4 10             	add    $0x10,%esp
80108df4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108df7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108dfa:	a2 90 e7 30 80       	mov    %al,0x8030e790
  mac_addr[1] = data_l>>8;
80108dff:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108e02:	c1 e8 08             	shr    $0x8,%eax
80108e05:	a2 91 e7 30 80       	mov    %al,0x8030e791
  uint data_m = i8254_read_eeprom(0x1);
80108e0a:	83 ec 0c             	sub    $0xc,%esp
80108e0d:	6a 01                	push   $0x1
80108e0f:	e8 c5 04 00 00       	call   801092d9 <i8254_read_eeprom>
80108e14:	83 c4 10             	add    $0x10,%esp
80108e17:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108e1a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e1d:	a2 92 e7 30 80       	mov    %al,0x8030e792
  mac_addr[3] = data_m>>8;
80108e22:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e25:	c1 e8 08             	shr    $0x8,%eax
80108e28:	a2 93 e7 30 80       	mov    %al,0x8030e793
  uint data_h = i8254_read_eeprom(0x2);
80108e2d:	83 ec 0c             	sub    $0xc,%esp
80108e30:	6a 02                	push   $0x2
80108e32:	e8 a2 04 00 00       	call   801092d9 <i8254_read_eeprom>
80108e37:	83 c4 10             	add    $0x10,%esp
80108e3a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108e3d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e40:	a2 94 e7 30 80       	mov    %al,0x8030e794
  mac_addr[5] = data_h>>8;
80108e45:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e48:	c1 e8 08             	shr    $0x8,%eax
80108e4b:	a2 95 e7 30 80       	mov    %al,0x8030e795
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108e50:	0f b6 05 95 e7 30 80 	movzbl 0x8030e795,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e57:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108e5a:	0f b6 05 94 e7 30 80 	movzbl 0x8030e794,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e61:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108e64:	0f b6 05 93 e7 30 80 	movzbl 0x8030e793,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e6b:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108e6e:	0f b6 05 92 e7 30 80 	movzbl 0x8030e792,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e75:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108e78:	0f b6 05 91 e7 30 80 	movzbl 0x8030e791,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e7f:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108e82:	0f b6 05 90 e7 30 80 	movzbl 0x8030e790,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e89:	0f b6 c0             	movzbl %al,%eax
80108e8c:	83 ec 04             	sub    $0x4,%esp
80108e8f:	57                   	push   %edi
80108e90:	56                   	push   %esi
80108e91:	53                   	push   %ebx
80108e92:	51                   	push   %ecx
80108e93:	52                   	push   %edx
80108e94:	50                   	push   %eax
80108e95:	68 98 c8 10 80       	push   $0x8010c898
80108e9a:	e8 55 75 ff ff       	call   801003f4 <cprintf>
80108e9f:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108ea2:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108ea7:	05 00 54 00 00       	add    $0x5400,%eax
80108eac:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108eaf:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108eb4:	05 04 54 00 00       	add    $0x5404,%eax
80108eb9:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108ebc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ebf:	c1 e0 10             	shl    $0x10,%eax
80108ec2:	0b 45 d8             	or     -0x28(%ebp),%eax
80108ec5:	89 c2                	mov    %eax,%edx
80108ec7:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108eca:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108ecc:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ecf:	0d 00 00 00 80       	or     $0x80000000,%eax
80108ed4:	89 c2                	mov    %eax,%edx
80108ed6:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108ed9:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108edb:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108ee0:	05 00 52 00 00       	add    $0x5200,%eax
80108ee5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108ee8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108eef:	eb 19                	jmp    80108f0a <i8254_init_recv+0x12c>
    mta[i] = 0;
80108ef1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ef4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108efb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108efe:	01 d0                	add    %edx,%eax
80108f00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108f06:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108f0a:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108f0e:	7e e1                	jle    80108ef1 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108f10:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108f15:	05 d0 00 00 00       	add    $0xd0,%eax
80108f1a:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108f1d:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108f20:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108f26:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108f2b:	05 c8 00 00 00       	add    $0xc8,%eax
80108f30:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108f33:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108f36:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108f3c:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108f41:	05 28 28 00 00       	add    $0x2828,%eax
80108f46:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108f49:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108f4c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108f52:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108f57:	05 00 01 00 00       	add    $0x100,%eax
80108f5c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108f5f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108f62:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108f68:	e8 1b 98 ff ff       	call   80102788 <kalloc>
80108f6d:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108f70:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108f75:	05 00 28 00 00       	add    $0x2800,%eax
80108f7a:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108f7d:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108f82:	05 04 28 00 00       	add    $0x2804,%eax
80108f87:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108f8a:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108f8f:	05 08 28 00 00       	add    $0x2808,%eax
80108f94:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108f97:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108f9c:	05 10 28 00 00       	add    $0x2810,%eax
80108fa1:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108fa4:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80108fa9:	05 18 28 00 00       	add    $0x2818,%eax
80108fae:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108fb1:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108fb4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108fba:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108fbd:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108fbf:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108fc2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108fc8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108fcb:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108fd1:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108fd4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108fda:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108fdd:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108fe3:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108fe6:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108fe9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108ff0:	eb 73                	jmp    80109065 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108ff2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ff5:	c1 e0 04             	shl    $0x4,%eax
80108ff8:	89 c2                	mov    %eax,%edx
80108ffa:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ffd:	01 d0                	add    %edx,%eax
80108fff:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80109006:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109009:	c1 e0 04             	shl    $0x4,%eax
8010900c:	89 c2                	mov    %eax,%edx
8010900e:	8b 45 98             	mov    -0x68(%ebp),%eax
80109011:	01 d0                	add    %edx,%eax
80109013:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80109019:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010901c:	c1 e0 04             	shl    $0x4,%eax
8010901f:	89 c2                	mov    %eax,%edx
80109021:	8b 45 98             	mov    -0x68(%ebp),%eax
80109024:	01 d0                	add    %edx,%eax
80109026:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
8010902c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010902f:	c1 e0 04             	shl    $0x4,%eax
80109032:	89 c2                	mov    %eax,%edx
80109034:	8b 45 98             	mov    -0x68(%ebp),%eax
80109037:	01 d0                	add    %edx,%eax
80109039:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
8010903d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109040:	c1 e0 04             	shl    $0x4,%eax
80109043:	89 c2                	mov    %eax,%edx
80109045:	8b 45 98             	mov    -0x68(%ebp),%eax
80109048:	01 d0                	add    %edx,%eax
8010904a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
8010904e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109051:	c1 e0 04             	shl    $0x4,%eax
80109054:	89 c2                	mov    %eax,%edx
80109056:	8b 45 98             	mov    -0x68(%ebp),%eax
80109059:	01 d0                	add    %edx,%eax
8010905b:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109061:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80109065:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
8010906c:	7e 84                	jle    80108ff2 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010906e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80109075:	eb 57                	jmp    801090ce <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80109077:	e8 0c 97 ff ff       	call   80102788 <kalloc>
8010907c:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
8010907f:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80109083:	75 12                	jne    80109097 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80109085:	83 ec 0c             	sub    $0xc,%esp
80109088:	68 b8 c8 10 80       	push   $0x8010c8b8
8010908d:	e8 62 73 ff ff       	call   801003f4 <cprintf>
80109092:	83 c4 10             	add    $0x10,%esp
      break;
80109095:	eb 3d                	jmp    801090d4 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80109097:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010909a:	c1 e0 04             	shl    $0x4,%eax
8010909d:	89 c2                	mov    %eax,%edx
8010909f:	8b 45 98             	mov    -0x68(%ebp),%eax
801090a2:	01 d0                	add    %edx,%eax
801090a4:	8b 55 94             	mov    -0x6c(%ebp),%edx
801090a7:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801090ad:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801090af:	8b 45 dc             	mov    -0x24(%ebp),%eax
801090b2:	83 c0 01             	add    $0x1,%eax
801090b5:	c1 e0 04             	shl    $0x4,%eax
801090b8:	89 c2                	mov    %eax,%edx
801090ba:	8b 45 98             	mov    -0x68(%ebp),%eax
801090bd:	01 d0                	add    %edx,%eax
801090bf:	8b 55 94             	mov    -0x6c(%ebp),%edx
801090c2:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801090c8:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801090ca:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801090ce:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801090d2:	7e a3                	jle    80109077 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
801090d4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801090d7:	8b 00                	mov    (%eax),%eax
801090d9:	83 c8 02             	or     $0x2,%eax
801090dc:	89 c2                	mov    %eax,%edx
801090de:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801090e1:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801090e3:	83 ec 0c             	sub    $0xc,%esp
801090e6:	68 d8 c8 10 80       	push   $0x8010c8d8
801090eb:	e8 04 73 ff ff       	call   801003f4 <cprintf>
801090f0:	83 c4 10             	add    $0x10,%esp
}
801090f3:	90                   	nop
801090f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801090f7:	5b                   	pop    %ebx
801090f8:	5e                   	pop    %esi
801090f9:	5f                   	pop    %edi
801090fa:	5d                   	pop    %ebp
801090fb:	c3                   	ret    

801090fc <i8254_init_send>:

void i8254_init_send(){
801090fc:	55                   	push   %ebp
801090fd:	89 e5                	mov    %esp,%ebp
801090ff:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80109102:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80109107:	05 28 38 00 00       	add    $0x3828,%eax
8010910c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
8010910f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109112:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80109118:	e8 6b 96 ff ff       	call   80102788 <kalloc>
8010911d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109120:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80109125:	05 00 38 00 00       	add    $0x3800,%eax
8010912a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
8010912d:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80109132:	05 04 38 00 00       	add    $0x3804,%eax
80109137:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
8010913a:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
8010913f:	05 08 38 00 00       	add    $0x3808,%eax
80109144:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80109147:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010914a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109150:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109153:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80109155:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109158:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
8010915e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109161:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80109167:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
8010916c:	05 10 38 00 00       	add    $0x3810,%eax
80109171:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109174:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80109179:	05 18 38 00 00       	add    $0x3818,%eax
8010917e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80109181:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109184:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
8010918a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010918d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109193:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109196:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109199:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801091a0:	e9 82 00 00 00       	jmp    80109227 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
801091a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091a8:	c1 e0 04             	shl    $0x4,%eax
801091ab:	89 c2                	mov    %eax,%edx
801091ad:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091b0:	01 d0                	add    %edx,%eax
801091b2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
801091b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091bc:	c1 e0 04             	shl    $0x4,%eax
801091bf:	89 c2                	mov    %eax,%edx
801091c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091c4:	01 d0                	add    %edx,%eax
801091c6:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801091cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091cf:	c1 e0 04             	shl    $0x4,%eax
801091d2:	89 c2                	mov    %eax,%edx
801091d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091d7:	01 d0                	add    %edx,%eax
801091d9:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801091dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091e0:	c1 e0 04             	shl    $0x4,%eax
801091e3:	89 c2                	mov    %eax,%edx
801091e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091e8:	01 d0                	add    %edx,%eax
801091ea:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801091ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f1:	c1 e0 04             	shl    $0x4,%eax
801091f4:	89 c2                	mov    %eax,%edx
801091f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091f9:	01 d0                	add    %edx,%eax
801091fb:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801091ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109202:	c1 e0 04             	shl    $0x4,%eax
80109205:	89 c2                	mov    %eax,%edx
80109207:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010920a:	01 d0                	add    %edx,%eax
8010920c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80109210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109213:	c1 e0 04             	shl    $0x4,%eax
80109216:	89 c2                	mov    %eax,%edx
80109218:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010921b:	01 d0                	add    %edx,%eax
8010921d:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109223:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109227:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010922e:	0f 8e 71 ff ff ff    	jle    801091a5 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109234:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010923b:	eb 57                	jmp    80109294 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
8010923d:	e8 46 95 ff ff       	call   80102788 <kalloc>
80109242:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109245:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80109249:	75 12                	jne    8010925d <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
8010924b:	83 ec 0c             	sub    $0xc,%esp
8010924e:	68 b8 c8 10 80       	push   $0x8010c8b8
80109253:	e8 9c 71 ff ff       	call   801003f4 <cprintf>
80109258:	83 c4 10             	add    $0x10,%esp
      break;
8010925b:	eb 3d                	jmp    8010929a <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
8010925d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109260:	c1 e0 04             	shl    $0x4,%eax
80109263:	89 c2                	mov    %eax,%edx
80109265:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109268:	01 d0                	add    %edx,%eax
8010926a:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010926d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109273:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109275:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109278:	83 c0 01             	add    $0x1,%eax
8010927b:	c1 e0 04             	shl    $0x4,%eax
8010927e:	89 c2                	mov    %eax,%edx
80109280:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109283:	01 d0                	add    %edx,%eax
80109285:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109288:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010928e:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109290:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109294:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109298:	7e a3                	jle    8010923d <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
8010929a:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
8010929f:	05 00 04 00 00       	add    $0x400,%eax
801092a4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
801092a7:	8b 45 c8             	mov    -0x38(%ebp),%eax
801092aa:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
801092b0:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
801092b5:	05 10 04 00 00       	add    $0x410,%eax
801092ba:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801092bd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801092c0:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
801092c6:	83 ec 0c             	sub    $0xc,%esp
801092c9:	68 f8 c8 10 80       	push   $0x8010c8f8
801092ce:	e8 21 71 ff ff       	call   801003f4 <cprintf>
801092d3:	83 c4 10             	add    $0x10,%esp

}
801092d6:	90                   	nop
801092d7:	c9                   	leave  
801092d8:	c3                   	ret    

801092d9 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801092d9:	55                   	push   %ebp
801092da:	89 e5                	mov    %esp,%ebp
801092dc:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801092df:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
801092e4:	83 c0 14             	add    $0x14,%eax
801092e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801092ea:	8b 45 08             	mov    0x8(%ebp),%eax
801092ed:	c1 e0 08             	shl    $0x8,%eax
801092f0:	0f b7 c0             	movzwl %ax,%eax
801092f3:	83 c8 01             	or     $0x1,%eax
801092f6:	89 c2                	mov    %eax,%edx
801092f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092fb:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801092fd:	83 ec 0c             	sub    $0xc,%esp
80109300:	68 18 c9 10 80       	push   $0x8010c918
80109305:	e8 ea 70 ff ff       	call   801003f4 <cprintf>
8010930a:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
8010930d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109310:	8b 00                	mov    (%eax),%eax
80109312:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109315:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109318:	83 e0 10             	and    $0x10,%eax
8010931b:	85 c0                	test   %eax,%eax
8010931d:	75 02                	jne    80109321 <i8254_read_eeprom+0x48>
  while(1){
8010931f:	eb dc                	jmp    801092fd <i8254_read_eeprom+0x24>
      break;
80109321:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109325:	8b 00                	mov    (%eax),%eax
80109327:	c1 e8 10             	shr    $0x10,%eax
}
8010932a:	c9                   	leave  
8010932b:	c3                   	ret    

8010932c <i8254_recv>:
void i8254_recv(){
8010932c:	55                   	push   %ebp
8010932d:	89 e5                	mov    %esp,%ebp
8010932f:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109332:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80109337:	05 10 28 00 00       	add    $0x2810,%eax
8010933c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010933f:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80109344:	05 18 28 00 00       	add    $0x2818,%eax
80109349:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010934c:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
80109351:	05 00 28 00 00       	add    $0x2800,%eax
80109356:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109359:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010935c:	8b 00                	mov    (%eax),%eax
8010935e:	05 00 00 00 80       	add    $0x80000000,%eax
80109363:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80109366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109369:	8b 10                	mov    (%eax),%edx
8010936b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010936e:	8b 08                	mov    (%eax),%ecx
80109370:	89 d0                	mov    %edx,%eax
80109372:	29 c8                	sub    %ecx,%eax
80109374:	25 ff 00 00 00       	and    $0xff,%eax
80109379:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
8010937c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109380:	7e 37                	jle    801093b9 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109382:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109385:	8b 00                	mov    (%eax),%eax
80109387:	c1 e0 04             	shl    $0x4,%eax
8010938a:	89 c2                	mov    %eax,%edx
8010938c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010938f:	01 d0                	add    %edx,%eax
80109391:	8b 00                	mov    (%eax),%eax
80109393:	05 00 00 00 80       	add    $0x80000000,%eax
80109398:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
8010939b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010939e:	8b 00                	mov    (%eax),%eax
801093a0:	83 c0 01             	add    $0x1,%eax
801093a3:	0f b6 d0             	movzbl %al,%edx
801093a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093a9:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
801093ab:	83 ec 0c             	sub    $0xc,%esp
801093ae:	ff 75 e0             	push   -0x20(%ebp)
801093b1:	e8 15 09 00 00       	call   80109ccb <eth_proc>
801093b6:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801093b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093bc:	8b 10                	mov    (%eax),%edx
801093be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c1:	8b 00                	mov    (%eax),%eax
801093c3:	39 c2                	cmp    %eax,%edx
801093c5:	75 9f                	jne    80109366 <i8254_recv+0x3a>
      (*rdt)--;
801093c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093ca:	8b 00                	mov    (%eax),%eax
801093cc:	8d 50 ff             	lea    -0x1(%eax),%edx
801093cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d2:	89 10                	mov    %edx,(%eax)
  while(1){
801093d4:	eb 90                	jmp    80109366 <i8254_recv+0x3a>

801093d6 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
801093d6:	55                   	push   %ebp
801093d7:	89 e5                	mov    %esp,%ebp
801093d9:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801093dc:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
801093e1:	05 10 38 00 00       	add    $0x3810,%eax
801093e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801093e9:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
801093ee:	05 18 38 00 00       	add    $0x3818,%eax
801093f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801093f6:	a1 8c e7 30 80       	mov    0x8030e78c,%eax
801093fb:	05 00 38 00 00       	add    $0x3800,%eax
80109400:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109403:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109406:	8b 00                	mov    (%eax),%eax
80109408:	05 00 00 00 80       	add    $0x80000000,%eax
8010940d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109410:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109413:	8b 10                	mov    (%eax),%edx
80109415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109418:	8b 08                	mov    (%eax),%ecx
8010941a:	89 d0                	mov    %edx,%eax
8010941c:	29 c8                	sub    %ecx,%eax
8010941e:	0f b6 d0             	movzbl %al,%edx
80109421:	b8 00 01 00 00       	mov    $0x100,%eax
80109426:	29 d0                	sub    %edx,%eax
80109428:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
8010942b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010942e:	8b 00                	mov    (%eax),%eax
80109430:	25 ff 00 00 00       	and    $0xff,%eax
80109435:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109438:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010943c:	0f 8e a8 00 00 00    	jle    801094ea <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109442:	8b 45 08             	mov    0x8(%ebp),%eax
80109445:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109448:	89 d1                	mov    %edx,%ecx
8010944a:	c1 e1 04             	shl    $0x4,%ecx
8010944d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109450:	01 ca                	add    %ecx,%edx
80109452:	8b 12                	mov    (%edx),%edx
80109454:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010945a:	83 ec 04             	sub    $0x4,%esp
8010945d:	ff 75 0c             	push   0xc(%ebp)
80109460:	50                   	push   %eax
80109461:	52                   	push   %edx
80109462:	e8 a6 ba ff ff       	call   80104f0d <memmove>
80109467:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
8010946a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010946d:	c1 e0 04             	shl    $0x4,%eax
80109470:	89 c2                	mov    %eax,%edx
80109472:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109475:	01 d0                	add    %edx,%eax
80109477:	8b 55 0c             	mov    0xc(%ebp),%edx
8010947a:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
8010947e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109481:	c1 e0 04             	shl    $0x4,%eax
80109484:	89 c2                	mov    %eax,%edx
80109486:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109489:	01 d0                	add    %edx,%eax
8010948b:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
8010948f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109492:	c1 e0 04             	shl    $0x4,%eax
80109495:	89 c2                	mov    %eax,%edx
80109497:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010949a:	01 d0                	add    %edx,%eax
8010949c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801094a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094a3:	c1 e0 04             	shl    $0x4,%eax
801094a6:	89 c2                	mov    %eax,%edx
801094a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094ab:	01 d0                	add    %edx,%eax
801094ad:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801094b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094b4:	c1 e0 04             	shl    $0x4,%eax
801094b7:	89 c2                	mov    %eax,%edx
801094b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094bc:	01 d0                	add    %edx,%eax
801094be:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
801094c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094c7:	c1 e0 04             	shl    $0x4,%eax
801094ca:	89 c2                	mov    %eax,%edx
801094cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094cf:	01 d0                	add    %edx,%eax
801094d1:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801094d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094d8:	8b 00                	mov    (%eax),%eax
801094da:	83 c0 01             	add    $0x1,%eax
801094dd:	0f b6 d0             	movzbl %al,%edx
801094e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094e3:	89 10                	mov    %edx,(%eax)
    return len;
801094e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801094e8:	eb 05                	jmp    801094ef <i8254_send+0x119>
  }else{
    return -1;
801094ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801094ef:	c9                   	leave  
801094f0:	c3                   	ret    

801094f1 <i8254_intr>:

void i8254_intr(){
801094f1:	55                   	push   %ebp
801094f2:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801094f4:	a1 98 e7 30 80       	mov    0x8030e798,%eax
801094f9:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801094ff:	90                   	nop
80109500:	5d                   	pop    %ebp
80109501:	c3                   	ret    

80109502 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109502:	55                   	push   %ebp
80109503:	89 e5                	mov    %esp,%ebp
80109505:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80109508:	8b 45 08             	mov    0x8(%ebp),%eax
8010950b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
8010950e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109511:	0f b7 00             	movzwl (%eax),%eax
80109514:	66 3d 00 01          	cmp    $0x100,%ax
80109518:	74 0a                	je     80109524 <arp_proc+0x22>
8010951a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010951f:	e9 4f 01 00 00       	jmp    80109673 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109527:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010952b:	66 83 f8 08          	cmp    $0x8,%ax
8010952f:	74 0a                	je     8010953b <arp_proc+0x39>
80109531:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109536:	e9 38 01 00 00       	jmp    80109673 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
8010953b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010953e:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109542:	3c 06                	cmp    $0x6,%al
80109544:	74 0a                	je     80109550 <arp_proc+0x4e>
80109546:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010954b:	e9 23 01 00 00       	jmp    80109673 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109553:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109557:	3c 04                	cmp    $0x4,%al
80109559:	74 0a                	je     80109565 <arp_proc+0x63>
8010955b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109560:	e9 0e 01 00 00       	jmp    80109673 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109565:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109568:	83 c0 18             	add    $0x18,%eax
8010956b:	83 ec 04             	sub    $0x4,%esp
8010956e:	6a 04                	push   $0x4
80109570:	50                   	push   %eax
80109571:	68 04 f5 10 80       	push   $0x8010f504
80109576:	e8 3a b9 ff ff       	call   80104eb5 <memcmp>
8010957b:	83 c4 10             	add    $0x10,%esp
8010957e:	85 c0                	test   %eax,%eax
80109580:	74 27                	je     801095a9 <arp_proc+0xa7>
80109582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109585:	83 c0 0e             	add    $0xe,%eax
80109588:	83 ec 04             	sub    $0x4,%esp
8010958b:	6a 04                	push   $0x4
8010958d:	50                   	push   %eax
8010958e:	68 04 f5 10 80       	push   $0x8010f504
80109593:	e8 1d b9 ff ff       	call   80104eb5 <memcmp>
80109598:	83 c4 10             	add    $0x10,%esp
8010959b:	85 c0                	test   %eax,%eax
8010959d:	74 0a                	je     801095a9 <arp_proc+0xa7>
8010959f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801095a4:	e9 ca 00 00 00       	jmp    80109673 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801095a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ac:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801095b0:	66 3d 00 01          	cmp    $0x100,%ax
801095b4:	75 69                	jne    8010961f <arp_proc+0x11d>
801095b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b9:	83 c0 18             	add    $0x18,%eax
801095bc:	83 ec 04             	sub    $0x4,%esp
801095bf:	6a 04                	push   $0x4
801095c1:	50                   	push   %eax
801095c2:	68 04 f5 10 80       	push   $0x8010f504
801095c7:	e8 e9 b8 ff ff       	call   80104eb5 <memcmp>
801095cc:	83 c4 10             	add    $0x10,%esp
801095cf:	85 c0                	test   %eax,%eax
801095d1:	75 4c                	jne    8010961f <arp_proc+0x11d>
    uint send = (uint)kalloc();
801095d3:	e8 b0 91 ff ff       	call   80102788 <kalloc>
801095d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801095db:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801095e2:	83 ec 04             	sub    $0x4,%esp
801095e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801095e8:	50                   	push   %eax
801095e9:	ff 75 f0             	push   -0x10(%ebp)
801095ec:	ff 75 f4             	push   -0xc(%ebp)
801095ef:	e8 1f 04 00 00       	call   80109a13 <arp_reply_pkt_create>
801095f4:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801095f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801095fa:	83 ec 08             	sub    $0x8,%esp
801095fd:	50                   	push   %eax
801095fe:	ff 75 f0             	push   -0x10(%ebp)
80109601:	e8 d0 fd ff ff       	call   801093d6 <i8254_send>
80109606:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109609:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010960c:	83 ec 0c             	sub    $0xc,%esp
8010960f:	50                   	push   %eax
80109610:	e8 d9 90 ff ff       	call   801026ee <kfree>
80109615:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109618:	b8 02 00 00 00       	mov    $0x2,%eax
8010961d:	eb 54                	jmp    80109673 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010961f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109622:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109626:	66 3d 00 02          	cmp    $0x200,%ax
8010962a:	75 42                	jne    8010966e <arp_proc+0x16c>
8010962c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010962f:	83 c0 18             	add    $0x18,%eax
80109632:	83 ec 04             	sub    $0x4,%esp
80109635:	6a 04                	push   $0x4
80109637:	50                   	push   %eax
80109638:	68 04 f5 10 80       	push   $0x8010f504
8010963d:	e8 73 b8 ff ff       	call   80104eb5 <memcmp>
80109642:	83 c4 10             	add    $0x10,%esp
80109645:	85 c0                	test   %eax,%eax
80109647:	75 25                	jne    8010966e <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80109649:	83 ec 0c             	sub    $0xc,%esp
8010964c:	68 1c c9 10 80       	push   $0x8010c91c
80109651:	e8 9e 6d ff ff       	call   801003f4 <cprintf>
80109656:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80109659:	83 ec 0c             	sub    $0xc,%esp
8010965c:	ff 75 f4             	push   -0xc(%ebp)
8010965f:	e8 af 01 00 00       	call   80109813 <arp_table_update>
80109664:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109667:	b8 01 00 00 00       	mov    $0x1,%eax
8010966c:	eb 05                	jmp    80109673 <arp_proc+0x171>
  }else{
    return -1;
8010966e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109673:	c9                   	leave  
80109674:	c3                   	ret    

80109675 <arp_scan>:

void arp_scan(){
80109675:	55                   	push   %ebp
80109676:	89 e5                	mov    %esp,%ebp
80109678:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
8010967b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109682:	eb 6f                	jmp    801096f3 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109684:	e8 ff 90 ff ff       	call   80102788 <kalloc>
80109689:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
8010968c:	83 ec 04             	sub    $0x4,%esp
8010968f:	ff 75 f4             	push   -0xc(%ebp)
80109692:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109695:	50                   	push   %eax
80109696:	ff 75 ec             	push   -0x14(%ebp)
80109699:	e8 62 00 00 00       	call   80109700 <arp_broadcast>
8010969e:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801096a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096a4:	83 ec 08             	sub    $0x8,%esp
801096a7:	50                   	push   %eax
801096a8:	ff 75 ec             	push   -0x14(%ebp)
801096ab:	e8 26 fd ff ff       	call   801093d6 <i8254_send>
801096b0:	83 c4 10             	add    $0x10,%esp
801096b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801096b6:	eb 22                	jmp    801096da <arp_scan+0x65>
      microdelay(1);
801096b8:	83 ec 0c             	sub    $0xc,%esp
801096bb:	6a 01                	push   $0x1
801096bd:	e8 5d 94 ff ff       	call   80102b1f <microdelay>
801096c2:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801096c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096c8:	83 ec 08             	sub    $0x8,%esp
801096cb:	50                   	push   %eax
801096cc:	ff 75 ec             	push   -0x14(%ebp)
801096cf:	e8 02 fd ff ff       	call   801093d6 <i8254_send>
801096d4:	83 c4 10             	add    $0x10,%esp
801096d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801096da:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801096de:	74 d8                	je     801096b8 <arp_scan+0x43>
    }
    kfree((char *)send);
801096e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096e3:	83 ec 0c             	sub    $0xc,%esp
801096e6:	50                   	push   %eax
801096e7:	e8 02 90 ff ff       	call   801026ee <kfree>
801096ec:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801096ef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801096f3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801096fa:	7e 88                	jle    80109684 <arp_scan+0xf>
  }
}
801096fc:	90                   	nop
801096fd:	90                   	nop
801096fe:	c9                   	leave  
801096ff:	c3                   	ret    

80109700 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109700:	55                   	push   %ebp
80109701:	89 e5                	mov    %esp,%ebp
80109703:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109706:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
8010970a:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
8010970e:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109712:	8b 45 10             	mov    0x10(%ebp),%eax
80109715:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109718:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
8010971f:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109725:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010972c:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109732:	8b 45 0c             	mov    0xc(%ebp),%eax
80109735:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010973b:	8b 45 08             	mov    0x8(%ebp),%eax
8010973e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109741:	8b 45 08             	mov    0x8(%ebp),%eax
80109744:	83 c0 0e             	add    $0xe,%eax
80109747:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010974a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010974d:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109754:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010975b:	83 ec 04             	sub    $0x4,%esp
8010975e:	6a 06                	push   $0x6
80109760:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109763:	52                   	push   %edx
80109764:	50                   	push   %eax
80109765:	e8 a3 b7 ff ff       	call   80104f0d <memmove>
8010976a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010976d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109770:	83 c0 06             	add    $0x6,%eax
80109773:	83 ec 04             	sub    $0x4,%esp
80109776:	6a 06                	push   $0x6
80109778:	68 90 e7 30 80       	push   $0x8030e790
8010977d:	50                   	push   %eax
8010977e:	e8 8a b7 ff ff       	call   80104f0d <memmove>
80109783:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109786:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109789:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010978e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109791:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109797:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010979a:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010979e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097a1:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801097a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097a8:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801097ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097b1:	8d 50 12             	lea    0x12(%eax),%edx
801097b4:	83 ec 04             	sub    $0x4,%esp
801097b7:	6a 06                	push   $0x6
801097b9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801097bc:	50                   	push   %eax
801097bd:	52                   	push   %edx
801097be:	e8 4a b7 ff ff       	call   80104f0d <memmove>
801097c3:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801097c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097c9:	8d 50 18             	lea    0x18(%eax),%edx
801097cc:	83 ec 04             	sub    $0x4,%esp
801097cf:	6a 04                	push   $0x4
801097d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801097d4:	50                   	push   %eax
801097d5:	52                   	push   %edx
801097d6:	e8 32 b7 ff ff       	call   80104f0d <memmove>
801097db:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801097de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097e1:	83 c0 08             	add    $0x8,%eax
801097e4:	83 ec 04             	sub    $0x4,%esp
801097e7:	6a 06                	push   $0x6
801097e9:	68 90 e7 30 80       	push   $0x8030e790
801097ee:	50                   	push   %eax
801097ef:	e8 19 b7 ff ff       	call   80104f0d <memmove>
801097f4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801097f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097fa:	83 c0 0e             	add    $0xe,%eax
801097fd:	83 ec 04             	sub    $0x4,%esp
80109800:	6a 04                	push   $0x4
80109802:	68 04 f5 10 80       	push   $0x8010f504
80109807:	50                   	push   %eax
80109808:	e8 00 b7 ff ff       	call   80104f0d <memmove>
8010980d:	83 c4 10             	add    $0x10,%esp
}
80109810:	90                   	nop
80109811:	c9                   	leave  
80109812:	c3                   	ret    

80109813 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109813:	55                   	push   %ebp
80109814:	89 e5                	mov    %esp,%ebp
80109816:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109819:	8b 45 08             	mov    0x8(%ebp),%eax
8010981c:	83 c0 0e             	add    $0xe,%eax
8010981f:	83 ec 0c             	sub    $0xc,%esp
80109822:	50                   	push   %eax
80109823:	e8 bc 00 00 00       	call   801098e4 <arp_table_search>
80109828:	83 c4 10             	add    $0x10,%esp
8010982b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010982e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109832:	78 2d                	js     80109861 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109834:	8b 45 08             	mov    0x8(%ebp),%eax
80109837:	8d 48 08             	lea    0x8(%eax),%ecx
8010983a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010983d:	89 d0                	mov    %edx,%eax
8010983f:	c1 e0 02             	shl    $0x2,%eax
80109842:	01 d0                	add    %edx,%eax
80109844:	01 c0                	add    %eax,%eax
80109846:	01 d0                	add    %edx,%eax
80109848:	05 a0 e7 30 80       	add    $0x8030e7a0,%eax
8010984d:	83 c0 04             	add    $0x4,%eax
80109850:	83 ec 04             	sub    $0x4,%esp
80109853:	6a 06                	push   $0x6
80109855:	51                   	push   %ecx
80109856:	50                   	push   %eax
80109857:	e8 b1 b6 ff ff       	call   80104f0d <memmove>
8010985c:	83 c4 10             	add    $0x10,%esp
8010985f:	eb 70                	jmp    801098d1 <arp_table_update+0xbe>
  }else{
    index += 1;
80109861:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109865:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109868:	8b 45 08             	mov    0x8(%ebp),%eax
8010986b:	8d 48 08             	lea    0x8(%eax),%ecx
8010986e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109871:	89 d0                	mov    %edx,%eax
80109873:	c1 e0 02             	shl    $0x2,%eax
80109876:	01 d0                	add    %edx,%eax
80109878:	01 c0                	add    %eax,%eax
8010987a:	01 d0                	add    %edx,%eax
8010987c:	05 a0 e7 30 80       	add    $0x8030e7a0,%eax
80109881:	83 c0 04             	add    $0x4,%eax
80109884:	83 ec 04             	sub    $0x4,%esp
80109887:	6a 06                	push   $0x6
80109889:	51                   	push   %ecx
8010988a:	50                   	push   %eax
8010988b:	e8 7d b6 ff ff       	call   80104f0d <memmove>
80109890:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109893:	8b 45 08             	mov    0x8(%ebp),%eax
80109896:	8d 48 0e             	lea    0xe(%eax),%ecx
80109899:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010989c:	89 d0                	mov    %edx,%eax
8010989e:	c1 e0 02             	shl    $0x2,%eax
801098a1:	01 d0                	add    %edx,%eax
801098a3:	01 c0                	add    %eax,%eax
801098a5:	01 d0                	add    %edx,%eax
801098a7:	05 a0 e7 30 80       	add    $0x8030e7a0,%eax
801098ac:	83 ec 04             	sub    $0x4,%esp
801098af:	6a 04                	push   $0x4
801098b1:	51                   	push   %ecx
801098b2:	50                   	push   %eax
801098b3:	e8 55 b6 ff ff       	call   80104f0d <memmove>
801098b8:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801098bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801098be:	89 d0                	mov    %edx,%eax
801098c0:	c1 e0 02             	shl    $0x2,%eax
801098c3:	01 d0                	add    %edx,%eax
801098c5:	01 c0                	add    %eax,%eax
801098c7:	01 d0                	add    %edx,%eax
801098c9:	05 aa e7 30 80       	add    $0x8030e7aa,%eax
801098ce:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801098d1:	83 ec 0c             	sub    $0xc,%esp
801098d4:	68 a0 e7 30 80       	push   $0x8030e7a0
801098d9:	e8 83 00 00 00       	call   80109961 <print_arp_table>
801098de:	83 c4 10             	add    $0x10,%esp
}
801098e1:	90                   	nop
801098e2:	c9                   	leave  
801098e3:	c3                   	ret    

801098e4 <arp_table_search>:

int arp_table_search(uchar *ip){
801098e4:	55                   	push   %ebp
801098e5:	89 e5                	mov    %esp,%ebp
801098e7:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801098ea:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801098f1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801098f8:	eb 59                	jmp    80109953 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801098fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801098fd:	89 d0                	mov    %edx,%eax
801098ff:	c1 e0 02             	shl    $0x2,%eax
80109902:	01 d0                	add    %edx,%eax
80109904:	01 c0                	add    %eax,%eax
80109906:	01 d0                	add    %edx,%eax
80109908:	05 a0 e7 30 80       	add    $0x8030e7a0,%eax
8010990d:	83 ec 04             	sub    $0x4,%esp
80109910:	6a 04                	push   $0x4
80109912:	ff 75 08             	push   0x8(%ebp)
80109915:	50                   	push   %eax
80109916:	e8 9a b5 ff ff       	call   80104eb5 <memcmp>
8010991b:	83 c4 10             	add    $0x10,%esp
8010991e:	85 c0                	test   %eax,%eax
80109920:	75 05                	jne    80109927 <arp_table_search+0x43>
      return i;
80109922:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109925:	eb 38                	jmp    8010995f <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109927:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010992a:	89 d0                	mov    %edx,%eax
8010992c:	c1 e0 02             	shl    $0x2,%eax
8010992f:	01 d0                	add    %edx,%eax
80109931:	01 c0                	add    %eax,%eax
80109933:	01 d0                	add    %edx,%eax
80109935:	05 aa e7 30 80       	add    $0x8030e7aa,%eax
8010993a:	0f b6 00             	movzbl (%eax),%eax
8010993d:	84 c0                	test   %al,%al
8010993f:	75 0e                	jne    8010994f <arp_table_search+0x6b>
80109941:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109945:	75 08                	jne    8010994f <arp_table_search+0x6b>
      empty = -i;
80109947:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010994a:	f7 d8                	neg    %eax
8010994c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010994f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109953:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109957:	7e a1                	jle    801098fa <arp_table_search+0x16>
    }
  }
  return empty-1;
80109959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010995c:	83 e8 01             	sub    $0x1,%eax
}
8010995f:	c9                   	leave  
80109960:	c3                   	ret    

80109961 <print_arp_table>:

void print_arp_table(){
80109961:	55                   	push   %ebp
80109962:	89 e5                	mov    %esp,%ebp
80109964:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109967:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010996e:	e9 92 00 00 00       	jmp    80109a05 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109973:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109976:	89 d0                	mov    %edx,%eax
80109978:	c1 e0 02             	shl    $0x2,%eax
8010997b:	01 d0                	add    %edx,%eax
8010997d:	01 c0                	add    %eax,%eax
8010997f:	01 d0                	add    %edx,%eax
80109981:	05 aa e7 30 80       	add    $0x8030e7aa,%eax
80109986:	0f b6 00             	movzbl (%eax),%eax
80109989:	84 c0                	test   %al,%al
8010998b:	74 74                	je     80109a01 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010998d:	83 ec 08             	sub    $0x8,%esp
80109990:	ff 75 f4             	push   -0xc(%ebp)
80109993:	68 2f c9 10 80       	push   $0x8010c92f
80109998:	e8 57 6a ff ff       	call   801003f4 <cprintf>
8010999d:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801099a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099a3:	89 d0                	mov    %edx,%eax
801099a5:	c1 e0 02             	shl    $0x2,%eax
801099a8:	01 d0                	add    %edx,%eax
801099aa:	01 c0                	add    %eax,%eax
801099ac:	01 d0                	add    %edx,%eax
801099ae:	05 a0 e7 30 80       	add    $0x8030e7a0,%eax
801099b3:	83 ec 0c             	sub    $0xc,%esp
801099b6:	50                   	push   %eax
801099b7:	e8 54 02 00 00       	call   80109c10 <print_ipv4>
801099bc:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801099bf:	83 ec 0c             	sub    $0xc,%esp
801099c2:	68 3e c9 10 80       	push   $0x8010c93e
801099c7:	e8 28 6a ff ff       	call   801003f4 <cprintf>
801099cc:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801099cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099d2:	89 d0                	mov    %edx,%eax
801099d4:	c1 e0 02             	shl    $0x2,%eax
801099d7:	01 d0                	add    %edx,%eax
801099d9:	01 c0                	add    %eax,%eax
801099db:	01 d0                	add    %edx,%eax
801099dd:	05 a0 e7 30 80       	add    $0x8030e7a0,%eax
801099e2:	83 c0 04             	add    $0x4,%eax
801099e5:	83 ec 0c             	sub    $0xc,%esp
801099e8:	50                   	push   %eax
801099e9:	e8 70 02 00 00       	call   80109c5e <print_mac>
801099ee:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801099f1:	83 ec 0c             	sub    $0xc,%esp
801099f4:	68 40 c9 10 80       	push   $0x8010c940
801099f9:	e8 f6 69 ff ff       	call   801003f4 <cprintf>
801099fe:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109a01:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109a05:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109a09:	0f 8e 64 ff ff ff    	jle    80109973 <print_arp_table+0x12>
    }
  }
}
80109a0f:	90                   	nop
80109a10:	90                   	nop
80109a11:	c9                   	leave  
80109a12:	c3                   	ret    

80109a13 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109a13:	55                   	push   %ebp
80109a14:	89 e5                	mov    %esp,%ebp
80109a16:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109a19:	8b 45 10             	mov    0x10(%ebp),%eax
80109a1c:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109a22:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a25:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109a28:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a2b:	83 c0 0e             	add    $0xe,%eax
80109a2e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a34:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a3b:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80109a42:	8d 50 08             	lea    0x8(%eax),%edx
80109a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a48:	83 ec 04             	sub    $0x4,%esp
80109a4b:	6a 06                	push   $0x6
80109a4d:	52                   	push   %edx
80109a4e:	50                   	push   %eax
80109a4f:	e8 b9 b4 ff ff       	call   80104f0d <memmove>
80109a54:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a5a:	83 c0 06             	add    $0x6,%eax
80109a5d:	83 ec 04             	sub    $0x4,%esp
80109a60:	6a 06                	push   $0x6
80109a62:	68 90 e7 30 80       	push   $0x8030e790
80109a67:	50                   	push   %eax
80109a68:	e8 a0 b4 ff ff       	call   80104f0d <memmove>
80109a6d:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a73:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a7b:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a84:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a8b:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a92:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109a98:	8b 45 08             	mov    0x8(%ebp),%eax
80109a9b:	8d 50 08             	lea    0x8(%eax),%edx
80109a9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aa1:	83 c0 12             	add    $0x12,%eax
80109aa4:	83 ec 04             	sub    $0x4,%esp
80109aa7:	6a 06                	push   $0x6
80109aa9:	52                   	push   %edx
80109aaa:	50                   	push   %eax
80109aab:	e8 5d b4 ff ff       	call   80104f0d <memmove>
80109ab0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80109ab6:	8d 50 0e             	lea    0xe(%eax),%edx
80109ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109abc:	83 c0 18             	add    $0x18,%eax
80109abf:	83 ec 04             	sub    $0x4,%esp
80109ac2:	6a 04                	push   $0x4
80109ac4:	52                   	push   %edx
80109ac5:	50                   	push   %eax
80109ac6:	e8 42 b4 ff ff       	call   80104f0d <memmove>
80109acb:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109ace:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ad1:	83 c0 08             	add    $0x8,%eax
80109ad4:	83 ec 04             	sub    $0x4,%esp
80109ad7:	6a 06                	push   $0x6
80109ad9:	68 90 e7 30 80       	push   $0x8030e790
80109ade:	50                   	push   %eax
80109adf:	e8 29 b4 ff ff       	call   80104f0d <memmove>
80109ae4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109ae7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aea:	83 c0 0e             	add    $0xe,%eax
80109aed:	83 ec 04             	sub    $0x4,%esp
80109af0:	6a 04                	push   $0x4
80109af2:	68 04 f5 10 80       	push   $0x8010f504
80109af7:	50                   	push   %eax
80109af8:	e8 10 b4 ff ff       	call   80104f0d <memmove>
80109afd:	83 c4 10             	add    $0x10,%esp
}
80109b00:	90                   	nop
80109b01:	c9                   	leave  
80109b02:	c3                   	ret    

80109b03 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109b03:	55                   	push   %ebp
80109b04:	89 e5                	mov    %esp,%ebp
80109b06:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109b09:	83 ec 0c             	sub    $0xc,%esp
80109b0c:	68 42 c9 10 80       	push   $0x8010c942
80109b11:	e8 de 68 ff ff       	call   801003f4 <cprintf>
80109b16:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109b19:	8b 45 08             	mov    0x8(%ebp),%eax
80109b1c:	83 c0 0e             	add    $0xe,%eax
80109b1f:	83 ec 0c             	sub    $0xc,%esp
80109b22:	50                   	push   %eax
80109b23:	e8 e8 00 00 00       	call   80109c10 <print_ipv4>
80109b28:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b2b:	83 ec 0c             	sub    $0xc,%esp
80109b2e:	68 40 c9 10 80       	push   $0x8010c940
80109b33:	e8 bc 68 ff ff       	call   801003f4 <cprintf>
80109b38:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b3e:	83 c0 08             	add    $0x8,%eax
80109b41:	83 ec 0c             	sub    $0xc,%esp
80109b44:	50                   	push   %eax
80109b45:	e8 14 01 00 00       	call   80109c5e <print_mac>
80109b4a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b4d:	83 ec 0c             	sub    $0xc,%esp
80109b50:	68 40 c9 10 80       	push   $0x8010c940
80109b55:	e8 9a 68 ff ff       	call   801003f4 <cprintf>
80109b5a:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109b5d:	83 ec 0c             	sub    $0xc,%esp
80109b60:	68 59 c9 10 80       	push   $0x8010c959
80109b65:	e8 8a 68 ff ff       	call   801003f4 <cprintf>
80109b6a:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80109b70:	83 c0 18             	add    $0x18,%eax
80109b73:	83 ec 0c             	sub    $0xc,%esp
80109b76:	50                   	push   %eax
80109b77:	e8 94 00 00 00       	call   80109c10 <print_ipv4>
80109b7c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b7f:	83 ec 0c             	sub    $0xc,%esp
80109b82:	68 40 c9 10 80       	push   $0x8010c940
80109b87:	e8 68 68 ff ff       	call   801003f4 <cprintf>
80109b8c:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80109b92:	83 c0 12             	add    $0x12,%eax
80109b95:	83 ec 0c             	sub    $0xc,%esp
80109b98:	50                   	push   %eax
80109b99:	e8 c0 00 00 00       	call   80109c5e <print_mac>
80109b9e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109ba1:	83 ec 0c             	sub    $0xc,%esp
80109ba4:	68 40 c9 10 80       	push   $0x8010c940
80109ba9:	e8 46 68 ff ff       	call   801003f4 <cprintf>
80109bae:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109bb1:	83 ec 0c             	sub    $0xc,%esp
80109bb4:	68 70 c9 10 80       	push   $0x8010c970
80109bb9:	e8 36 68 ff ff       	call   801003f4 <cprintf>
80109bbe:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109bc1:	8b 45 08             	mov    0x8(%ebp),%eax
80109bc4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109bc8:	66 3d 00 01          	cmp    $0x100,%ax
80109bcc:	75 12                	jne    80109be0 <print_arp_info+0xdd>
80109bce:	83 ec 0c             	sub    $0xc,%esp
80109bd1:	68 7c c9 10 80       	push   $0x8010c97c
80109bd6:	e8 19 68 ff ff       	call   801003f4 <cprintf>
80109bdb:	83 c4 10             	add    $0x10,%esp
80109bde:	eb 1d                	jmp    80109bfd <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109be0:	8b 45 08             	mov    0x8(%ebp),%eax
80109be3:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109be7:	66 3d 00 02          	cmp    $0x200,%ax
80109beb:	75 10                	jne    80109bfd <print_arp_info+0xfa>
    cprintf("Reply\n");
80109bed:	83 ec 0c             	sub    $0xc,%esp
80109bf0:	68 85 c9 10 80       	push   $0x8010c985
80109bf5:	e8 fa 67 ff ff       	call   801003f4 <cprintf>
80109bfa:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109bfd:	83 ec 0c             	sub    $0xc,%esp
80109c00:	68 40 c9 10 80       	push   $0x8010c940
80109c05:	e8 ea 67 ff ff       	call   801003f4 <cprintf>
80109c0a:	83 c4 10             	add    $0x10,%esp
}
80109c0d:	90                   	nop
80109c0e:	c9                   	leave  
80109c0f:	c3                   	ret    

80109c10 <print_ipv4>:

void print_ipv4(uchar *ip){
80109c10:	55                   	push   %ebp
80109c11:	89 e5                	mov    %esp,%ebp
80109c13:	53                   	push   %ebx
80109c14:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109c17:	8b 45 08             	mov    0x8(%ebp),%eax
80109c1a:	83 c0 03             	add    $0x3,%eax
80109c1d:	0f b6 00             	movzbl (%eax),%eax
80109c20:	0f b6 d8             	movzbl %al,%ebx
80109c23:	8b 45 08             	mov    0x8(%ebp),%eax
80109c26:	83 c0 02             	add    $0x2,%eax
80109c29:	0f b6 00             	movzbl (%eax),%eax
80109c2c:	0f b6 c8             	movzbl %al,%ecx
80109c2f:	8b 45 08             	mov    0x8(%ebp),%eax
80109c32:	83 c0 01             	add    $0x1,%eax
80109c35:	0f b6 00             	movzbl (%eax),%eax
80109c38:	0f b6 d0             	movzbl %al,%edx
80109c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c3e:	0f b6 00             	movzbl (%eax),%eax
80109c41:	0f b6 c0             	movzbl %al,%eax
80109c44:	83 ec 0c             	sub    $0xc,%esp
80109c47:	53                   	push   %ebx
80109c48:	51                   	push   %ecx
80109c49:	52                   	push   %edx
80109c4a:	50                   	push   %eax
80109c4b:	68 8c c9 10 80       	push   $0x8010c98c
80109c50:	e8 9f 67 ff ff       	call   801003f4 <cprintf>
80109c55:	83 c4 20             	add    $0x20,%esp
}
80109c58:	90                   	nop
80109c59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c5c:	c9                   	leave  
80109c5d:	c3                   	ret    

80109c5e <print_mac>:

void print_mac(uchar *mac){
80109c5e:	55                   	push   %ebp
80109c5f:	89 e5                	mov    %esp,%ebp
80109c61:	57                   	push   %edi
80109c62:	56                   	push   %esi
80109c63:	53                   	push   %ebx
80109c64:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109c67:	8b 45 08             	mov    0x8(%ebp),%eax
80109c6a:	83 c0 05             	add    $0x5,%eax
80109c6d:	0f b6 00             	movzbl (%eax),%eax
80109c70:	0f b6 f8             	movzbl %al,%edi
80109c73:	8b 45 08             	mov    0x8(%ebp),%eax
80109c76:	83 c0 04             	add    $0x4,%eax
80109c79:	0f b6 00             	movzbl (%eax),%eax
80109c7c:	0f b6 f0             	movzbl %al,%esi
80109c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80109c82:	83 c0 03             	add    $0x3,%eax
80109c85:	0f b6 00             	movzbl (%eax),%eax
80109c88:	0f b6 d8             	movzbl %al,%ebx
80109c8b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c8e:	83 c0 02             	add    $0x2,%eax
80109c91:	0f b6 00             	movzbl (%eax),%eax
80109c94:	0f b6 c8             	movzbl %al,%ecx
80109c97:	8b 45 08             	mov    0x8(%ebp),%eax
80109c9a:	83 c0 01             	add    $0x1,%eax
80109c9d:	0f b6 00             	movzbl (%eax),%eax
80109ca0:	0f b6 d0             	movzbl %al,%edx
80109ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80109ca6:	0f b6 00             	movzbl (%eax),%eax
80109ca9:	0f b6 c0             	movzbl %al,%eax
80109cac:	83 ec 04             	sub    $0x4,%esp
80109caf:	57                   	push   %edi
80109cb0:	56                   	push   %esi
80109cb1:	53                   	push   %ebx
80109cb2:	51                   	push   %ecx
80109cb3:	52                   	push   %edx
80109cb4:	50                   	push   %eax
80109cb5:	68 a4 c9 10 80       	push   $0x8010c9a4
80109cba:	e8 35 67 ff ff       	call   801003f4 <cprintf>
80109cbf:	83 c4 20             	add    $0x20,%esp
}
80109cc2:	90                   	nop
80109cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109cc6:	5b                   	pop    %ebx
80109cc7:	5e                   	pop    %esi
80109cc8:	5f                   	pop    %edi
80109cc9:	5d                   	pop    %ebp
80109cca:	c3                   	ret    

80109ccb <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109ccb:	55                   	push   %ebp
80109ccc:	89 e5                	mov    %esp,%ebp
80109cce:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109cd1:	8b 45 08             	mov    0x8(%ebp),%eax
80109cd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80109cda:	83 c0 0e             	add    $0xe,%eax
80109cdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ce3:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109ce7:	3c 08                	cmp    $0x8,%al
80109ce9:	75 1b                	jne    80109d06 <eth_proc+0x3b>
80109ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cee:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109cf2:	3c 06                	cmp    $0x6,%al
80109cf4:	75 10                	jne    80109d06 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109cf6:	83 ec 0c             	sub    $0xc,%esp
80109cf9:	ff 75 f0             	push   -0x10(%ebp)
80109cfc:	e8 01 f8 ff ff       	call   80109502 <arp_proc>
80109d01:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109d04:	eb 24                	jmp    80109d2a <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d09:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109d0d:	3c 08                	cmp    $0x8,%al
80109d0f:	75 19                	jne    80109d2a <eth_proc+0x5f>
80109d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d14:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d18:	84 c0                	test   %al,%al
80109d1a:	75 0e                	jne    80109d2a <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109d1c:	83 ec 0c             	sub    $0xc,%esp
80109d1f:	ff 75 08             	push   0x8(%ebp)
80109d22:	e8 a3 00 00 00       	call   80109dca <ipv4_proc>
80109d27:	83 c4 10             	add    $0x10,%esp
}
80109d2a:	90                   	nop
80109d2b:	c9                   	leave  
80109d2c:	c3                   	ret    

80109d2d <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109d2d:	55                   	push   %ebp
80109d2e:	89 e5                	mov    %esp,%ebp
80109d30:	83 ec 04             	sub    $0x4,%esp
80109d33:	8b 45 08             	mov    0x8(%ebp),%eax
80109d36:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109d3a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d3e:	c1 e0 08             	shl    $0x8,%eax
80109d41:	89 c2                	mov    %eax,%edx
80109d43:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d47:	66 c1 e8 08          	shr    $0x8,%ax
80109d4b:	01 d0                	add    %edx,%eax
}
80109d4d:	c9                   	leave  
80109d4e:	c3                   	ret    

80109d4f <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109d4f:	55                   	push   %ebp
80109d50:	89 e5                	mov    %esp,%ebp
80109d52:	83 ec 04             	sub    $0x4,%esp
80109d55:	8b 45 08             	mov    0x8(%ebp),%eax
80109d58:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109d5c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d60:	c1 e0 08             	shl    $0x8,%eax
80109d63:	89 c2                	mov    %eax,%edx
80109d65:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d69:	66 c1 e8 08          	shr    $0x8,%ax
80109d6d:	01 d0                	add    %edx,%eax
}
80109d6f:	c9                   	leave  
80109d70:	c3                   	ret    

80109d71 <H2N_uint>:

uint H2N_uint(uint value){
80109d71:	55                   	push   %ebp
80109d72:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109d74:	8b 45 08             	mov    0x8(%ebp),%eax
80109d77:	c1 e0 18             	shl    $0x18,%eax
80109d7a:	25 00 00 00 0f       	and    $0xf000000,%eax
80109d7f:	89 c2                	mov    %eax,%edx
80109d81:	8b 45 08             	mov    0x8(%ebp),%eax
80109d84:	c1 e0 08             	shl    $0x8,%eax
80109d87:	25 00 f0 00 00       	and    $0xf000,%eax
80109d8c:	09 c2                	or     %eax,%edx
80109d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80109d91:	c1 e8 08             	shr    $0x8,%eax
80109d94:	83 e0 0f             	and    $0xf,%eax
80109d97:	01 d0                	add    %edx,%eax
}
80109d99:	5d                   	pop    %ebp
80109d9a:	c3                   	ret    

80109d9b <N2H_uint>:

uint N2H_uint(uint value){
80109d9b:	55                   	push   %ebp
80109d9c:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109d9e:	8b 45 08             	mov    0x8(%ebp),%eax
80109da1:	c1 e0 18             	shl    $0x18,%eax
80109da4:	89 c2                	mov    %eax,%edx
80109da6:	8b 45 08             	mov    0x8(%ebp),%eax
80109da9:	c1 e0 08             	shl    $0x8,%eax
80109dac:	25 00 00 ff 00       	and    $0xff0000,%eax
80109db1:	01 c2                	add    %eax,%edx
80109db3:	8b 45 08             	mov    0x8(%ebp),%eax
80109db6:	c1 e8 08             	shr    $0x8,%eax
80109db9:	25 00 ff 00 00       	and    $0xff00,%eax
80109dbe:	01 c2                	add    %eax,%edx
80109dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80109dc3:	c1 e8 18             	shr    $0x18,%eax
80109dc6:	01 d0                	add    %edx,%eax
}
80109dc8:	5d                   	pop    %ebp
80109dc9:	c3                   	ret    

80109dca <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109dca:	55                   	push   %ebp
80109dcb:	89 e5                	mov    %esp,%ebp
80109dcd:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80109dd3:	83 c0 0e             	add    $0xe,%eax
80109dd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ddc:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109de0:	0f b7 d0             	movzwl %ax,%edx
80109de3:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109de8:	39 c2                	cmp    %eax,%edx
80109dea:	74 60                	je     80109e4c <ipv4_proc+0x82>
80109dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109def:	83 c0 0c             	add    $0xc,%eax
80109df2:	83 ec 04             	sub    $0x4,%esp
80109df5:	6a 04                	push   $0x4
80109df7:	50                   	push   %eax
80109df8:	68 04 f5 10 80       	push   $0x8010f504
80109dfd:	e8 b3 b0 ff ff       	call   80104eb5 <memcmp>
80109e02:	83 c4 10             	add    $0x10,%esp
80109e05:	85 c0                	test   %eax,%eax
80109e07:	74 43                	je     80109e4c <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e0c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109e10:	0f b7 c0             	movzwl %ax,%eax
80109e13:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e1b:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109e1f:	3c 01                	cmp    $0x1,%al
80109e21:	75 10                	jne    80109e33 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109e23:	83 ec 0c             	sub    $0xc,%esp
80109e26:	ff 75 08             	push   0x8(%ebp)
80109e29:	e8 a3 00 00 00       	call   80109ed1 <icmp_proc>
80109e2e:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109e31:	eb 19                	jmp    80109e4c <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e36:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109e3a:	3c 06                	cmp    $0x6,%al
80109e3c:	75 0e                	jne    80109e4c <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109e3e:	83 ec 0c             	sub    $0xc,%esp
80109e41:	ff 75 08             	push   0x8(%ebp)
80109e44:	e8 b3 03 00 00       	call   8010a1fc <tcp_proc>
80109e49:	83 c4 10             	add    $0x10,%esp
}
80109e4c:	90                   	nop
80109e4d:	c9                   	leave  
80109e4e:	c3                   	ret    

80109e4f <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109e4f:	55                   	push   %ebp
80109e50:	89 e5                	mov    %esp,%ebp
80109e52:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109e55:	8b 45 08             	mov    0x8(%ebp),%eax
80109e58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e5e:	0f b6 00             	movzbl (%eax),%eax
80109e61:	83 e0 0f             	and    $0xf,%eax
80109e64:	01 c0                	add    %eax,%eax
80109e66:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109e69:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109e70:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109e77:	eb 48                	jmp    80109ec1 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e79:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e7c:	01 c0                	add    %eax,%eax
80109e7e:	89 c2                	mov    %eax,%edx
80109e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e83:	01 d0                	add    %edx,%eax
80109e85:	0f b6 00             	movzbl (%eax),%eax
80109e88:	0f b6 c0             	movzbl %al,%eax
80109e8b:	c1 e0 08             	shl    $0x8,%eax
80109e8e:	89 c2                	mov    %eax,%edx
80109e90:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e93:	01 c0                	add    %eax,%eax
80109e95:	8d 48 01             	lea    0x1(%eax),%ecx
80109e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e9b:	01 c8                	add    %ecx,%eax
80109e9d:	0f b6 00             	movzbl (%eax),%eax
80109ea0:	0f b6 c0             	movzbl %al,%eax
80109ea3:	01 d0                	add    %edx,%eax
80109ea5:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109ea8:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109eaf:	76 0c                	jbe    80109ebd <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109eb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109eb4:	0f b7 c0             	movzwl %ax,%eax
80109eb7:	83 c0 01             	add    $0x1,%eax
80109eba:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109ebd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109ec1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109ec5:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109ec8:	7c af                	jl     80109e79 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109eca:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ecd:	f7 d0                	not    %eax
}
80109ecf:	c9                   	leave  
80109ed0:	c3                   	ret    

80109ed1 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109ed1:	55                   	push   %ebp
80109ed2:	89 e5                	mov    %esp,%ebp
80109ed4:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80109eda:	83 c0 0e             	add    $0xe,%eax
80109edd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ee3:	0f b6 00             	movzbl (%eax),%eax
80109ee6:	0f b6 c0             	movzbl %al,%eax
80109ee9:	83 e0 0f             	and    $0xf,%eax
80109eec:	c1 e0 02             	shl    $0x2,%eax
80109eef:	89 c2                	mov    %eax,%edx
80109ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ef4:	01 d0                	add    %edx,%eax
80109ef6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109efc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109f00:	84 c0                	test   %al,%al
80109f02:	75 4f                	jne    80109f53 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f07:	0f b6 00             	movzbl (%eax),%eax
80109f0a:	3c 08                	cmp    $0x8,%al
80109f0c:	75 45                	jne    80109f53 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109f0e:	e8 75 88 ff ff       	call   80102788 <kalloc>
80109f13:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109f16:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109f1d:	83 ec 04             	sub    $0x4,%esp
80109f20:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109f23:	50                   	push   %eax
80109f24:	ff 75 ec             	push   -0x14(%ebp)
80109f27:	ff 75 08             	push   0x8(%ebp)
80109f2a:	e8 78 00 00 00       	call   80109fa7 <icmp_reply_pkt_create>
80109f2f:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109f32:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f35:	83 ec 08             	sub    $0x8,%esp
80109f38:	50                   	push   %eax
80109f39:	ff 75 ec             	push   -0x14(%ebp)
80109f3c:	e8 95 f4 ff ff       	call   801093d6 <i8254_send>
80109f41:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109f44:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f47:	83 ec 0c             	sub    $0xc,%esp
80109f4a:	50                   	push   %eax
80109f4b:	e8 9e 87 ff ff       	call   801026ee <kfree>
80109f50:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109f53:	90                   	nop
80109f54:	c9                   	leave  
80109f55:	c3                   	ret    

80109f56 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109f56:	55                   	push   %ebp
80109f57:	89 e5                	mov    %esp,%ebp
80109f59:	53                   	push   %ebx
80109f5a:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80109f60:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109f64:	0f b7 c0             	movzwl %ax,%eax
80109f67:	83 ec 0c             	sub    $0xc,%esp
80109f6a:	50                   	push   %eax
80109f6b:	e8 bd fd ff ff       	call   80109d2d <N2H_ushort>
80109f70:	83 c4 10             	add    $0x10,%esp
80109f73:	0f b7 d8             	movzwl %ax,%ebx
80109f76:	8b 45 08             	mov    0x8(%ebp),%eax
80109f79:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109f7d:	0f b7 c0             	movzwl %ax,%eax
80109f80:	83 ec 0c             	sub    $0xc,%esp
80109f83:	50                   	push   %eax
80109f84:	e8 a4 fd ff ff       	call   80109d2d <N2H_ushort>
80109f89:	83 c4 10             	add    $0x10,%esp
80109f8c:	0f b7 c0             	movzwl %ax,%eax
80109f8f:	83 ec 04             	sub    $0x4,%esp
80109f92:	53                   	push   %ebx
80109f93:	50                   	push   %eax
80109f94:	68 c3 c9 10 80       	push   $0x8010c9c3
80109f99:	e8 56 64 ff ff       	call   801003f4 <cprintf>
80109f9e:	83 c4 10             	add    $0x10,%esp
}
80109fa1:	90                   	nop
80109fa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109fa5:	c9                   	leave  
80109fa6:	c3                   	ret    

80109fa7 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109fa7:	55                   	push   %ebp
80109fa8:	89 e5                	mov    %esp,%ebp
80109faa:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109fad:	8b 45 08             	mov    0x8(%ebp),%eax
80109fb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80109fb6:	83 c0 0e             	add    $0xe,%eax
80109fb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109fbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fbf:	0f b6 00             	movzbl (%eax),%eax
80109fc2:	0f b6 c0             	movzbl %al,%eax
80109fc5:	83 e0 0f             	and    $0xf,%eax
80109fc8:	c1 e0 02             	shl    $0x2,%eax
80109fcb:	89 c2                	mov    %eax,%edx
80109fcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fd0:	01 d0                	add    %edx,%eax
80109fd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fd8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fde:	83 c0 0e             	add    $0xe,%eax
80109fe1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109fe4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fe7:	83 c0 14             	add    $0x14,%eax
80109fea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109fed:	8b 45 10             	mov    0x10(%ebp),%eax
80109ff0:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ff9:	8d 50 06             	lea    0x6(%eax),%edx
80109ffc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fff:	83 ec 04             	sub    $0x4,%esp
8010a002:	6a 06                	push   $0x6
8010a004:	52                   	push   %edx
8010a005:	50                   	push   %eax
8010a006:	e8 02 af ff ff       	call   80104f0d <memmove>
8010a00b:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a00e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a011:	83 c0 06             	add    $0x6,%eax
8010a014:	83 ec 04             	sub    $0x4,%esp
8010a017:	6a 06                	push   $0x6
8010a019:	68 90 e7 30 80       	push   $0x8030e790
8010a01e:	50                   	push   %eax
8010a01f:	e8 e9 ae ff ff       	call   80104f0d <memmove>
8010a024:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a027:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a02a:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a02e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a031:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a035:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a038:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a03b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a03e:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a042:	83 ec 0c             	sub    $0xc,%esp
8010a045:	6a 54                	push   $0x54
8010a047:	e8 03 fd ff ff       	call   80109d4f <H2N_ushort>
8010a04c:	83 c4 10             	add    $0x10,%esp
8010a04f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a052:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a056:	0f b7 15 60 ea 30 80 	movzwl 0x8030ea60,%edx
8010a05d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a060:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a064:	0f b7 05 60 ea 30 80 	movzwl 0x8030ea60,%eax
8010a06b:	83 c0 01             	add    $0x1,%eax
8010a06e:	66 a3 60 ea 30 80    	mov    %ax,0x8030ea60
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a074:	83 ec 0c             	sub    $0xc,%esp
8010a077:	68 00 40 00 00       	push   $0x4000
8010a07c:	e8 ce fc ff ff       	call   80109d4f <H2N_ushort>
8010a081:	83 c4 10             	add    $0x10,%esp
8010a084:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a087:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a08b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a08e:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a092:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a095:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a099:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a09c:	83 c0 0c             	add    $0xc,%eax
8010a09f:	83 ec 04             	sub    $0x4,%esp
8010a0a2:	6a 04                	push   $0x4
8010a0a4:	68 04 f5 10 80       	push   $0x8010f504
8010a0a9:	50                   	push   %eax
8010a0aa:	e8 5e ae ff ff       	call   80104f0d <memmove>
8010a0af:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a0b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0b5:	8d 50 0c             	lea    0xc(%eax),%edx
8010a0b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0bb:	83 c0 10             	add    $0x10,%eax
8010a0be:	83 ec 04             	sub    $0x4,%esp
8010a0c1:	6a 04                	push   $0x4
8010a0c3:	52                   	push   %edx
8010a0c4:	50                   	push   %eax
8010a0c5:	e8 43 ae ff ff       	call   80104f0d <memmove>
8010a0ca:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a0cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0d0:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a0d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0d9:	83 ec 0c             	sub    $0xc,%esp
8010a0dc:	50                   	push   %eax
8010a0dd:	e8 6d fd ff ff       	call   80109e4f <ipv4_chksum>
8010a0e2:	83 c4 10             	add    $0x10,%esp
8010a0e5:	0f b7 c0             	movzwl %ax,%eax
8010a0e8:	83 ec 0c             	sub    $0xc,%esp
8010a0eb:	50                   	push   %eax
8010a0ec:	e8 5e fc ff ff       	call   80109d4f <H2N_ushort>
8010a0f1:	83 c4 10             	add    $0x10,%esp
8010a0f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0f7:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a0fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0fe:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a101:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a104:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a108:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a10b:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a10f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a112:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a116:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a119:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a11d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a120:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a124:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a127:	8d 50 08             	lea    0x8(%eax),%edx
8010a12a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a12d:	83 c0 08             	add    $0x8,%eax
8010a130:	83 ec 04             	sub    $0x4,%esp
8010a133:	6a 08                	push   $0x8
8010a135:	52                   	push   %edx
8010a136:	50                   	push   %eax
8010a137:	e8 d1 ad ff ff       	call   80104f0d <memmove>
8010a13c:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a13f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a142:	8d 50 10             	lea    0x10(%eax),%edx
8010a145:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a148:	83 c0 10             	add    $0x10,%eax
8010a14b:	83 ec 04             	sub    $0x4,%esp
8010a14e:	6a 30                	push   $0x30
8010a150:	52                   	push   %edx
8010a151:	50                   	push   %eax
8010a152:	e8 b6 ad ff ff       	call   80104f0d <memmove>
8010a157:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a15a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a15d:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a163:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a166:	83 ec 0c             	sub    $0xc,%esp
8010a169:	50                   	push   %eax
8010a16a:	e8 1c 00 00 00       	call   8010a18b <icmp_chksum>
8010a16f:	83 c4 10             	add    $0x10,%esp
8010a172:	0f b7 c0             	movzwl %ax,%eax
8010a175:	83 ec 0c             	sub    $0xc,%esp
8010a178:	50                   	push   %eax
8010a179:	e8 d1 fb ff ff       	call   80109d4f <H2N_ushort>
8010a17e:	83 c4 10             	add    $0x10,%esp
8010a181:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a184:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a188:	90                   	nop
8010a189:	c9                   	leave  
8010a18a:	c3                   	ret    

8010a18b <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a18b:	55                   	push   %ebp
8010a18c:	89 e5                	mov    %esp,%ebp
8010a18e:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a191:	8b 45 08             	mov    0x8(%ebp),%eax
8010a194:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a197:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a19e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a1a5:	eb 48                	jmp    8010a1ef <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a1a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a1aa:	01 c0                	add    %eax,%eax
8010a1ac:	89 c2                	mov    %eax,%edx
8010a1ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1b1:	01 d0                	add    %edx,%eax
8010a1b3:	0f b6 00             	movzbl (%eax),%eax
8010a1b6:	0f b6 c0             	movzbl %al,%eax
8010a1b9:	c1 e0 08             	shl    $0x8,%eax
8010a1bc:	89 c2                	mov    %eax,%edx
8010a1be:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a1c1:	01 c0                	add    %eax,%eax
8010a1c3:	8d 48 01             	lea    0x1(%eax),%ecx
8010a1c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1c9:	01 c8                	add    %ecx,%eax
8010a1cb:	0f b6 00             	movzbl (%eax),%eax
8010a1ce:	0f b6 c0             	movzbl %al,%eax
8010a1d1:	01 d0                	add    %edx,%eax
8010a1d3:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a1d6:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a1dd:	76 0c                	jbe    8010a1eb <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a1df:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a1e2:	0f b7 c0             	movzwl %ax,%eax
8010a1e5:	83 c0 01             	add    $0x1,%eax
8010a1e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a1eb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a1ef:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a1f3:	7e b2                	jle    8010a1a7 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a1f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a1f8:	f7 d0                	not    %eax
}
8010a1fa:	c9                   	leave  
8010a1fb:	c3                   	ret    

8010a1fc <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a1fc:	55                   	push   %ebp
8010a1fd:	89 e5                	mov    %esp,%ebp
8010a1ff:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a202:	8b 45 08             	mov    0x8(%ebp),%eax
8010a205:	83 c0 0e             	add    $0xe,%eax
8010a208:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a20b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a20e:	0f b6 00             	movzbl (%eax),%eax
8010a211:	0f b6 c0             	movzbl %al,%eax
8010a214:	83 e0 0f             	and    $0xf,%eax
8010a217:	c1 e0 02             	shl    $0x2,%eax
8010a21a:	89 c2                	mov    %eax,%edx
8010a21c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a21f:	01 d0                	add    %edx,%eax
8010a221:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a224:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a227:	83 c0 14             	add    $0x14,%eax
8010a22a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a22d:	e8 56 85 ff ff       	call   80102788 <kalloc>
8010a232:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a235:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a23c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a23f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a243:	0f b6 c0             	movzbl %al,%eax
8010a246:	83 e0 02             	and    $0x2,%eax
8010a249:	85 c0                	test   %eax,%eax
8010a24b:	74 3d                	je     8010a28a <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a24d:	83 ec 0c             	sub    $0xc,%esp
8010a250:	6a 00                	push   $0x0
8010a252:	6a 12                	push   $0x12
8010a254:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a257:	50                   	push   %eax
8010a258:	ff 75 e8             	push   -0x18(%ebp)
8010a25b:	ff 75 08             	push   0x8(%ebp)
8010a25e:	e8 a2 01 00 00       	call   8010a405 <tcp_pkt_create>
8010a263:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a266:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a269:	83 ec 08             	sub    $0x8,%esp
8010a26c:	50                   	push   %eax
8010a26d:	ff 75 e8             	push   -0x18(%ebp)
8010a270:	e8 61 f1 ff ff       	call   801093d6 <i8254_send>
8010a275:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a278:	a1 64 ea 30 80       	mov    0x8030ea64,%eax
8010a27d:	83 c0 01             	add    $0x1,%eax
8010a280:	a3 64 ea 30 80       	mov    %eax,0x8030ea64
8010a285:	e9 69 01 00 00       	jmp    8010a3f3 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a28a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a28d:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a291:	3c 18                	cmp    $0x18,%al
8010a293:	0f 85 10 01 00 00    	jne    8010a3a9 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a299:	83 ec 04             	sub    $0x4,%esp
8010a29c:	6a 03                	push   $0x3
8010a29e:	68 de c9 10 80       	push   $0x8010c9de
8010a2a3:	ff 75 ec             	push   -0x14(%ebp)
8010a2a6:	e8 0a ac ff ff       	call   80104eb5 <memcmp>
8010a2ab:	83 c4 10             	add    $0x10,%esp
8010a2ae:	85 c0                	test   %eax,%eax
8010a2b0:	74 74                	je     8010a326 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a2b2:	83 ec 0c             	sub    $0xc,%esp
8010a2b5:	68 e2 c9 10 80       	push   $0x8010c9e2
8010a2ba:	e8 35 61 ff ff       	call   801003f4 <cprintf>
8010a2bf:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a2c2:	83 ec 0c             	sub    $0xc,%esp
8010a2c5:	6a 00                	push   $0x0
8010a2c7:	6a 10                	push   $0x10
8010a2c9:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a2cc:	50                   	push   %eax
8010a2cd:	ff 75 e8             	push   -0x18(%ebp)
8010a2d0:	ff 75 08             	push   0x8(%ebp)
8010a2d3:	e8 2d 01 00 00       	call   8010a405 <tcp_pkt_create>
8010a2d8:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a2db:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a2de:	83 ec 08             	sub    $0x8,%esp
8010a2e1:	50                   	push   %eax
8010a2e2:	ff 75 e8             	push   -0x18(%ebp)
8010a2e5:	e8 ec f0 ff ff       	call   801093d6 <i8254_send>
8010a2ea:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a2ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2f0:	83 c0 36             	add    $0x36,%eax
8010a2f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a2f6:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a2f9:	50                   	push   %eax
8010a2fa:	ff 75 e0             	push   -0x20(%ebp)
8010a2fd:	6a 00                	push   $0x0
8010a2ff:	6a 00                	push   $0x0
8010a301:	e8 5a 04 00 00       	call   8010a760 <http_proc>
8010a306:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a309:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a30c:	83 ec 0c             	sub    $0xc,%esp
8010a30f:	50                   	push   %eax
8010a310:	6a 18                	push   $0x18
8010a312:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a315:	50                   	push   %eax
8010a316:	ff 75 e8             	push   -0x18(%ebp)
8010a319:	ff 75 08             	push   0x8(%ebp)
8010a31c:	e8 e4 00 00 00       	call   8010a405 <tcp_pkt_create>
8010a321:	83 c4 20             	add    $0x20,%esp
8010a324:	eb 62                	jmp    8010a388 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a326:	83 ec 0c             	sub    $0xc,%esp
8010a329:	6a 00                	push   $0x0
8010a32b:	6a 10                	push   $0x10
8010a32d:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a330:	50                   	push   %eax
8010a331:	ff 75 e8             	push   -0x18(%ebp)
8010a334:	ff 75 08             	push   0x8(%ebp)
8010a337:	e8 c9 00 00 00       	call   8010a405 <tcp_pkt_create>
8010a33c:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a33f:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a342:	83 ec 08             	sub    $0x8,%esp
8010a345:	50                   	push   %eax
8010a346:	ff 75 e8             	push   -0x18(%ebp)
8010a349:	e8 88 f0 ff ff       	call   801093d6 <i8254_send>
8010a34e:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a351:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a354:	83 c0 36             	add    $0x36,%eax
8010a357:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a35a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a35d:	50                   	push   %eax
8010a35e:	ff 75 e4             	push   -0x1c(%ebp)
8010a361:	6a 00                	push   $0x0
8010a363:	6a 00                	push   $0x0
8010a365:	e8 f6 03 00 00       	call   8010a760 <http_proc>
8010a36a:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a36d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a370:	83 ec 0c             	sub    $0xc,%esp
8010a373:	50                   	push   %eax
8010a374:	6a 18                	push   $0x18
8010a376:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a379:	50                   	push   %eax
8010a37a:	ff 75 e8             	push   -0x18(%ebp)
8010a37d:	ff 75 08             	push   0x8(%ebp)
8010a380:	e8 80 00 00 00       	call   8010a405 <tcp_pkt_create>
8010a385:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a388:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a38b:	83 ec 08             	sub    $0x8,%esp
8010a38e:	50                   	push   %eax
8010a38f:	ff 75 e8             	push   -0x18(%ebp)
8010a392:	e8 3f f0 ff ff       	call   801093d6 <i8254_send>
8010a397:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a39a:	a1 64 ea 30 80       	mov    0x8030ea64,%eax
8010a39f:	83 c0 01             	add    $0x1,%eax
8010a3a2:	a3 64 ea 30 80       	mov    %eax,0x8030ea64
8010a3a7:	eb 4a                	jmp    8010a3f3 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a3a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3ac:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a3b0:	3c 10                	cmp    $0x10,%al
8010a3b2:	75 3f                	jne    8010a3f3 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a3b4:	a1 68 ea 30 80       	mov    0x8030ea68,%eax
8010a3b9:	83 f8 01             	cmp    $0x1,%eax
8010a3bc:	75 35                	jne    8010a3f3 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a3be:	83 ec 0c             	sub    $0xc,%esp
8010a3c1:	6a 00                	push   $0x0
8010a3c3:	6a 01                	push   $0x1
8010a3c5:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a3c8:	50                   	push   %eax
8010a3c9:	ff 75 e8             	push   -0x18(%ebp)
8010a3cc:	ff 75 08             	push   0x8(%ebp)
8010a3cf:	e8 31 00 00 00       	call   8010a405 <tcp_pkt_create>
8010a3d4:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a3d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a3da:	83 ec 08             	sub    $0x8,%esp
8010a3dd:	50                   	push   %eax
8010a3de:	ff 75 e8             	push   -0x18(%ebp)
8010a3e1:	e8 f0 ef ff ff       	call   801093d6 <i8254_send>
8010a3e6:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a3e9:	c7 05 68 ea 30 80 00 	movl   $0x0,0x8030ea68
8010a3f0:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a3f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3f6:	83 ec 0c             	sub    $0xc,%esp
8010a3f9:	50                   	push   %eax
8010a3fa:	e8 ef 82 ff ff       	call   801026ee <kfree>
8010a3ff:	83 c4 10             	add    $0x10,%esp
}
8010a402:	90                   	nop
8010a403:	c9                   	leave  
8010a404:	c3                   	ret    

8010a405 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a405:	55                   	push   %ebp
8010a406:	89 e5                	mov    %esp,%ebp
8010a408:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a40b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a40e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a411:	8b 45 08             	mov    0x8(%ebp),%eax
8010a414:	83 c0 0e             	add    $0xe,%eax
8010a417:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a41a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a41d:	0f b6 00             	movzbl (%eax),%eax
8010a420:	0f b6 c0             	movzbl %al,%eax
8010a423:	83 e0 0f             	and    $0xf,%eax
8010a426:	c1 e0 02             	shl    $0x2,%eax
8010a429:	89 c2                	mov    %eax,%edx
8010a42b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a42e:	01 d0                	add    %edx,%eax
8010a430:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a433:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a436:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a439:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a43c:	83 c0 0e             	add    $0xe,%eax
8010a43f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a442:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a445:	83 c0 14             	add    $0x14,%eax
8010a448:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a44b:	8b 45 18             	mov    0x18(%ebp),%eax
8010a44e:	8d 50 36             	lea    0x36(%eax),%edx
8010a451:	8b 45 10             	mov    0x10(%ebp),%eax
8010a454:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a456:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a459:	8d 50 06             	lea    0x6(%eax),%edx
8010a45c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a45f:	83 ec 04             	sub    $0x4,%esp
8010a462:	6a 06                	push   $0x6
8010a464:	52                   	push   %edx
8010a465:	50                   	push   %eax
8010a466:	e8 a2 aa ff ff       	call   80104f0d <memmove>
8010a46b:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a46e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a471:	83 c0 06             	add    $0x6,%eax
8010a474:	83 ec 04             	sub    $0x4,%esp
8010a477:	6a 06                	push   $0x6
8010a479:	68 90 e7 30 80       	push   $0x8030e790
8010a47e:	50                   	push   %eax
8010a47f:	e8 89 aa ff ff       	call   80104f0d <memmove>
8010a484:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a487:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a48a:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a48e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a491:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a495:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a498:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a49b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a49e:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a4a2:	8b 45 18             	mov    0x18(%ebp),%eax
8010a4a5:	83 c0 28             	add    $0x28,%eax
8010a4a8:	0f b7 c0             	movzwl %ax,%eax
8010a4ab:	83 ec 0c             	sub    $0xc,%esp
8010a4ae:	50                   	push   %eax
8010a4af:	e8 9b f8 ff ff       	call   80109d4f <H2N_ushort>
8010a4b4:	83 c4 10             	add    $0x10,%esp
8010a4b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a4ba:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a4be:	0f b7 15 60 ea 30 80 	movzwl 0x8030ea60,%edx
8010a4c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4c8:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a4cc:	0f b7 05 60 ea 30 80 	movzwl 0x8030ea60,%eax
8010a4d3:	83 c0 01             	add    $0x1,%eax
8010a4d6:	66 a3 60 ea 30 80    	mov    %ax,0x8030ea60
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a4dc:	83 ec 0c             	sub    $0xc,%esp
8010a4df:	6a 00                	push   $0x0
8010a4e1:	e8 69 f8 ff ff       	call   80109d4f <H2N_ushort>
8010a4e6:	83 c4 10             	add    $0x10,%esp
8010a4e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a4ec:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a4f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4f3:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a4f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4fa:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a4fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a501:	83 c0 0c             	add    $0xc,%eax
8010a504:	83 ec 04             	sub    $0x4,%esp
8010a507:	6a 04                	push   $0x4
8010a509:	68 04 f5 10 80       	push   $0x8010f504
8010a50e:	50                   	push   %eax
8010a50f:	e8 f9 a9 ff ff       	call   80104f0d <memmove>
8010a514:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a517:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a51a:	8d 50 0c             	lea    0xc(%eax),%edx
8010a51d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a520:	83 c0 10             	add    $0x10,%eax
8010a523:	83 ec 04             	sub    $0x4,%esp
8010a526:	6a 04                	push   $0x4
8010a528:	52                   	push   %edx
8010a529:	50                   	push   %eax
8010a52a:	e8 de a9 ff ff       	call   80104f0d <memmove>
8010a52f:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a532:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a535:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a53b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a53e:	83 ec 0c             	sub    $0xc,%esp
8010a541:	50                   	push   %eax
8010a542:	e8 08 f9 ff ff       	call   80109e4f <ipv4_chksum>
8010a547:	83 c4 10             	add    $0x10,%esp
8010a54a:	0f b7 c0             	movzwl %ax,%eax
8010a54d:	83 ec 0c             	sub    $0xc,%esp
8010a550:	50                   	push   %eax
8010a551:	e8 f9 f7 ff ff       	call   80109d4f <H2N_ushort>
8010a556:	83 c4 10             	add    $0x10,%esp
8010a559:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a55c:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a560:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a563:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a567:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a56a:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a56d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a570:	0f b7 10             	movzwl (%eax),%edx
8010a573:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a576:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a57a:	a1 64 ea 30 80       	mov    0x8030ea64,%eax
8010a57f:	83 ec 0c             	sub    $0xc,%esp
8010a582:	50                   	push   %eax
8010a583:	e8 e9 f7 ff ff       	call   80109d71 <H2N_uint>
8010a588:	83 c4 10             	add    $0x10,%esp
8010a58b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a58e:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a591:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a594:	8b 40 04             	mov    0x4(%eax),%eax
8010a597:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a59d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5a0:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a5a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5a6:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a5aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5ad:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a5b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5b4:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a5b8:	8b 45 14             	mov    0x14(%ebp),%eax
8010a5bb:	89 c2                	mov    %eax,%edx
8010a5bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5c0:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a5c3:	83 ec 0c             	sub    $0xc,%esp
8010a5c6:	68 90 38 00 00       	push   $0x3890
8010a5cb:	e8 7f f7 ff ff       	call   80109d4f <H2N_ushort>
8010a5d0:	83 c4 10             	add    $0x10,%esp
8010a5d3:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a5d6:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a5da:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5dd:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a5e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5e6:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a5ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5ef:	83 ec 0c             	sub    $0xc,%esp
8010a5f2:	50                   	push   %eax
8010a5f3:	e8 1f 00 00 00       	call   8010a617 <tcp_chksum>
8010a5f8:	83 c4 10             	add    $0x10,%esp
8010a5fb:	83 c0 08             	add    $0x8,%eax
8010a5fe:	0f b7 c0             	movzwl %ax,%eax
8010a601:	83 ec 0c             	sub    $0xc,%esp
8010a604:	50                   	push   %eax
8010a605:	e8 45 f7 ff ff       	call   80109d4f <H2N_ushort>
8010a60a:	83 c4 10             	add    $0x10,%esp
8010a60d:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a610:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a614:	90                   	nop
8010a615:	c9                   	leave  
8010a616:	c3                   	ret    

8010a617 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a617:	55                   	push   %ebp
8010a618:	89 e5                	mov    %esp,%ebp
8010a61a:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a61d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a620:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a623:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a626:	83 c0 14             	add    $0x14,%eax
8010a629:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a62c:	83 ec 04             	sub    $0x4,%esp
8010a62f:	6a 04                	push   $0x4
8010a631:	68 04 f5 10 80       	push   $0x8010f504
8010a636:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a639:	50                   	push   %eax
8010a63a:	e8 ce a8 ff ff       	call   80104f0d <memmove>
8010a63f:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a642:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a645:	83 c0 0c             	add    $0xc,%eax
8010a648:	83 ec 04             	sub    $0x4,%esp
8010a64b:	6a 04                	push   $0x4
8010a64d:	50                   	push   %eax
8010a64e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a651:	83 c0 04             	add    $0x4,%eax
8010a654:	50                   	push   %eax
8010a655:	e8 b3 a8 ff ff       	call   80104f0d <memmove>
8010a65a:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a65d:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a661:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a665:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a668:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a66c:	0f b7 c0             	movzwl %ax,%eax
8010a66f:	83 ec 0c             	sub    $0xc,%esp
8010a672:	50                   	push   %eax
8010a673:	e8 b5 f6 ff ff       	call   80109d2d <N2H_ushort>
8010a678:	83 c4 10             	add    $0x10,%esp
8010a67b:	83 e8 14             	sub    $0x14,%eax
8010a67e:	0f b7 c0             	movzwl %ax,%eax
8010a681:	83 ec 0c             	sub    $0xc,%esp
8010a684:	50                   	push   %eax
8010a685:	e8 c5 f6 ff ff       	call   80109d4f <H2N_ushort>
8010a68a:	83 c4 10             	add    $0x10,%esp
8010a68d:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a691:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a698:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a69b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a69e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a6a5:	eb 33                	jmp    8010a6da <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a6a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6aa:	01 c0                	add    %eax,%eax
8010a6ac:	89 c2                	mov    %eax,%edx
8010a6ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6b1:	01 d0                	add    %edx,%eax
8010a6b3:	0f b6 00             	movzbl (%eax),%eax
8010a6b6:	0f b6 c0             	movzbl %al,%eax
8010a6b9:	c1 e0 08             	shl    $0x8,%eax
8010a6bc:	89 c2                	mov    %eax,%edx
8010a6be:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6c1:	01 c0                	add    %eax,%eax
8010a6c3:	8d 48 01             	lea    0x1(%eax),%ecx
8010a6c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6c9:	01 c8                	add    %ecx,%eax
8010a6cb:	0f b6 00             	movzbl (%eax),%eax
8010a6ce:	0f b6 c0             	movzbl %al,%eax
8010a6d1:	01 d0                	add    %edx,%eax
8010a6d3:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a6d6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a6da:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a6de:	7e c7                	jle    8010a6a7 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a6e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a6e6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a6ed:	eb 33                	jmp    8010a722 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a6ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a6f2:	01 c0                	add    %eax,%eax
8010a6f4:	89 c2                	mov    %eax,%edx
8010a6f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6f9:	01 d0                	add    %edx,%eax
8010a6fb:	0f b6 00             	movzbl (%eax),%eax
8010a6fe:	0f b6 c0             	movzbl %al,%eax
8010a701:	c1 e0 08             	shl    $0x8,%eax
8010a704:	89 c2                	mov    %eax,%edx
8010a706:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a709:	01 c0                	add    %eax,%eax
8010a70b:	8d 48 01             	lea    0x1(%eax),%ecx
8010a70e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a711:	01 c8                	add    %ecx,%eax
8010a713:	0f b6 00             	movzbl (%eax),%eax
8010a716:	0f b6 c0             	movzbl %al,%eax
8010a719:	01 d0                	add    %edx,%eax
8010a71b:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a71e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a722:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a726:	0f b7 c0             	movzwl %ax,%eax
8010a729:	83 ec 0c             	sub    $0xc,%esp
8010a72c:	50                   	push   %eax
8010a72d:	e8 fb f5 ff ff       	call   80109d2d <N2H_ushort>
8010a732:	83 c4 10             	add    $0x10,%esp
8010a735:	66 d1 e8             	shr    %ax
8010a738:	0f b7 c0             	movzwl %ax,%eax
8010a73b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a73e:	7c af                	jl     8010a6ef <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a740:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a743:	c1 e8 10             	shr    $0x10,%eax
8010a746:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a74c:	f7 d0                	not    %eax
}
8010a74e:	c9                   	leave  
8010a74f:	c3                   	ret    

8010a750 <tcp_fin>:

void tcp_fin(){
8010a750:	55                   	push   %ebp
8010a751:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a753:	c7 05 68 ea 30 80 01 	movl   $0x1,0x8030ea68
8010a75a:	00 00 00 
}
8010a75d:	90                   	nop
8010a75e:	5d                   	pop    %ebp
8010a75f:	c3                   	ret    

8010a760 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a760:	55                   	push   %ebp
8010a761:	89 e5                	mov    %esp,%ebp
8010a763:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a766:	8b 45 10             	mov    0x10(%ebp),%eax
8010a769:	83 ec 04             	sub    $0x4,%esp
8010a76c:	6a 00                	push   $0x0
8010a76e:	68 eb c9 10 80       	push   $0x8010c9eb
8010a773:	50                   	push   %eax
8010a774:	e8 65 00 00 00       	call   8010a7de <http_strcpy>
8010a779:	83 c4 10             	add    $0x10,%esp
8010a77c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a77f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a782:	83 ec 04             	sub    $0x4,%esp
8010a785:	ff 75 f4             	push   -0xc(%ebp)
8010a788:	68 fe c9 10 80       	push   $0x8010c9fe
8010a78d:	50                   	push   %eax
8010a78e:	e8 4b 00 00 00       	call   8010a7de <http_strcpy>
8010a793:	83 c4 10             	add    $0x10,%esp
8010a796:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a799:	8b 45 10             	mov    0x10(%ebp),%eax
8010a79c:	83 ec 04             	sub    $0x4,%esp
8010a79f:	ff 75 f4             	push   -0xc(%ebp)
8010a7a2:	68 19 ca 10 80       	push   $0x8010ca19
8010a7a7:	50                   	push   %eax
8010a7a8:	e8 31 00 00 00       	call   8010a7de <http_strcpy>
8010a7ad:	83 c4 10             	add    $0x10,%esp
8010a7b0:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a7b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a7b6:	83 e0 01             	and    $0x1,%eax
8010a7b9:	85 c0                	test   %eax,%eax
8010a7bb:	74 11                	je     8010a7ce <http_proc+0x6e>
    char *payload = (char *)send;
8010a7bd:	8b 45 10             	mov    0x10(%ebp),%eax
8010a7c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a7c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a7c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a7c9:	01 d0                	add    %edx,%eax
8010a7cb:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a7ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a7d1:	8b 45 14             	mov    0x14(%ebp),%eax
8010a7d4:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a7d6:	e8 75 ff ff ff       	call   8010a750 <tcp_fin>
}
8010a7db:	90                   	nop
8010a7dc:	c9                   	leave  
8010a7dd:	c3                   	ret    

8010a7de <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a7de:	55                   	push   %ebp
8010a7df:	89 e5                	mov    %esp,%ebp
8010a7e1:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a7e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a7eb:	eb 20                	jmp    8010a80d <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a7ed:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a7f0:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a7f3:	01 d0                	add    %edx,%eax
8010a7f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a7f8:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a7fb:	01 ca                	add    %ecx,%edx
8010a7fd:	89 d1                	mov    %edx,%ecx
8010a7ff:	8b 55 08             	mov    0x8(%ebp),%edx
8010a802:	01 ca                	add    %ecx,%edx
8010a804:	0f b6 00             	movzbl (%eax),%eax
8010a807:	88 02                	mov    %al,(%edx)
    i++;
8010a809:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a80d:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a810:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a813:	01 d0                	add    %edx,%eax
8010a815:	0f b6 00             	movzbl (%eax),%eax
8010a818:	84 c0                	test   %al,%al
8010a81a:	75 d1                	jne    8010a7ed <http_strcpy+0xf>
  }
  return i;
8010a81c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a81f:	c9                   	leave  
8010a820:	c3                   	ret    

8010a821 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a821:	55                   	push   %ebp
8010a822:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a824:	c7 05 70 ea 30 80 c2 	movl   $0x8010f5c2,0x8030ea70
8010a82b:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a82e:	b8 00 40 1f 00       	mov    $0x1f4000,%eax
8010a833:	c1 e8 09             	shr    $0x9,%eax
8010a836:	a3 6c ea 30 80       	mov    %eax,0x8030ea6c
}
8010a83b:	90                   	nop
8010a83c:	5d                   	pop    %ebp
8010a83d:	c3                   	ret    

8010a83e <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a83e:	55                   	push   %ebp
8010a83f:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a841:	90                   	nop
8010a842:	5d                   	pop    %ebp
8010a843:	c3                   	ret    

8010a844 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a844:	55                   	push   %ebp
8010a845:	89 e5                	mov    %esp,%ebp
8010a847:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a84a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a84d:	83 c0 0c             	add    $0xc,%eax
8010a850:	83 ec 0c             	sub    $0xc,%esp
8010a853:	50                   	push   %eax
8010a854:	e8 ee a2 ff ff       	call   80104b47 <holdingsleep>
8010a859:	83 c4 10             	add    $0x10,%esp
8010a85c:	85 c0                	test   %eax,%eax
8010a85e:	75 0d                	jne    8010a86d <iderw+0x29>
    panic("iderw: buf not locked");
8010a860:	83 ec 0c             	sub    $0xc,%esp
8010a863:	68 2a ca 10 80       	push   $0x8010ca2a
8010a868:	e8 3c 5d ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a86d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a870:	8b 00                	mov    (%eax),%eax
8010a872:	83 e0 06             	and    $0x6,%eax
8010a875:	83 f8 02             	cmp    $0x2,%eax
8010a878:	75 0d                	jne    8010a887 <iderw+0x43>
    panic("iderw: nothing to do");
8010a87a:	83 ec 0c             	sub    $0xc,%esp
8010a87d:	68 40 ca 10 80       	push   $0x8010ca40
8010a882:	e8 22 5d ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a887:	8b 45 08             	mov    0x8(%ebp),%eax
8010a88a:	8b 40 04             	mov    0x4(%eax),%eax
8010a88d:	83 f8 01             	cmp    $0x1,%eax
8010a890:	74 0d                	je     8010a89f <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a892:	83 ec 0c             	sub    $0xc,%esp
8010a895:	68 55 ca 10 80       	push   $0x8010ca55
8010a89a:	e8 0a 5d ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a89f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8a2:	8b 40 08             	mov    0x8(%eax),%eax
8010a8a5:	8b 15 6c ea 30 80    	mov    0x8030ea6c,%edx
8010a8ab:	39 d0                	cmp    %edx,%eax
8010a8ad:	72 0d                	jb     8010a8bc <iderw+0x78>
    panic("iderw: block out of range");
8010a8af:	83 ec 0c             	sub    $0xc,%esp
8010a8b2:	68 73 ca 10 80       	push   $0x8010ca73
8010a8b7:	e8 ed 5c ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a8bc:	8b 15 70 ea 30 80    	mov    0x8030ea70,%edx
8010a8c2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8c5:	8b 40 08             	mov    0x8(%eax),%eax
8010a8c8:	c1 e0 09             	shl    $0x9,%eax
8010a8cb:	01 d0                	add    %edx,%eax
8010a8cd:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a8d0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8d3:	8b 00                	mov    (%eax),%eax
8010a8d5:	83 e0 04             	and    $0x4,%eax
8010a8d8:	85 c0                	test   %eax,%eax
8010a8da:	74 2b                	je     8010a907 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a8dc:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8df:	8b 00                	mov    (%eax),%eax
8010a8e1:	83 e0 fb             	and    $0xfffffffb,%eax
8010a8e4:	89 c2                	mov    %eax,%edx
8010a8e6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8e9:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a8eb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8ee:	83 c0 5c             	add    $0x5c,%eax
8010a8f1:	83 ec 04             	sub    $0x4,%esp
8010a8f4:	68 00 02 00 00       	push   $0x200
8010a8f9:	50                   	push   %eax
8010a8fa:	ff 75 f4             	push   -0xc(%ebp)
8010a8fd:	e8 0b a6 ff ff       	call   80104f0d <memmove>
8010a902:	83 c4 10             	add    $0x10,%esp
8010a905:	eb 1a                	jmp    8010a921 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a907:	8b 45 08             	mov    0x8(%ebp),%eax
8010a90a:	83 c0 5c             	add    $0x5c,%eax
8010a90d:	83 ec 04             	sub    $0x4,%esp
8010a910:	68 00 02 00 00       	push   $0x200
8010a915:	ff 75 f4             	push   -0xc(%ebp)
8010a918:	50                   	push   %eax
8010a919:	e8 ef a5 ff ff       	call   80104f0d <memmove>
8010a91e:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a921:	8b 45 08             	mov    0x8(%ebp),%eax
8010a924:	8b 00                	mov    (%eax),%eax
8010a926:	83 c8 02             	or     $0x2,%eax
8010a929:	89 c2                	mov    %eax,%edx
8010a92b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a92e:	89 10                	mov    %edx,(%eax)
}
8010a930:	90                   	nop
8010a931:	c9                   	leave  
8010a932:	c3                   	ret    
