
kernel:     file format elf32-i386


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
8010005a:	bc b0 b0 11 80       	mov    $0x8011b0b0,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 49 38 10 80       	mov    $0x80103849,%edx
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
8010006f:	68 80 a3 10 80       	push   $0x8010a380
80100074:	68 00 00 11 80       	push   $0x80110000
80100079:	e8 38 4b 00 00       	call   80104bb6 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 47 11 80 fc 	movl   $0x801146fc,0x8011474c
80100088:	46 11 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 47 11 80 fc 	movl   $0x801146fc,0x80114750
80100092:	46 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 00 11 80 	movl   $0x80110034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 47 11 80    	mov    0x80114750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 87 a3 10 80       	push   $0x8010a387
801000c2:	50                   	push   %eax
801000c3:	e8 91 49 00 00       	call   80104a59 <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 47 11 80       	mov    0x80114750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 47 11 80       	mov    %eax,0x80114750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 46 11 80       	mov    $0x801146fc,%eax
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
801000fc:	68 00 00 11 80       	push   $0x80110000
80100101:	e8 d2 4a 00 00       	call   80104bd8 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 47 11 80       	mov    0x80114750,%eax
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
8010013b:	68 00 00 11 80       	push   $0x80110000
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
8010016b:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 47 11 80       	mov    0x8011474c,%eax
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
801001bc:	68 00 00 11 80       	push   $0x80110000
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
801001e9:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 8e a3 10 80       	push   $0x8010a38e
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
8010022d:	e8 f9 26 00 00       	call   8010292b <iderw>
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
80100259:	68 9f a3 10 80       	push   $0x8010a39f
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
80100278:	e8 ae 26 00 00       	call   8010292b <iderw>
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
801002a2:	68 a6 a3 10 80       	push   $0x8010a3a6
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
801002c1:	68 00 00 11 80       	push   $0x80110000
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
80100305:	8b 15 50 47 11 80    	mov    0x80114750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 47 11 80       	mov    0x80114750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 47 11 80       	mov    %eax,0x80114750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 00 11 80       	push   $0x80110000
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
801003fa:	a1 34 4a 11 80       	mov    0x80114a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 4a 11 80       	push   $0x80114a00
80100410:	e8 c3 47 00 00       	call   80104bd8 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 ad a3 10 80       	push   $0x8010a3ad
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
80100510:	c7 45 ec b6 a3 10 80 	movl   $0x8010a3b6,-0x14(%ebp)
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
80100599:	68 00 4a 11 80       	push   $0x80114a00
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
801005b4:	c7 05 34 4a 11 80 00 	movl   $0x0,0x80114a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 1b 2a 00 00       	call   80102fde <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 bd a3 10 80       	push   $0x8010a3bd
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
801005e6:	68 d1 a3 10 80       	push   $0x8010a3d1
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
8010061a:	68 d3 a3 10 80       	push   $0x8010a3d3
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 49 11 80 01 	movl   $0x1,0x801149ec
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
801006a0:	e8 53 7c 00 00       	call   801082f8 <graphic_scroll_up>
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
801006f3:	e8 00 7c 00 00       	call   801082f8 <graphic_scroll_up>
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
80100757:	e8 07 7c 00 00       	call   80108363 <font_render>
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
80100775:	a1 ec 49 11 80       	mov    0x801149ec,%eax
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
80100793:	e8 d7 5f 00 00       	call   8010676f <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 ca 5f 00 00       	call   8010676f <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 bd 5f 00 00       	call   8010676f <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 ad 5f 00 00       	call   8010676f <uartputc>
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
801007e6:	68 00 4a 11 80       	push   $0x80114a00
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
80100838:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 49 11 80       	mov    %eax,0x801149e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
8010085b:	a1 e4 49 11 80       	mov    0x801149e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
80100889:	a1 e4 49 11 80       	mov    0x801149e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 49 11 80       	mov    %eax,0x801149e8
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
801008c2:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008c7:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
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
801008e7:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 49 11 80    	mov    %edx,0x801149e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 49 11 80    	mov    %dl,-0x7feeb6a0(%eax)
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
8010091b:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100920:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100932:	a3 e4 49 11 80       	mov    %eax,0x801149e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 49 11 80       	push   $0x801149e0
8010093f:	e8 60 3f 00 00       	call   801048a4 <wakeup>
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
8010095d:	68 00 4a 11 80       	push   $0x80114a00
80100962:	e8 df 42 00 00       	call   80104c46 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 ea 3f 00 00       	call   8010495f <procdump>
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
80100984:	e8 74 11 00 00       	call   80101afd <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 4a 11 80       	push   $0x80114a00
8010099a:	e8 39 42 00 00       	call   80104bd8 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 68 35 00 00       	call   80103f14 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 4a 11 80       	push   $0x80114a00
801009bb:	e8 86 42 00 00       	call   80104c46 <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 1c 10 00 00       	call   801019ea <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 4a 11 80       	push   $0x80114a00
801009e3:	68 e0 49 11 80       	push   $0x801149e0
801009e8:	e8 d0 3d 00 00       	call   801047bd <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
801009f6:	a1 e4 49 11 80       	mov    0x801149e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 49 11 80    	mov    %edx,0x801149e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
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
80100a2b:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 49 11 80       	mov    %eax,0x801149e0
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
80100a61:	68 00 4a 11 80       	push   $0x80114a00
80100a66:	e8 db 41 00 00       	call   80104c46 <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 71 0f 00 00       	call   801019ea <ilock>
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
80100a92:	e8 66 10 00 00       	call   80101afd <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 4a 11 80       	push   $0x80114a00
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
80100adf:	68 00 4a 11 80       	push   $0x80114a00
80100ae4:	e8 5d 41 00 00       	call   80104c46 <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 f3 0e 00 00       	call   801019ea <ilock>
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
80100b05:	c7 05 ec 49 11 80 00 	movl   $0x0,0x801149ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 d7 a3 10 80       	push   $0x8010a3d7
80100b17:	68 00 4a 11 80       	push   $0x80114a00
80100b1c:	e8 95 40 00 00       	call   80104bb6 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 4a 11 80 86 	movl   $0x80100a86,0x80114a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 4a 11 80 78 	movl   $0x80100978,0x80114a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 df a3 10 80 	movl   $0x8010a3df,-0xc(%ebp)
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
80100b64:	c7 05 34 4a 11 80 01 	movl   $0x1,0x80114a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 98 1f 00 00       	call   80102b12 <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#include "x86.h"
#include "elf.h"

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
80100b89:	e8 86 33 00 00       	call   80103f14 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 8a 29 00 00       	call   80103520 <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7c 19 00 00       	call   8010251d <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 fa 29 00 00       	call   801035ac <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 f5 a3 10 80       	push   $0x8010a3f5
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 f1 03 00 00       	jmp    80100fbd <exec+0x43d>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 13 0e 00 00       	call   801019ea <ilock>
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
80100bef:	e8 e2 12 00 00       	call   80101ed6 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 66 03 00 00    	jne    80100f66 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 58 03 00 00    	jne    80100f69 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 55 6b 00 00       	call   8010776b <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 49 03 00 00    	je     80100f6c <exec+0x3ec>
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
80100c4f:	e8 82 12 00 00       	call   80101ed6 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 0f 03 00 00    	jne    80100f6f <exec+0x3ef>
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
80100c7d:	0f 82 ef 02 00 00    	jb     80100f72 <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 d6 02 00 00    	jb     80100f75 <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 a8 6e 00 00       	call   80107b64 <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 ac 02 00 00    	je     80100f78 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 9c 02 00 00    	jne    80100f7b <exec+0x3fb>
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
80100cfd:	e8 95 6d 00 00       	call   80107a97 <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 71 02 00 00    	js     80100f7e <exec+0x3fe>
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
80100d36:	e8 e0 0e 00 00       	call   80101c1b <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 69 28 00 00       	call   801035ac <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	05 00 20 00 00       	add    $0x2000,%eax
80100d62:	83 ec 04             	sub    $0x4,%esp
80100d65:	50                   	push   %eax
80100d66:	ff 75 e0             	push   -0x20(%ebp)
80100d69:	ff 75 d4             	push   -0x2c(%ebp)
80100d6c:	e8 f3 6d 00 00       	call   80107b64 <allocuvm>
80100d71:	83 c4 10             	add    $0x10,%esp
80100d74:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7b:	0f 84 00 02 00 00    	je     80100f81 <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d84:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d89:	83 ec 08             	sub    $0x8,%esp
80100d8c:	50                   	push   %eax
80100d8d:	ff 75 d4             	push   -0x2c(%ebp)
80100d90:	e8 31 70 00 00       	call   80107dc6 <clearpteu>
80100d95:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100da5:	e9 96 00 00 00       	jmp    80100e40 <exec+0x2c0>
    if(argc >= MAXARG)
80100daa:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dae:	0f 87 d0 01 00 00    	ja     80100f84 <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	83 ec 0c             	sub    $0xc,%esp
80100dc8:	50                   	push   %eax
80100dc9:	e8 ce 42 00 00       	call   8010509c <strlen>
80100dce:	83 c4 10             	add    $0x10,%esp
80100dd1:	89 c2                	mov    %eax,%edx
80100dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd6:	29 d0                	sub    %edx,%eax
80100dd8:	83 e8 01             	sub    $0x1,%eax
80100ddb:	83 e0 fc             	and    $0xfffffffc,%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dee:	01 d0                	add    %edx,%eax
80100df0:	8b 00                	mov    (%eax),%eax
80100df2:	83 ec 0c             	sub    $0xc,%esp
80100df5:	50                   	push   %eax
80100df6:	e8 a1 42 00 00       	call   8010509c <strlen>
80100dfb:	83 c4 10             	add    $0x10,%esp
80100dfe:	83 c0 01             	add    $0x1,%eax
80100e01:	89 c2                	mov    %eax,%edx
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e10:	01 c8                	add    %ecx,%eax
80100e12:	8b 00                	mov    (%eax),%eax
80100e14:	52                   	push   %edx
80100e15:	50                   	push   %eax
80100e16:	ff 75 dc             	push   -0x24(%ebp)
80100e19:	ff 75 d4             	push   -0x2c(%ebp)
80100e1c:	e8 44 71 00 00       	call   80107f65 <copyout>
80100e21:	83 c4 10             	add    $0x10,%esp
80100e24:	85 c0                	test   %eax,%eax
80100e26:	0f 88 5b 01 00 00    	js     80100f87 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	8d 50 03             	lea    0x3(%eax),%edx
80100e32:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e35:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e3c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4d:	01 d0                	add    %edx,%eax
80100e4f:	8b 00                	mov    (%eax),%eax
80100e51:	85 c0                	test   %eax,%eax
80100e53:	0f 85 51 ff ff ff    	jne    80100daa <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5c:	83 c0 03             	add    $0x3,%eax
80100e5f:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e66:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e6a:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e71:	ff ff ff 
  ustack[1] = argc;
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 01             	add    $0x1,%eax
80100e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8d:	29 d0                	sub    %edx,%eax
80100e8f:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	83 c0 04             	add    $0x4,%eax
80100e9b:	c1 e0 02             	shl    $0x2,%eax
80100e9e:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea4:	83 c0 04             	add    $0x4,%eax
80100ea7:	c1 e0 02             	shl    $0x2,%eax
80100eaa:	50                   	push   %eax
80100eab:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eb1:	50                   	push   %eax
80100eb2:	ff 75 dc             	push   -0x24(%ebp)
80100eb5:	ff 75 d4             	push   -0x2c(%ebp)
80100eb8:	e8 a8 70 00 00       	call   80107f65 <copyout>
80100ebd:	83 c4 10             	add    $0x10,%esp
80100ec0:	85 c0                	test   %eax,%eax
80100ec2:	0f 88 c2 00 00 00    	js     80100f8a <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ed4:	eb 17                	jmp    80100eed <exec+0x36d>
    if(*s == '/')
80100ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed9:	0f b6 00             	movzbl (%eax),%eax
80100edc:	3c 2f                	cmp    $0x2f,%al
80100ede:	75 09                	jne    80100ee9 <exec+0x369>
      last = s+1;
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	83 c0 01             	add    $0x1,%eax
80100ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ee9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef0:	0f b6 00             	movzbl (%eax),%eax
80100ef3:	84 c0                	test   %al,%al
80100ef5:	75 df                	jne    80100ed6 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efa:	83 c0 6c             	add    $0x6c,%eax
80100efd:	83 ec 04             	sub    $0x4,%esp
80100f00:	6a 10                	push   $0x10
80100f02:	ff 75 f0             	push   -0x10(%ebp)
80100f05:	50                   	push   %eax
80100f06:	e8 46 41 00 00       	call   80105051 <safestrcpy>
80100f0b:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f11:	8b 40 04             	mov    0x4(%eax),%eax
80100f14:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f17:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f1d:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f20:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f23:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f26:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2b:	8b 40 18             	mov    0x18(%eax),%eax
80100f2e:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f34:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f37:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3a:	8b 40 18             	mov    0x18(%eax),%eax
80100f3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f40:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f43:	83 ec 0c             	sub    $0xc,%esp
80100f46:	ff 75 d0             	push   -0x30(%ebp)
80100f49:	e8 3a 69 00 00       	call   80107888 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 d1 6d 00 00       	call   80107d2d <freevm>
80100f5c:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f5f:	b8 00 00 00 00       	mov    $0x0,%eax
80100f64:	eb 57                	jmp    80100fbd <exec+0x43d>
    goto bad;
80100f66:	90                   	nop
80100f67:	eb 22                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f69:	90                   	nop
80100f6a:	eb 1f                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 1c                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f6f:	90                   	nop
80100f70:	eb 19                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f72:	90                   	nop
80100f73:	eb 16                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f75:	90                   	nop
80100f76:	eb 13                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f78:	90                   	nop
80100f79:	eb 10                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7b:	90                   	nop
80100f7c:	eb 0d                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7e:	90                   	nop
80100f7f:	eb 0a                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f81:	90                   	nop
80100f82:	eb 07                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f84:	90                   	nop
80100f85:	eb 04                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f87:	90                   	nop
80100f88:	eb 01                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f8a:	90                   	nop

 bad:
  if(pgdir)
80100f8b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f8f:	74 0e                	je     80100f9f <exec+0x41f>
    freevm(pgdir);
80100f91:	83 ec 0c             	sub    $0xc,%esp
80100f94:	ff 75 d4             	push   -0x2c(%ebp)
80100f97:	e8 91 6d 00 00       	call   80107d2d <freevm>
80100f9c:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f9f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa3:	74 13                	je     80100fb8 <exec+0x438>
    iunlockput(ip);
80100fa5:	83 ec 0c             	sub    $0xc,%esp
80100fa8:	ff 75 d8             	push   -0x28(%ebp)
80100fab:	e8 6b 0c 00 00       	call   80101c1b <iunlockput>
80100fb0:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb3:	e8 f4 25 00 00       	call   801035ac <end_op>
  }
  return -1;
80100fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fbd:	c9                   	leave  
80100fbe:	c3                   	ret    

80100fbf <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fbf:	55                   	push   %ebp
80100fc0:	89 e5                	mov    %esp,%ebp
80100fc2:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc5:	83 ec 08             	sub    $0x8,%esp
80100fc8:	68 01 a4 10 80       	push   $0x8010a401
80100fcd:	68 a0 4a 11 80       	push   $0x80114aa0
80100fd2:	e8 df 3b 00 00       	call   80104bb6 <initlock>
80100fd7:	83 c4 10             	add    $0x10,%esp
}
80100fda:	90                   	nop
80100fdb:	c9                   	leave  
80100fdc:	c3                   	ret    

80100fdd <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fdd:	55                   	push   %ebp
80100fde:	89 e5                	mov    %esp,%ebp
80100fe0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe3:	83 ec 0c             	sub    $0xc,%esp
80100fe6:	68 a0 4a 11 80       	push   $0x80114aa0
80100feb:	e8 e8 3b 00 00       	call   80104bd8 <acquire>
80100ff0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff3:	c7 45 f4 d4 4a 11 80 	movl   $0x80114ad4,-0xc(%ebp)
80100ffa:	eb 2d                	jmp    80101029 <filealloc+0x4c>
    if(f->ref == 0){
80100ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fff:	8b 40 04             	mov    0x4(%eax),%eax
80101002:	85 c0                	test   %eax,%eax
80101004:	75 1f                	jne    80101025 <filealloc+0x48>
      f->ref = 1;
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101010:	83 ec 0c             	sub    $0xc,%esp
80101013:	68 a0 4a 11 80       	push   $0x80114aa0
80101018:	e8 29 3c 00 00       	call   80104c46 <release>
8010101d:	83 c4 10             	add    $0x10,%esp
      return f;
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	eb 23                	jmp    80101048 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101025:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101029:	b8 34 54 11 80       	mov    $0x80115434,%eax
8010102e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101031:	72 c9                	jb     80100ffc <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 a0 4a 11 80       	push   $0x80114aa0
8010103b:	e8 06 3c 00 00       	call   80104c46 <release>
80101040:	83 c4 10             	add    $0x10,%esp
  return 0;
80101043:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101048:	c9                   	leave  
80101049:	c3                   	ret    

8010104a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104a:	55                   	push   %ebp
8010104b:	89 e5                	mov    %esp,%ebp
8010104d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101050:	83 ec 0c             	sub    $0xc,%esp
80101053:	68 a0 4a 11 80       	push   $0x80114aa0
80101058:	e8 7b 3b 00 00       	call   80104bd8 <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 08 a4 10 80       	push   $0x8010a408
80101072:	e8 32 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101077:	8b 45 08             	mov    0x8(%ebp),%eax
8010107a:	8b 40 04             	mov    0x4(%eax),%eax
8010107d:	8d 50 01             	lea    0x1(%eax),%edx
80101080:	8b 45 08             	mov    0x8(%ebp),%eax
80101083:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	68 a0 4a 11 80       	push   $0x80114aa0
8010108e:	e8 b3 3b 00 00       	call   80104c46 <release>
80101093:	83 c4 10             	add    $0x10,%esp
  return f;
80101096:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101099:	c9                   	leave  
8010109a:	c3                   	ret    

8010109b <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109b:	55                   	push   %ebp
8010109c:	89 e5                	mov    %esp,%ebp
8010109e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a1:	83 ec 0c             	sub    $0xc,%esp
801010a4:	68 a0 4a 11 80       	push   $0x80114aa0
801010a9:	e8 2a 3b 00 00       	call   80104bd8 <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 10 a4 10 80       	push   $0x8010a410
801010c3:	e8 e1 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c8:	8b 45 08             	mov    0x8(%ebp),%eax
801010cb:	8b 40 04             	mov    0x4(%eax),%eax
801010ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d1:	8b 45 08             	mov    0x8(%ebp),%eax
801010d4:	89 50 04             	mov    %edx,0x4(%eax)
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 04             	mov    0x4(%eax),%eax
801010dd:	85 c0                	test   %eax,%eax
801010df:	7e 15                	jle    801010f6 <fileclose+0x5b>
    release(&ftable.lock);
801010e1:	83 ec 0c             	sub    $0xc,%esp
801010e4:	68 a0 4a 11 80       	push   $0x80114aa0
801010e9:	e8 58 3b 00 00       	call   80104c46 <release>
801010ee:	83 c4 10             	add    $0x10,%esp
801010f1:	e9 8b 00 00 00       	jmp    80101181 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8b 10                	mov    (%eax),%edx
801010fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010fe:	8b 50 04             	mov    0x4(%eax),%edx
80101101:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101104:	8b 50 08             	mov    0x8(%eax),%edx
80101107:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110a:	8b 50 0c             	mov    0xc(%eax),%edx
8010110d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101110:	8b 50 10             	mov    0x10(%eax),%edx
80101113:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101116:	8b 40 14             	mov    0x14(%eax),%eax
80101119:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111c:	8b 45 08             	mov    0x8(%ebp),%eax
8010111f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010112f:	83 ec 0c             	sub    $0xc,%esp
80101132:	68 a0 4a 11 80       	push   $0x80114aa0
80101137:	e8 0a 3b 00 00       	call   80104c46 <release>
8010113c:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010113f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101142:	83 f8 01             	cmp    $0x1,%eax
80101145:	75 19                	jne    80101160 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101147:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114b:	0f be d0             	movsbl %al,%edx
8010114e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101151:	83 ec 08             	sub    $0x8,%esp
80101154:	52                   	push   %edx
80101155:	50                   	push   %eax
80101156:	e8 48 2a 00 00       	call   80103ba3 <pipeclose>
8010115b:	83 c4 10             	add    $0x10,%esp
8010115e:	eb 21                	jmp    80101181 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101160:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101163:	83 f8 02             	cmp    $0x2,%eax
80101166:	75 19                	jne    80101181 <fileclose+0xe6>
    begin_op();
80101168:	e8 b3 23 00 00       	call   80103520 <begin_op>
    iput(ff.ip);
8010116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101170:	83 ec 0c             	sub    $0xc,%esp
80101173:	50                   	push   %eax
80101174:	e8 d2 09 00 00       	call   80101b4b <iput>
80101179:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117c:	e8 2b 24 00 00       	call   801035ac <end_op>
  }
}
80101181:	c9                   	leave  
80101182:	c3                   	ret    

80101183 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101183:	55                   	push   %ebp
80101184:	89 e5                	mov    %esp,%ebp
80101186:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101189:	8b 45 08             	mov    0x8(%ebp),%eax
8010118c:	8b 00                	mov    (%eax),%eax
8010118e:	83 f8 02             	cmp    $0x2,%eax
80101191:	75 40                	jne    801011d3 <filestat+0x50>
    ilock(f->ip);
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 40 10             	mov    0x10(%eax),%eax
80101199:	83 ec 0c             	sub    $0xc,%esp
8010119c:	50                   	push   %eax
8010119d:	e8 48 08 00 00       	call   801019ea <ilock>
801011a2:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
801011a8:	8b 40 10             	mov    0x10(%eax),%eax
801011ab:	83 ec 08             	sub    $0x8,%esp
801011ae:	ff 75 0c             	push   0xc(%ebp)
801011b1:	50                   	push   %eax
801011b2:	e8 d9 0c 00 00       	call   80101e90 <stati>
801011b7:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 40 10             	mov    0x10(%eax),%eax
801011c0:	83 ec 0c             	sub    $0xc,%esp
801011c3:	50                   	push   %eax
801011c4:	e8 34 09 00 00       	call   80101afd <iunlock>
801011c9:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cc:	b8 00 00 00 00       	mov    $0x0,%eax
801011d1:	eb 05                	jmp    801011d8 <filestat+0x55>
  }
  return -1;
801011d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d8:	c9                   	leave  
801011d9:	c3                   	ret    

801011da <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011da:	55                   	push   %ebp
801011db:	89 e5                	mov    %esp,%ebp
801011dd:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e0:	8b 45 08             	mov    0x8(%ebp),%eax
801011e3:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e7:	84 c0                	test   %al,%al
801011e9:	75 0a                	jne    801011f5 <fileread+0x1b>
    return -1;
801011eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f0:	e9 9b 00 00 00       	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 00                	mov    (%eax),%eax
801011fa:	83 f8 01             	cmp    $0x1,%eax
801011fd:	75 1a                	jne    80101219 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 40 0c             	mov    0xc(%eax),%eax
80101205:	83 ec 04             	sub    $0x4,%esp
80101208:	ff 75 10             	push   0x10(%ebp)
8010120b:	ff 75 0c             	push   0xc(%ebp)
8010120e:	50                   	push   %eax
8010120f:	e8 3c 2b 00 00       	call   80103d50 <piperead>
80101214:	83 c4 10             	add    $0x10,%esp
80101217:	eb 77                	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_INODE){
80101219:	8b 45 08             	mov    0x8(%ebp),%eax
8010121c:	8b 00                	mov    (%eax),%eax
8010121e:	83 f8 02             	cmp    $0x2,%eax
80101221:	75 60                	jne    80101283 <fileread+0xa9>
    ilock(f->ip);
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 10             	mov    0x10(%eax),%eax
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	50                   	push   %eax
8010122d:	e8 b8 07 00 00       	call   801019ea <ilock>
80101232:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101235:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 50 14             	mov    0x14(%eax),%edx
8010123e:	8b 45 08             	mov    0x8(%ebp),%eax
80101241:	8b 40 10             	mov    0x10(%eax),%eax
80101244:	51                   	push   %ecx
80101245:	52                   	push   %edx
80101246:	ff 75 0c             	push   0xc(%ebp)
80101249:	50                   	push   %eax
8010124a:	e8 87 0c 00 00       	call   80101ed6 <readi>
8010124f:	83 c4 10             	add    $0x10,%esp
80101252:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101259:	7e 11                	jle    8010126c <fileread+0x92>
      f->off += r;
8010125b:	8b 45 08             	mov    0x8(%ebp),%eax
8010125e:	8b 50 14             	mov    0x14(%eax),%edx
80101261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101264:	01 c2                	add    %eax,%edx
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 40 10             	mov    0x10(%eax),%eax
80101272:	83 ec 0c             	sub    $0xc,%esp
80101275:	50                   	push   %eax
80101276:	e8 82 08 00 00       	call   80101afd <iunlock>
8010127b:	83 c4 10             	add    $0x10,%esp
    return r;
8010127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101281:	eb 0d                	jmp    80101290 <fileread+0xb6>
  }
  panic("fileread");
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	68 1a a4 10 80       	push   $0x8010a41a
8010128b:	e8 19 f3 ff ff       	call   801005a9 <panic>
}
80101290:	c9                   	leave  
80101291:	c3                   	ret    

80101292 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101292:	55                   	push   %ebp
80101293:	89 e5                	mov    %esp,%ebp
80101295:	53                   	push   %ebx
80101296:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a0:	84 c0                	test   %al,%al
801012a2:	75 0a                	jne    801012ae <filewrite+0x1c>
    return -1;
801012a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a9:	e9 1b 01 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 00                	mov    (%eax),%eax
801012b3:	83 f8 01             	cmp    $0x1,%eax
801012b6:	75 1d                	jne    801012d5 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 40 0c             	mov    0xc(%eax),%eax
801012be:	83 ec 04             	sub    $0x4,%esp
801012c1:	ff 75 10             	push   0x10(%ebp)
801012c4:	ff 75 0c             	push   0xc(%ebp)
801012c7:	50                   	push   %eax
801012c8:	e8 81 29 00 00       	call   80103c4e <pipewrite>
801012cd:	83 c4 10             	add    $0x10,%esp
801012d0:	e9 f4 00 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_INODE){
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	8b 00                	mov    (%eax),%eax
801012da:	83 f8 02             	cmp    $0x2,%eax
801012dd:	0f 85 d9 00 00 00    	jne    801013bc <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012e3:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f1:	e9 a3 00 00 00       	jmp    80101399 <filewrite+0x107>
      int n1 = n - i;
801012f6:	8b 45 10             	mov    0x10(%ebp),%eax
801012f9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101302:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101305:	7e 06                	jle    8010130d <filewrite+0x7b>
        n1 = max;
80101307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010130d:	e8 0e 22 00 00       	call   80103520 <begin_op>
      ilock(f->ip);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	8b 40 10             	mov    0x10(%eax),%eax
80101318:	83 ec 0c             	sub    $0xc,%esp
8010131b:	50                   	push   %eax
8010131c:	e8 c9 06 00 00       	call   801019ea <ilock>
80101321:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101324:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101327:	8b 45 08             	mov    0x8(%ebp),%eax
8010132a:	8b 50 14             	mov    0x14(%eax),%edx
8010132d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101330:	8b 45 0c             	mov    0xc(%ebp),%eax
80101333:	01 c3                	add    %eax,%ebx
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	8b 40 10             	mov    0x10(%eax),%eax
8010133b:	51                   	push   %ecx
8010133c:	52                   	push   %edx
8010133d:	53                   	push   %ebx
8010133e:	50                   	push   %eax
8010133f:	e8 e7 0c 00 00       	call   8010202b <writei>
80101344:	83 c4 10             	add    $0x10,%esp
80101347:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010134e:	7e 11                	jle    80101361 <filewrite+0xcf>
        f->off += r;
80101350:	8b 45 08             	mov    0x8(%ebp),%eax
80101353:	8b 50 14             	mov    0x14(%eax),%edx
80101356:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101359:	01 c2                	add    %eax,%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 10             	mov    0x10(%eax),%eax
80101367:	83 ec 0c             	sub    $0xc,%esp
8010136a:	50                   	push   %eax
8010136b:	e8 8d 07 00 00       	call   80101afd <iunlock>
80101370:	83 c4 10             	add    $0x10,%esp
      end_op();
80101373:	e8 34 22 00 00       	call   801035ac <end_op>

      if(r < 0)
80101378:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137c:	78 29                	js     801013a7 <filewrite+0x115>
        break;
      if(r != n1)
8010137e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101381:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101384:	74 0d                	je     80101393 <filewrite+0x101>
        panic("short filewrite");
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	68 23 a4 10 80       	push   $0x8010a423
8010138e:	e8 16 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101393:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101396:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010139f:	0f 8c 51 ff ff ff    	jl     801012f6 <filewrite+0x64>
801013a5:	eb 01                	jmp    801013a8 <filewrite+0x116>
        break;
801013a7:	90                   	nop
    }
    return i == n ? n : -1;
801013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ae:	75 05                	jne    801013b5 <filewrite+0x123>
801013b0:	8b 45 10             	mov    0x10(%ebp),%eax
801013b3:	eb 14                	jmp    801013c9 <filewrite+0x137>
801013b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013ba:	eb 0d                	jmp    801013c9 <filewrite+0x137>
  }
  panic("filewrite");
801013bc:	83 ec 0c             	sub    $0xc,%esp
801013bf:	68 33 a4 10 80       	push   $0x8010a433
801013c4:	e8 e0 f1 ff ff       	call   801005a9 <panic>
}
801013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cc:	c9                   	leave  
801013cd:	c3                   	ret    

801013ce <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013ce:	55                   	push   %ebp
801013cf:	89 e5                	mov    %esp,%ebp
801013d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d4:	8b 45 08             	mov    0x8(%ebp),%eax
801013d7:	83 ec 08             	sub    $0x8,%esp
801013da:	6a 01                	push   $0x1
801013dc:	50                   	push   %eax
801013dd:	e8 1f ee ff ff       	call   80100201 <bread>
801013e2:	83 c4 10             	add    $0x10,%esp
801013e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013eb:	83 c0 5c             	add    $0x5c,%eax
801013ee:	83 ec 04             	sub    $0x4,%esp
801013f1:	6a 1c                	push   $0x1c
801013f3:	50                   	push   %eax
801013f4:	ff 75 0c             	push   0xc(%ebp)
801013f7:	e8 11 3b 00 00       	call   80104f0d <memmove>
801013fc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	ff 75 f4             	push   -0xc(%ebp)
80101405:	e8 79 ee ff ff       	call   80100283 <brelse>
8010140a:	83 c4 10             	add    $0x10,%esp
}
8010140d:	90                   	nop
8010140e:	c9                   	leave  
8010140f:	c3                   	ret    

80101410 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101410:	55                   	push   %ebp
80101411:	89 e5                	mov    %esp,%ebp
80101413:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101416:	8b 55 0c             	mov    0xc(%ebp),%edx
80101419:	8b 45 08             	mov    0x8(%ebp),%eax
8010141c:	83 ec 08             	sub    $0x8,%esp
8010141f:	52                   	push   %edx
80101420:	50                   	push   %eax
80101421:	e8 db ed ff ff       	call   80100201 <bread>
80101426:	83 c4 10             	add    $0x10,%esp
80101429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142f:	83 c0 5c             	add    $0x5c,%eax
80101432:	83 ec 04             	sub    $0x4,%esp
80101435:	68 00 02 00 00       	push   $0x200
8010143a:	6a 00                	push   $0x0
8010143c:	50                   	push   %eax
8010143d:	e8 0c 3a 00 00       	call   80104e4e <memset>
80101442:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	ff 75 f4             	push   -0xc(%ebp)
8010144b:	e8 09 23 00 00       	call   80103759 <log_write>
80101450:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	push   -0xc(%ebp)
80101459:	e8 25 ee ff ff       	call   80100283 <brelse>
8010145e:	83 c4 10             	add    $0x10,%esp
}
80101461:	90                   	nop
80101462:	c9                   	leave  
80101463:	c3                   	ret    

80101464 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101464:	55                   	push   %ebp
80101465:	89 e5                	mov    %esp,%ebp
80101467:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101471:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101478:	e9 0b 01 00 00       	jmp    80101588 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101480:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101486:	85 c0                	test   %eax,%eax
80101488:	0f 48 c2             	cmovs  %edx,%eax
8010148b:	c1 f8 0c             	sar    $0xc,%eax
8010148e:	89 c2                	mov    %eax,%edx
80101490:	a1 58 54 11 80       	mov    0x80115458,%eax
80101495:	01 d0                	add    %edx,%eax
80101497:	83 ec 08             	sub    $0x8,%esp
8010149a:	50                   	push   %eax
8010149b:	ff 75 08             	push   0x8(%ebp)
8010149e:	e8 5e ed ff ff       	call   80100201 <bread>
801014a3:	83 c4 10             	add    $0x10,%esp
801014a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b0:	e9 9e 00 00 00       	jmp    80101553 <balloc+0xef>
      m = 1 << (bi % 8);
801014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b8:	83 e0 07             	and    $0x7,%eax
801014bb:	ba 01 00 00 00       	mov    $0x1,%edx
801014c0:	89 c1                	mov    %eax,%ecx
801014c2:	d3 e2                	shl    %cl,%edx
801014c4:	89 d0                	mov    %edx,%eax
801014c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cc:	8d 50 07             	lea    0x7(%eax),%edx
801014cf:	85 c0                	test   %eax,%eax
801014d1:	0f 48 c2             	cmovs  %edx,%eax
801014d4:	c1 f8 03             	sar    $0x3,%eax
801014d7:	89 c2                	mov    %eax,%edx
801014d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014dc:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014e1:	0f b6 c0             	movzbl %al,%eax
801014e4:	23 45 e8             	and    -0x18(%ebp),%eax
801014e7:	85 c0                	test   %eax,%eax
801014e9:	75 64                	jne    8010154f <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ee:	8d 50 07             	lea    0x7(%eax),%edx
801014f1:	85 c0                	test   %eax,%eax
801014f3:	0f 48 c2             	cmovs  %edx,%eax
801014f6:	c1 f8 03             	sar    $0x3,%eax
801014f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fc:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101501:	89 d1                	mov    %edx,%ecx
80101503:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101506:	09 ca                	or     %ecx,%edx
80101508:	89 d1                	mov    %edx,%ecx
8010150a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150d:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101511:	83 ec 0c             	sub    $0xc,%esp
80101514:	ff 75 ec             	push   -0x14(%ebp)
80101517:	e8 3d 22 00 00       	call   80103759 <log_write>
8010151c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010151f:	83 ec 0c             	sub    $0xc,%esp
80101522:	ff 75 ec             	push   -0x14(%ebp)
80101525:	e8 59 ed ff ff       	call   80100283 <brelse>
8010152a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	01 c2                	add    %eax,%edx
80101535:	8b 45 08             	mov    0x8(%ebp),%eax
80101538:	83 ec 08             	sub    $0x8,%esp
8010153b:	52                   	push   %edx
8010153c:	50                   	push   %eax
8010153d:	e8 ce fe ff ff       	call   80101410 <bzero>
80101542:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101545:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154b:	01 d0                	add    %edx,%eax
8010154d:	eb 57                	jmp    801015a6 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010154f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101553:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010155a:	7f 17                	jg     80101573 <balloc+0x10f>
8010155c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101562:	01 d0                	add    %edx,%eax
80101564:	89 c2                	mov    %eax,%edx
80101566:	a1 40 54 11 80       	mov    0x80115440,%eax
8010156b:	39 c2                	cmp    %eax,%edx
8010156d:	0f 82 42 ff ff ff    	jb     801014b5 <balloc+0x51>
      }
    }
    brelse(bp);
80101573:	83 ec 0c             	sub    $0xc,%esp
80101576:	ff 75 ec             	push   -0x14(%ebp)
80101579:	e8 05 ed ff ff       	call   80100283 <brelse>
8010157e:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101581:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101588:	8b 15 40 54 11 80    	mov    0x80115440,%edx
8010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101591:	39 c2                	cmp    %eax,%edx
80101593:	0f 87 e4 fe ff ff    	ja     8010147d <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101599:	83 ec 0c             	sub    $0xc,%esp
8010159c:	68 40 a4 10 80       	push   $0x8010a440
801015a1:	e8 03 f0 ff ff       	call   801005a9 <panic>
}
801015a6:	c9                   	leave  
801015a7:	c3                   	ret    

801015a8 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a8:	55                   	push   %ebp
801015a9:	89 e5                	mov    %esp,%ebp
801015ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015ae:	83 ec 08             	sub    $0x8,%esp
801015b1:	68 40 54 11 80       	push   $0x80115440
801015b6:	ff 75 08             	push   0x8(%ebp)
801015b9:	e8 10 fe ff ff       	call   801013ce <readsb>
801015be:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c4:	c1 e8 0c             	shr    $0xc,%eax
801015c7:	89 c2                	mov    %eax,%edx
801015c9:	a1 58 54 11 80       	mov    0x80115458,%eax
801015ce:	01 c2                	add    %eax,%edx
801015d0:	8b 45 08             	mov    0x8(%ebp),%eax
801015d3:	83 ec 08             	sub    $0x8,%esp
801015d6:	52                   	push   %edx
801015d7:	50                   	push   %eax
801015d8:	e8 24 ec ff ff       	call   80100201 <bread>
801015dd:	83 c4 10             	add    $0x10,%esp
801015e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e6:	25 ff 0f 00 00       	and    $0xfff,%eax
801015eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f1:	83 e0 07             	and    $0x7,%eax
801015f4:	ba 01 00 00 00       	mov    $0x1,%edx
801015f9:	89 c1                	mov    %eax,%ecx
801015fb:	d3 e2                	shl    %cl,%edx
801015fd:	89 d0                	mov    %edx,%eax
801015ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101605:	8d 50 07             	lea    0x7(%eax),%edx
80101608:	85 c0                	test   %eax,%eax
8010160a:	0f 48 c2             	cmovs  %edx,%eax
8010160d:	c1 f8 03             	sar    $0x3,%eax
80101610:	89 c2                	mov    %eax,%edx
80101612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101615:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161a:	0f b6 c0             	movzbl %al,%eax
8010161d:	23 45 ec             	and    -0x14(%ebp),%eax
80101620:	85 c0                	test   %eax,%eax
80101622:	75 0d                	jne    80101631 <bfree+0x89>
    panic("freeing free block");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 56 a4 10 80       	push   $0x8010a456
8010162c:	e8 78 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101634:	8d 50 07             	lea    0x7(%eax),%edx
80101637:	85 c0                	test   %eax,%eax
80101639:	0f 48 c2             	cmovs  %edx,%eax
8010163c:	c1 f8 03             	sar    $0x3,%eax
8010163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101642:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101647:	89 d1                	mov    %edx,%ecx
80101649:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164c:	f7 d2                	not    %edx
8010164e:	21 ca                	and    %ecx,%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101655:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101659:	83 ec 0c             	sub    $0xc,%esp
8010165c:	ff 75 f4             	push   -0xc(%ebp)
8010165f:	e8 f5 20 00 00       	call   80103759 <log_write>
80101664:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101667:	83 ec 0c             	sub    $0xc,%esp
8010166a:	ff 75 f4             	push   -0xc(%ebp)
8010166d:	e8 11 ec ff ff       	call   80100283 <brelse>
80101672:	83 c4 10             	add    $0x10,%esp
}
80101675:	90                   	nop
80101676:	c9                   	leave  
80101677:	c3                   	ret    

80101678 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101678:	55                   	push   %ebp
80101679:	89 e5                	mov    %esp,%ebp
8010167b:	57                   	push   %edi
8010167c:	56                   	push   %esi
8010167d:	53                   	push   %ebx
8010167e:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101681:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101688:	83 ec 08             	sub    $0x8,%esp
8010168b:	68 69 a4 10 80       	push   $0x8010a469
80101690:	68 60 54 11 80       	push   $0x80115460
80101695:	e8 1c 35 00 00       	call   80104bb6 <initlock>
8010169a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010169d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016a4:	eb 2d                	jmp    801016d3 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016a9:	89 d0                	mov    %edx,%eax
801016ab:	c1 e0 03             	shl    $0x3,%eax
801016ae:	01 d0                	add    %edx,%eax
801016b0:	c1 e0 04             	shl    $0x4,%eax
801016b3:	83 c0 30             	add    $0x30,%eax
801016b6:	05 60 54 11 80       	add    $0x80115460,%eax
801016bb:	83 c0 10             	add    $0x10,%eax
801016be:	83 ec 08             	sub    $0x8,%esp
801016c1:	68 70 a4 10 80       	push   $0x8010a470
801016c6:	50                   	push   %eax
801016c7:	e8 8d 33 00 00       	call   80104a59 <initsleeplock>
801016cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d7:	7e cd                	jle    801016a6 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016d9:	83 ec 08             	sub    $0x8,%esp
801016dc:	68 40 54 11 80       	push   $0x80115440
801016e1:	ff 75 08             	push   0x8(%ebp)
801016e4:	e8 e5 fc ff ff       	call   801013ce <readsb>
801016e9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ec:	a1 58 54 11 80       	mov    0x80115458,%eax
801016f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f4:	8b 3d 54 54 11 80    	mov    0x80115454,%edi
801016fa:	8b 35 50 54 11 80    	mov    0x80115450,%esi
80101700:	8b 1d 4c 54 11 80    	mov    0x8011544c,%ebx
80101706:	8b 0d 48 54 11 80    	mov    0x80115448,%ecx
8010170c:	8b 15 44 54 11 80    	mov    0x80115444,%edx
80101712:	a1 40 54 11 80       	mov    0x80115440,%eax
80101717:	ff 75 d4             	push   -0x2c(%ebp)
8010171a:	57                   	push   %edi
8010171b:	56                   	push   %esi
8010171c:	53                   	push   %ebx
8010171d:	51                   	push   %ecx
8010171e:	52                   	push   %edx
8010171f:	50                   	push   %eax
80101720:	68 78 a4 10 80       	push   $0x8010a478
80101725:	e8 ca ec ff ff       	call   801003f4 <cprintf>
8010172a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010172d:	90                   	nop
8010172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101731:	5b                   	pop    %ebx
80101732:	5e                   	pop    %esi
80101733:	5f                   	pop    %edi
80101734:	5d                   	pop    %ebp
80101735:	c3                   	ret    

80101736 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	83 ec 28             	sub    $0x28,%esp
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173f:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101743:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010174a:	e9 9e 00 00 00       	jmp    801017ed <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101752:	c1 e8 03             	shr    $0x3,%eax
80101755:	89 c2                	mov    %eax,%edx
80101757:	a1 54 54 11 80       	mov    0x80115454,%eax
8010175c:	01 d0                	add    %edx,%eax
8010175e:	83 ec 08             	sub    $0x8,%esp
80101761:	50                   	push   %eax
80101762:	ff 75 08             	push   0x8(%ebp)
80101765:	e8 97 ea ff ff       	call   80100201 <bread>
8010176a:	83 c4 10             	add    $0x10,%esp
8010176d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101773:	8d 50 5c             	lea    0x5c(%eax),%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	83 e0 07             	and    $0x7,%eax
8010177c:	c1 e0 06             	shl    $0x6,%eax
8010177f:	01 d0                	add    %edx,%eax
80101781:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101784:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101787:	0f b7 00             	movzwl (%eax),%eax
8010178a:	66 85 c0             	test   %ax,%ax
8010178d:	75 4c                	jne    801017db <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010178f:	83 ec 04             	sub    $0x4,%esp
80101792:	6a 40                	push   $0x40
80101794:	6a 00                	push   $0x0
80101796:	ff 75 ec             	push   -0x14(%ebp)
80101799:	e8 b0 36 00 00       	call   80104e4e <memset>
8010179e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	ff 75 f0             	push   -0x10(%ebp)
801017b1:	e8 a3 1f 00 00       	call   80103759 <log_write>
801017b6:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017b9:	83 ec 0c             	sub    $0xc,%esp
801017bc:	ff 75 f0             	push   -0x10(%ebp)
801017bf:	e8 bf ea ff ff       	call   80100283 <brelse>
801017c4:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ca:	83 ec 08             	sub    $0x8,%esp
801017cd:	50                   	push   %eax
801017ce:	ff 75 08             	push   0x8(%ebp)
801017d1:	e8 f8 00 00 00       	call   801018ce <iget>
801017d6:	83 c4 10             	add    $0x10,%esp
801017d9:	eb 30                	jmp    8010180b <ialloc+0xd5>
    }
    brelse(bp);
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f0             	push   -0x10(%ebp)
801017e1:	e8 9d ea ff ff       	call   80100283 <brelse>
801017e6:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017ed:	8b 15 48 54 11 80    	mov    0x80115448,%edx
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	39 c2                	cmp    %eax,%edx
801017f8:	0f 87 51 ff ff ff    	ja     8010174f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017fe:	83 ec 0c             	sub    $0xc,%esp
80101801:	68 cb a4 10 80       	push   $0x8010a4cb
80101806:	e8 9e ed ff ff       	call   801005a9 <panic>
}
8010180b:	c9                   	leave  
8010180c:	c3                   	ret    

8010180d <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010180d:	55                   	push   %ebp
8010180e:	89 e5                	mov    %esp,%ebp
80101810:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	8b 40 04             	mov    0x4(%eax),%eax
80101819:	c1 e8 03             	shr    $0x3,%eax
8010181c:	89 c2                	mov    %eax,%edx
8010181e:	a1 54 54 11 80       	mov    0x80115454,%eax
80101823:	01 c2                	add    %eax,%edx
80101825:	8b 45 08             	mov    0x8(%ebp),%eax
80101828:	8b 00                	mov    (%eax),%eax
8010182a:	83 ec 08             	sub    $0x8,%esp
8010182d:	52                   	push   %edx
8010182e:	50                   	push   %eax
8010182f:	e8 cd e9 ff ff       	call   80100201 <bread>
80101834:	83 c4 10             	add    $0x10,%esp
80101837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	8b 40 04             	mov    0x4(%eax),%eax
80101846:	83 e0 07             	and    $0x7,%eax
80101849:	c1 e0 06             	shl    $0x6,%eax
8010184c:	01 d0                	add    %edx,%eax
8010184e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185e:	8b 45 08             	mov    0x8(%ebp),%eax
80101861:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101868:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101876:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010187a:	8b 45 08             	mov    0x8(%ebp),%eax
8010187d:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101884:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101888:	8b 45 08             	mov    0x8(%ebp),%eax
8010188b:	8b 50 58             	mov    0x58(%eax),%edx
8010188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101891:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101894:	8b 45 08             	mov    0x8(%ebp),%eax
80101897:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189d:	83 c0 0c             	add    $0xc,%eax
801018a0:	83 ec 04             	sub    $0x4,%esp
801018a3:	6a 34                	push   $0x34
801018a5:	52                   	push   %edx
801018a6:	50                   	push   %eax
801018a7:	e8 61 36 00 00       	call   80104f0d <memmove>
801018ac:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	ff 75 f4             	push   -0xc(%ebp)
801018b5:	e8 9f 1e 00 00       	call   80103759 <log_write>
801018ba:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018bd:	83 ec 0c             	sub    $0xc,%esp
801018c0:	ff 75 f4             	push   -0xc(%ebp)
801018c3:	e8 bb e9 ff ff       	call   80100283 <brelse>
801018c8:	83 c4 10             	add    $0x10,%esp
}
801018cb:	90                   	nop
801018cc:	c9                   	leave  
801018cd:	c3                   	ret    

801018ce <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018ce:	55                   	push   %ebp
801018cf:	89 e5                	mov    %esp,%ebp
801018d1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018d4:	83 ec 0c             	sub    $0xc,%esp
801018d7:	68 60 54 11 80       	push   $0x80115460
801018dc:	e8 f7 32 00 00       	call   80104bd8 <acquire>
801018e1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018eb:	c7 45 f4 94 54 11 80 	movl   $0x80115494,-0xc(%ebp)
801018f2:	eb 60                	jmp    80101954 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f7:	8b 40 08             	mov    0x8(%eax),%eax
801018fa:	85 c0                	test   %eax,%eax
801018fc:	7e 39                	jle    80101937 <iget+0x69>
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 00                	mov    (%eax),%eax
80101903:	39 45 08             	cmp    %eax,0x8(%ebp)
80101906:	75 2f                	jne    80101937 <iget+0x69>
80101908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190b:	8b 40 04             	mov    0x4(%eax),%eax
8010190e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101911:	75 24                	jne    80101937 <iget+0x69>
      ip->ref++;
80101913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101916:	8b 40 08             	mov    0x8(%eax),%eax
80101919:	8d 50 01             	lea    0x1(%eax),%edx
8010191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101922:	83 ec 0c             	sub    $0xc,%esp
80101925:	68 60 54 11 80       	push   $0x80115460
8010192a:	e8 17 33 00 00       	call   80104c46 <release>
8010192f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101935:	eb 77                	jmp    801019ae <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101937:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010193b:	75 10                	jne    8010194d <iget+0x7f>
8010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101940:	8b 40 08             	mov    0x8(%eax),%eax
80101943:	85 c0                	test   %eax,%eax
80101945:	75 06                	jne    8010194d <iget+0x7f>
      empty = ip;
80101947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101954:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
8010195b:	72 97                	jb     801018f4 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101961:	75 0d                	jne    80101970 <iget+0xa2>
    panic("iget: no inodes");
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 dd a4 10 80       	push   $0x8010a4dd
8010196b:	e8 39 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101973:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101979:	8b 55 08             	mov    0x8(%ebp),%edx
8010197c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 0c             	mov    0xc(%ebp),%edx
80101984:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101994:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010199b:	83 ec 0c             	sub    $0xc,%esp
8010199e:	68 60 54 11 80       	push   $0x80115460
801019a3:	e8 9e 32 00 00       	call   80104c46 <release>
801019a8:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b6:	83 ec 0c             	sub    $0xc,%esp
801019b9:	68 60 54 11 80       	push   $0x80115460
801019be:	e8 15 32 00 00       	call   80104bd8 <acquire>
801019c3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c6:	8b 45 08             	mov    0x8(%ebp),%eax
801019c9:	8b 40 08             	mov    0x8(%eax),%eax
801019cc:	8d 50 01             	lea    0x1(%eax),%edx
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d5:	83 ec 0c             	sub    $0xc,%esp
801019d8:	68 60 54 11 80       	push   $0x80115460
801019dd:	e8 64 32 00 00       	call   80104c46 <release>
801019e2:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e8:	c9                   	leave  
801019e9:	c3                   	ret    

801019ea <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019ea:	55                   	push   %ebp
801019eb:	89 e5                	mov    %esp,%ebp
801019ed:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019f4:	74 0a                	je     80101a00 <ilock+0x16>
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	8b 40 08             	mov    0x8(%eax),%eax
801019fc:	85 c0                	test   %eax,%eax
801019fe:	7f 0d                	jg     80101a0d <ilock+0x23>
    panic("ilock");
80101a00:	83 ec 0c             	sub    $0xc,%esp
80101a03:	68 ed a4 10 80       	push   $0x8010a4ed
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 79 30 00 00       	call   80104a95 <acquiresleep>
80101a1c:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a22:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a25:	85 c0                	test   %eax,%eax
80101a27:	0f 85 cd 00 00 00    	jne    80101afa <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 04             	mov    0x4(%eax),%eax
80101a33:	c1 e8 03             	shr    $0x3,%eax
80101a36:	89 c2                	mov    %eax,%edx
80101a38:	a1 54 54 11 80       	mov    0x80115454,%eax
80101a3d:	01 c2                	add    %eax,%edx
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 00                	mov    (%eax),%eax
80101a44:	83 ec 08             	sub    $0x8,%esp
80101a47:	52                   	push   %edx
80101a48:	50                   	push   %eax
80101a49:	e8 b3 e7 ff ff       	call   80100201 <bread>
80101a4e:	83 c4 10             	add    $0x10,%esp
80101a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a57:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5d:	8b 40 04             	mov    0x4(%eax),%eax
80101a60:	83 e0 07             	and    $0x7,%eax
80101a63:	c1 e0 06             	shl    $0x6,%eax
80101a66:	01 d0                	add    %edx,%eax
80101a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6e:	0f b7 10             	movzwl (%eax),%edx
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7b:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a82:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a89:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a97:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa5:	8b 50 08             	mov    0x8(%eax),%edx
80101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aab:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab1:	8d 50 0c             	lea    0xc(%eax),%edx
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	83 c0 5c             	add    $0x5c,%eax
80101aba:	83 ec 04             	sub    $0x4,%esp
80101abd:	6a 34                	push   $0x34
80101abf:	52                   	push   %edx
80101ac0:	50                   	push   %eax
80101ac1:	e8 47 34 00 00       	call   80104f0d <memmove>
80101ac6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ac9:	83 ec 0c             	sub    $0xc,%esp
80101acc:	ff 75 f4             	push   -0xc(%ebp)
80101acf:	e8 af e7 ff ff       	call   80100283 <brelse>
80101ad4:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae8:	66 85 c0             	test   %ax,%ax
80101aeb:	75 0d                	jne    80101afa <ilock+0x110>
      panic("ilock: no type");
80101aed:	83 ec 0c             	sub    $0xc,%esp
80101af0:	68 f3 a4 10 80       	push   $0x8010a4f3
80101af5:	e8 af ea ff ff       	call   801005a9 <panic>
  }
}
80101afa:	90                   	nop
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b07:	74 20                	je     80101b29 <iunlock+0x2c>
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	83 c0 0c             	add    $0xc,%eax
80101b0f:	83 ec 0c             	sub    $0xc,%esp
80101b12:	50                   	push   %eax
80101b13:	e8 2f 30 00 00       	call   80104b47 <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 02 a5 10 80       	push   $0x8010a502
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 b4 2f 00 00       	call   80104af9 <releasesleep>
80101b45:	83 c4 10             	add    $0x10,%esp
}
80101b48:	90                   	nop
80101b49:	c9                   	leave  
80101b4a:	c3                   	ret    

80101b4b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b4b:	55                   	push   %ebp
80101b4c:	89 e5                	mov    %esp,%ebp
80101b4e:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	83 c0 0c             	add    $0xc,%eax
80101b57:	83 ec 0c             	sub    $0xc,%esp
80101b5a:	50                   	push   %eax
80101b5b:	e8 35 2f 00 00       	call   80104a95 <acquiresleep>
80101b60:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b69:	85 c0                	test   %eax,%eax
80101b6b:	74 6a                	je     80101bd7 <iput+0x8c>
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b74:	66 85 c0             	test   %ax,%ax
80101b77:	75 5e                	jne    80101bd7 <iput+0x8c>
    acquire(&icache.lock);
80101b79:	83 ec 0c             	sub    $0xc,%esp
80101b7c:	68 60 54 11 80       	push   $0x80115460
80101b81:	e8 52 30 00 00       	call   80104bd8 <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 54 11 80       	push   $0x80115460
80101b9a:	e8 a7 30 00 00       	call   80104c46 <release>
80101b9f:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ba2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba6:	75 2f                	jne    80101bd7 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba8:	83 ec 0c             	sub    $0xc,%esp
80101bab:	ff 75 08             	push   0x8(%ebp)
80101bae:	e8 ad 01 00 00       	call   80101d60 <itrunc>
80101bb3:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb9:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bbf:	83 ec 0c             	sub    $0xc,%esp
80101bc2:	ff 75 08             	push   0x8(%ebp)
80101bc5:	e8 43 fc ff ff       	call   8010180d <iupdate>
80101bca:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bda:	83 c0 0c             	add    $0xc,%eax
80101bdd:	83 ec 0c             	sub    $0xc,%esp
80101be0:	50                   	push   %eax
80101be1:	e8 13 2f 00 00       	call   80104af9 <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 54 11 80       	push   $0x80115460
80101bf1:	e8 e2 2f 00 00       	call   80104bd8 <acquire>
80101bf6:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 40 08             	mov    0x8(%eax),%eax
80101bff:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	68 60 54 11 80       	push   $0x80115460
80101c10:	e8 31 30 00 00       	call   80104c46 <release>
80101c15:	83 c4 10             	add    $0x10,%esp
}
80101c18:	90                   	nop
80101c19:	c9                   	leave  
80101c1a:	c3                   	ret    

80101c1b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c1b:	55                   	push   %ebp
80101c1c:	89 e5                	mov    %esp,%ebp
80101c1e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c21:	83 ec 0c             	sub    $0xc,%esp
80101c24:	ff 75 08             	push   0x8(%ebp)
80101c27:	e8 d1 fe ff ff       	call   80101afd <iunlock>
80101c2c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	ff 75 08             	push   0x8(%ebp)
80101c35:	e8 11 ff ff ff       	call   80101b4b <iput>
80101c3a:	83 c4 10             	add    $0x10,%esp
}
80101c3d:	90                   	nop
80101c3e:	c9                   	leave  
80101c3f:	c3                   	ret    

80101c40 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c40:	55                   	push   %ebp
80101c41:	89 e5                	mov    %esp,%ebp
80101c43:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c46:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4a:	77 42                	ja     80101c8e <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c52:	83 c2 14             	add    $0x14,%edx
80101c55:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c60:	75 24                	jne    80101c86 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	8b 00                	mov    (%eax),%eax
80101c67:	83 ec 0c             	sub    $0xc,%esp
80101c6a:	50                   	push   %eax
80101c6b:	e8 f4 f7 ff ff       	call   80101464 <balloc>
80101c70:	83 c4 10             	add    $0x10,%esp
80101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7c:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c82:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c89:	e9 d0 00 00 00       	jmp    80101d5e <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c8e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c92:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c96:	0f 87 b5 00 00 00    	ja     80101d51 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cac:	75 20                	jne    80101cce <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	8b 00                	mov    (%eax),%eax
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	50                   	push   %eax
80101cb7:	e8 a8 f7 ff ff       	call   80101464 <balloc>
80101cbc:	83 c4 10             	add    $0x10,%esp
80101cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	8b 00                	mov    (%eax),%eax
80101cd3:	83 ec 08             	sub    $0x8,%esp
80101cd6:	ff 75 f4             	push   -0xc(%ebp)
80101cd9:	50                   	push   %eax
80101cda:	e8 22 e5 ff ff       	call   80100201 <bread>
80101cdf:	83 c4 10             	add    $0x10,%esp
80101ce2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce8:	83 c0 5c             	add    $0x5c,%eax
80101ceb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfb:	01 d0                	add    %edx,%eax
80101cfd:	8b 00                	mov    (%eax),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 36                	jne    80101d3e <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 4e f7 ff ff       	call   80101464 <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d29:	01 c2                	add    %eax,%edx
80101d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2e:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d30:	83 ec 0c             	sub    $0xc,%esp
80101d33:	ff 75 f0             	push   -0x10(%ebp)
80101d36:	e8 1e 1a 00 00       	call   80103759 <log_write>
80101d3b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	ff 75 f0             	push   -0x10(%ebp)
80101d44:	e8 3a e5 ff ff       	call   80100283 <brelse>
80101d49:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4f:	eb 0d                	jmp    80101d5e <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d51:	83 ec 0c             	sub    $0xc,%esp
80101d54:	68 0a a5 10 80       	push   $0x8010a50a
80101d59:	e8 4b e8 ff ff       	call   801005a9 <panic>
}
80101d5e:	c9                   	leave  
80101d5f:	c3                   	ret    

80101d60 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d60:	55                   	push   %ebp
80101d61:	89 e5                	mov    %esp,%ebp
80101d63:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d6d:	eb 45                	jmp    80101db4 <itrunc+0x54>
    if(ip->addrs[i]){
80101d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d75:	83 c2 14             	add    $0x14,%edx
80101d78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7c:	85 c0                	test   %eax,%eax
80101d7e:	74 30                	je     80101db0 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d86:	83 c2 14             	add    $0x14,%edx
80101d89:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8d:	8b 55 08             	mov    0x8(%ebp),%edx
80101d90:	8b 12                	mov    (%edx),%edx
80101d92:	83 ec 08             	sub    $0x8,%esp
80101d95:	50                   	push   %eax
80101d96:	52                   	push   %edx
80101d97:	e8 0c f8 ff ff       	call   801015a8 <bfree>
80101d9c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da5:	83 c2 14             	add    $0x14,%edx
80101da8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101daf:	00 
  for(i = 0; i < NDIRECT; i++){
80101db0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db8:	7e b5                	jle    80101d6f <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dba:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbd:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dc3:	85 c0                	test   %eax,%eax
80101dc5:	0f 84 aa 00 00 00    	je     80101e75 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	8b 00                	mov    (%eax),%eax
80101dd9:	83 ec 08             	sub    $0x8,%esp
80101ddc:	52                   	push   %edx
80101ddd:	50                   	push   %eax
80101dde:	e8 1e e4 ff ff       	call   80100201 <bread>
80101de3:	83 c4 10             	add    $0x10,%esp
80101de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dec:	83 c0 5c             	add    $0x5c,%eax
80101def:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101df9:	eb 3c                	jmp    80101e37 <itrunc+0xd7>
      if(a[j])
80101dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e08:	01 d0                	add    %edx,%eax
80101e0a:	8b 00                	mov    (%eax),%eax
80101e0c:	85 c0                	test   %eax,%eax
80101e0e:	74 23                	je     80101e33 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1d:	01 d0                	add    %edx,%eax
80101e1f:	8b 00                	mov    (%eax),%eax
80101e21:	8b 55 08             	mov    0x8(%ebp),%edx
80101e24:	8b 12                	mov    (%edx),%edx
80101e26:	83 ec 08             	sub    $0x8,%esp
80101e29:	50                   	push   %eax
80101e2a:	52                   	push   %edx
80101e2b:	e8 78 f7 ff ff       	call   801015a8 <bfree>
80101e30:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3a:	83 f8 7f             	cmp    $0x7f,%eax
80101e3d:	76 bc                	jbe    80101dfb <itrunc+0x9b>
    }
    brelse(bp);
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	ff 75 ec             	push   -0x14(%ebp)
80101e45:	e8 39 e4 ff ff       	call   80100283 <brelse>
80101e4a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e50:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e56:	8b 55 08             	mov    0x8(%ebp),%edx
80101e59:	8b 12                	mov    (%edx),%edx
80101e5b:	83 ec 08             	sub    $0x8,%esp
80101e5e:	50                   	push   %eax
80101e5f:	52                   	push   %edx
80101e60:	e8 43 f7 ff ff       	call   801015a8 <bfree>
80101e65:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e72:	00 00 00 
  }

  ip->size = 0;
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e7f:	83 ec 0c             	sub    $0xc,%esp
80101e82:	ff 75 08             	push   0x8(%ebp)
80101e85:	e8 83 f9 ff ff       	call   8010180d <iupdate>
80101e8a:	83 c4 10             	add    $0x10,%esp
}
80101e8d:	90                   	nop
80101e8e:	c9                   	leave  
80101e8f:	c3                   	ret    

80101e90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e90:	55                   	push   %ebp
80101e91:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 00                	mov    (%eax),%eax
80101e98:	89 c2                	mov    %eax,%edx
80101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	8b 50 04             	mov    0x4(%eax),%edx
80101ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea9:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	8b 50 58             	mov    0x58(%eax),%edx
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed3:	90                   	nop
80101ed4:	5d                   	pop    %ebp
80101ed5:	c3                   	ret    

80101ed6 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed6:	55                   	push   %ebp
80101ed7:	89 e5                	mov    %esp,%ebp
80101ed9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ee3:	66 83 f8 03          	cmp    $0x3,%ax
80101ee7:	75 5c                	jne    80101f45 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef0:	66 85 c0             	test   %ax,%ax
80101ef3:	78 20                	js     80101f15 <readi+0x3f>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efc:	66 83 f8 09          	cmp    $0x9,%ax
80101f00:	7f 13                	jg     80101f15 <readi+0x3f>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f09:	98                   	cwtl   
80101f0a:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <readi+0x49>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 0a 01 00 00       	jmp    80102029 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f2e:	8b 55 14             	mov    0x14(%ebp),%edx
80101f31:	83 ec 04             	sub    $0x4,%esp
80101f34:	52                   	push   %edx
80101f35:	ff 75 0c             	push   0xc(%ebp)
80101f38:	ff 75 08             	push   0x8(%ebp)
80101f3b:	ff d0                	call   *%eax
80101f3d:	83 c4 10             	add    $0x10,%esp
80101f40:	e9 e4 00 00 00       	jmp    80102029 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 40 58             	mov    0x58(%eax),%eax
80101f4b:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4e:	77 0d                	ja     80101f5d <readi+0x87>
80101f50:	8b 55 10             	mov    0x10(%ebp),%edx
80101f53:	8b 45 14             	mov    0x14(%ebp),%eax
80101f56:	01 d0                	add    %edx,%eax
80101f58:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5b:	76 0a                	jbe    80101f67 <readi+0x91>
    return -1;
80101f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f62:	e9 c2 00 00 00       	jmp    80102029 <readi+0x153>
  if(off + n > ip->size)
80101f67:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6d:	01 c2                	add    %eax,%edx
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 58             	mov    0x58(%eax),%eax
80101f75:	39 c2                	cmp    %eax,%edx
80101f77:	76 0c                	jbe    80101f85 <readi+0xaf>
    n = ip->size - off;
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	8b 40 58             	mov    0x58(%eax),%eax
80101f7f:	2b 45 10             	sub    0x10(%ebp),%eax
80101f82:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8c:	e9 89 00 00 00       	jmp    8010201a <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f91:	8b 45 10             	mov    0x10(%ebp),%eax
80101f94:	c1 e8 09             	shr    $0x9,%eax
80101f97:	83 ec 08             	sub    $0x8,%esp
80101f9a:	50                   	push   %eax
80101f9b:	ff 75 08             	push   0x8(%ebp)
80101f9e:	e8 9d fc ff ff       	call   80101c40 <bmap>
80101fa3:	83 c4 10             	add    $0x10,%esp
80101fa6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa9:	8b 12                	mov    (%edx),%edx
80101fab:	83 ec 08             	sub    $0x8,%esp
80101fae:	50                   	push   %eax
80101faf:	52                   	push   %edx
80101fb0:	e8 4c e2 ff ff       	call   80100201 <bread>
80101fb5:	83 c4 10             	add    $0x10,%esp
80101fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbe:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc3:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc8:	29 c2                	sub    %eax,%edx
80101fca:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd0:	39 c2                	cmp    %eax,%edx
80101fd2:	0f 46 c2             	cmovbe %edx,%eax
80101fd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdb:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fde:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe1:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	83 ec 04             	sub    $0x4,%esp
80101feb:	ff 75 ec             	push   -0x14(%ebp)
80101fee:	50                   	push   %eax
80101fef:	ff 75 0c             	push   0xc(%ebp)
80101ff2:	e8 16 2f 00 00       	call   80104f0d <memmove>
80101ff7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffa:	83 ec 0c             	sub    $0xc,%esp
80101ffd:	ff 75 f0             	push   -0x10(%ebp)
80102000:	e8 7e e2 ff ff       	call   80100283 <brelse>
80102005:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102008:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102011:	01 45 10             	add    %eax,0x10(%ebp)
80102014:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102017:	01 45 0c             	add    %eax,0xc(%ebp)
8010201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102020:	0f 82 6b ff ff ff    	jb     80101f91 <readi+0xbb>
  }
  return n;
80102026:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102029:	c9                   	leave  
8010202a:	c3                   	ret    

8010202b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202b:	55                   	push   %ebp
8010202c:	89 e5                	mov    %esp,%ebp
8010202e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102038:	66 83 f8 03          	cmp    $0x3,%ax
8010203c:	75 5c                	jne    8010209a <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102045:	66 85 c0             	test   %ax,%ax
80102048:	78 20                	js     8010206a <writei+0x3f>
8010204a:	8b 45 08             	mov    0x8(%ebp),%eax
8010204d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102051:	66 83 f8 09          	cmp    $0x9,%ax
80102055:	7f 13                	jg     8010206a <writei+0x3f>
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205e:	98                   	cwtl   
8010205f:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
80102066:	85 c0                	test   %eax,%eax
80102068:	75 0a                	jne    80102074 <writei+0x49>
      return -1;
8010206a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206f:	e9 3b 01 00 00       	jmp    801021af <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207b:	98                   	cwtl   
8010207c:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
80102083:	8b 55 14             	mov    0x14(%ebp),%edx
80102086:	83 ec 04             	sub    $0x4,%esp
80102089:	52                   	push   %edx
8010208a:	ff 75 0c             	push   0xc(%ebp)
8010208d:	ff 75 08             	push   0x8(%ebp)
80102090:	ff d0                	call   *%eax
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	e9 15 01 00 00       	jmp    801021af <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010209a:	8b 45 08             	mov    0x8(%ebp),%eax
8010209d:	8b 40 58             	mov    0x58(%eax),%eax
801020a0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a3:	77 0d                	ja     801020b2 <writei+0x87>
801020a5:	8b 55 10             	mov    0x10(%ebp),%edx
801020a8:	8b 45 14             	mov    0x14(%ebp),%eax
801020ab:	01 d0                	add    %edx,%eax
801020ad:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b0:	76 0a                	jbe    801020bc <writei+0x91>
    return -1;
801020b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b7:	e9 f3 00 00 00       	jmp    801021af <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020bc:	8b 55 10             	mov    0x10(%ebp),%edx
801020bf:	8b 45 14             	mov    0x14(%ebp),%eax
801020c2:	01 d0                	add    %edx,%eax
801020c4:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020c9:	76 0a                	jbe    801020d5 <writei+0xaa>
    return -1;
801020cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d0:	e9 da 00 00 00       	jmp    801021af <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dc:	e9 97 00 00 00       	jmp    80102178 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e1:	8b 45 10             	mov    0x10(%ebp),%eax
801020e4:	c1 e8 09             	shr    $0x9,%eax
801020e7:	83 ec 08             	sub    $0x8,%esp
801020ea:	50                   	push   %eax
801020eb:	ff 75 08             	push   0x8(%ebp)
801020ee:	e8 4d fb ff ff       	call   80101c40 <bmap>
801020f3:	83 c4 10             	add    $0x10,%esp
801020f6:	8b 55 08             	mov    0x8(%ebp),%edx
801020f9:	8b 12                	mov    (%edx),%edx
801020fb:	83 ec 08             	sub    $0x8,%esp
801020fe:	50                   	push   %eax
801020ff:	52                   	push   %edx
80102100:	e8 fc e0 ff ff       	call   80100201 <bread>
80102105:	83 c4 10             	add    $0x10,%esp
80102108:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210b:	8b 45 10             	mov    0x10(%ebp),%eax
8010210e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102113:	ba 00 02 00 00       	mov    $0x200,%edx
80102118:	29 c2                	sub    %eax,%edx
8010211a:	8b 45 14             	mov    0x14(%ebp),%eax
8010211d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102120:	39 c2                	cmp    %eax,%edx
80102122:	0f 46 c2             	cmovbe %edx,%eax
80102125:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010212e:	8b 45 10             	mov    0x10(%ebp),%eax
80102131:	25 ff 01 00 00       	and    $0x1ff,%eax
80102136:	01 d0                	add    %edx,%eax
80102138:	83 ec 04             	sub    $0x4,%esp
8010213b:	ff 75 ec             	push   -0x14(%ebp)
8010213e:	ff 75 0c             	push   0xc(%ebp)
80102141:	50                   	push   %eax
80102142:	e8 c6 2d 00 00       	call   80104f0d <memmove>
80102147:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214a:	83 ec 0c             	sub    $0xc,%esp
8010214d:	ff 75 f0             	push   -0x10(%ebp)
80102150:	e8 04 16 00 00       	call   80103759 <log_write>
80102155:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	ff 75 f0             	push   -0x10(%ebp)
8010215e:	e8 20 e1 ff ff       	call   80100283 <brelse>
80102163:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102169:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 10             	add    %eax,0x10(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 0c             	add    %eax,0xc(%ebp)
80102178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010217e:	0f 82 5d ff ff ff    	jb     801020e1 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102184:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102188:	74 22                	je     801021ac <writei+0x181>
8010218a:	8b 45 08             	mov    0x8(%ebp),%eax
8010218d:	8b 40 58             	mov    0x58(%eax),%eax
80102190:	39 45 10             	cmp    %eax,0x10(%ebp)
80102193:	76 17                	jbe    801021ac <writei+0x181>
    ip->size = off;
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 55 10             	mov    0x10(%ebp),%edx
8010219b:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010219e:	83 ec 0c             	sub    $0xc,%esp
801021a1:	ff 75 08             	push   0x8(%ebp)
801021a4:	e8 64 f6 ff ff       	call   8010180d <iupdate>
801021a9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ac:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021af:	c9                   	leave  
801021b0:	c3                   	ret    

801021b1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b1:	55                   	push   %ebp
801021b2:	89 e5                	mov    %esp,%ebp
801021b4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b7:	83 ec 04             	sub    $0x4,%esp
801021ba:	6a 0e                	push   $0xe
801021bc:	ff 75 0c             	push   0xc(%ebp)
801021bf:	ff 75 08             	push   0x8(%ebp)
801021c2:	e8 dc 2d 00 00       	call   80104fa3 <strncmp>
801021c7:	83 c4 10             	add    $0x10,%esp
}
801021ca:	c9                   	leave  
801021cb:	c3                   	ret    

801021cc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021cc:	55                   	push   %ebp
801021cd:	89 e5                	mov    %esp,%ebp
801021cf:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d2:	8b 45 08             	mov    0x8(%ebp),%eax
801021d5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021d9:	66 83 f8 01          	cmp    $0x1,%ax
801021dd:	74 0d                	je     801021ec <dirlookup+0x20>
    panic("dirlookup not DIR");
801021df:	83 ec 0c             	sub    $0xc,%esp
801021e2:	68 1d a5 10 80       	push   $0x8010a51d
801021e7:	e8 bd e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f3:	eb 7b                	jmp    80102270 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f5:	6a 10                	push   $0x10
801021f7:	ff 75 f4             	push   -0xc(%ebp)
801021fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021fd:	50                   	push   %eax
801021fe:	ff 75 08             	push   0x8(%ebp)
80102201:	e8 d0 fc ff ff       	call   80101ed6 <readi>
80102206:	83 c4 10             	add    $0x10,%esp
80102209:	83 f8 10             	cmp    $0x10,%eax
8010220c:	74 0d                	je     8010221b <dirlookup+0x4f>
      panic("dirlookup read");
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	68 2f a5 10 80       	push   $0x8010a52f
80102216:	e8 8e e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010221b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010221f:	66 85 c0             	test   %ax,%ax
80102222:	74 47                	je     8010226b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102224:	83 ec 08             	sub    $0x8,%esp
80102227:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222a:	83 c0 02             	add    $0x2,%eax
8010222d:	50                   	push   %eax
8010222e:	ff 75 0c             	push   0xc(%ebp)
80102231:	e8 7b ff ff ff       	call   801021b1 <namecmp>
80102236:	83 c4 10             	add    $0x10,%esp
80102239:	85 c0                	test   %eax,%eax
8010223b:	75 2f                	jne    8010226c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010223d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102241:	74 08                	je     8010224b <dirlookup+0x7f>
        *poff = off;
80102243:	8b 45 10             	mov    0x10(%ebp),%eax
80102246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102249:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010224f:	0f b7 c0             	movzwl %ax,%eax
80102252:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 00                	mov    (%eax),%eax
8010225a:	83 ec 08             	sub    $0x8,%esp
8010225d:	ff 75 f0             	push   -0x10(%ebp)
80102260:	50                   	push   %eax
80102261:	e8 68 f6 ff ff       	call   801018ce <iget>
80102266:	83 c4 10             	add    $0x10,%esp
80102269:	eb 19                	jmp    80102284 <dirlookup+0xb8>
      continue;
8010226b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	8b 40 58             	mov    0x58(%eax),%eax
80102276:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102279:	0f 82 76 ff ff ff    	jb     801021f5 <dirlookup+0x29>
    }
  }

  return 0;
8010227f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102286:	55                   	push   %ebp
80102287:	89 e5                	mov    %esp,%ebp
80102289:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228c:	83 ec 04             	sub    $0x4,%esp
8010228f:	6a 00                	push   $0x0
80102291:	ff 75 0c             	push   0xc(%ebp)
80102294:	ff 75 08             	push   0x8(%ebp)
80102297:	e8 30 ff ff ff       	call   801021cc <dirlookup>
8010229c:	83 c4 10             	add    $0x10,%esp
8010229f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a6:	74 18                	je     801022c0 <dirlink+0x3a>
    iput(ip);
801022a8:	83 ec 0c             	sub    $0xc,%esp
801022ab:	ff 75 f0             	push   -0x10(%ebp)
801022ae:	e8 98 f8 ff ff       	call   80101b4b <iput>
801022b3:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bb:	e9 9c 00 00 00       	jmp    8010235c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c7:	eb 39                	jmp    80102302 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cc:	6a 10                	push   $0x10
801022ce:	50                   	push   %eax
801022cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d2:	50                   	push   %eax
801022d3:	ff 75 08             	push   0x8(%ebp)
801022d6:	e8 fb fb ff ff       	call   80101ed6 <readi>
801022db:	83 c4 10             	add    $0x10,%esp
801022de:	83 f8 10             	cmp    $0x10,%eax
801022e1:	74 0d                	je     801022f0 <dirlink+0x6a>
      panic("dirlink read");
801022e3:	83 ec 0c             	sub    $0xc,%esp
801022e6:	68 3e a5 10 80       	push   $0x8010a53e
801022eb:	e8 b9 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f4:	66 85 c0             	test   %ax,%ax
801022f7:	74 18                	je     80102311 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fc:	83 c0 10             	add    $0x10,%eax
801022ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102302:	8b 45 08             	mov    0x8(%ebp),%eax
80102305:	8b 50 58             	mov    0x58(%eax),%edx
80102308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230b:	39 c2                	cmp    %eax,%edx
8010230d:	77 ba                	ja     801022c9 <dirlink+0x43>
8010230f:	eb 01                	jmp    80102312 <dirlink+0x8c>
      break;
80102311:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102312:	83 ec 04             	sub    $0x4,%esp
80102315:	6a 0e                	push   $0xe
80102317:	ff 75 0c             	push   0xc(%ebp)
8010231a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010231d:	83 c0 02             	add    $0x2,%eax
80102320:	50                   	push   %eax
80102321:	e8 d3 2c 00 00       	call   80104ff9 <strncpy>
80102326:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102329:	8b 45 10             	mov    0x10(%ebp),%eax
8010232c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102333:	6a 10                	push   $0x10
80102335:	50                   	push   %eax
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	50                   	push   %eax
8010233a:	ff 75 08             	push   0x8(%ebp)
8010233d:	e8 e9 fc ff ff       	call   8010202b <writei>
80102342:	83 c4 10             	add    $0x10,%esp
80102345:	83 f8 10             	cmp    $0x10,%eax
80102348:	74 0d                	je     80102357 <dirlink+0xd1>
    panic("dirlink");
8010234a:	83 ec 0c             	sub    $0xc,%esp
8010234d:	68 4b a5 10 80       	push   $0x8010a54b
80102352:	e8 52 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010235c:	c9                   	leave  
8010235d:	c3                   	ret    

8010235e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010235e:	55                   	push   %ebp
8010235f:	89 e5                	mov    %esp,%ebp
80102361:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102364:	eb 04                	jmp    8010236a <skipelem+0xc>
    path++;
80102366:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	0f b6 00             	movzbl (%eax),%eax
80102370:	3c 2f                	cmp    $0x2f,%al
80102372:	74 f2                	je     80102366 <skipelem+0x8>
  if(*path == 0)
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	84 c0                	test   %al,%al
8010237c:	75 07                	jne    80102385 <skipelem+0x27>
    return 0;
8010237e:	b8 00 00 00 00       	mov    $0x0,%eax
80102383:	eb 77                	jmp    801023fc <skipelem+0x9e>
  s = path;
80102385:	8b 45 08             	mov    0x8(%ebp),%eax
80102388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238b:	eb 04                	jmp    80102391 <skipelem+0x33>
    path++;
8010238d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102391:	8b 45 08             	mov    0x8(%ebp),%eax
80102394:	0f b6 00             	movzbl (%eax),%eax
80102397:	3c 2f                	cmp    $0x2f,%al
80102399:	74 0a                	je     801023a5 <skipelem+0x47>
8010239b:	8b 45 08             	mov    0x8(%ebp),%eax
8010239e:	0f b6 00             	movzbl (%eax),%eax
801023a1:	84 c0                	test   %al,%al
801023a3:	75 e8                	jne    8010238d <skipelem+0x2f>
  len = path - s;
801023a5:	8b 45 08             	mov    0x8(%ebp),%eax
801023a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b2:	7e 15                	jle    801023c9 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023b4:	83 ec 04             	sub    $0x4,%esp
801023b7:	6a 0e                	push   $0xe
801023b9:	ff 75 f4             	push   -0xc(%ebp)
801023bc:	ff 75 0c             	push   0xc(%ebp)
801023bf:	e8 49 2b 00 00       	call   80104f0d <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 32 2b 00 00       	call   80104f0d <memmove>
801023db:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023de:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e4:	01 d0                	add    %edx,%eax
801023e6:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023e9:	eb 04                	jmp    801023ef <skipelem+0x91>
    path++;
801023eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	0f b6 00             	movzbl (%eax),%eax
801023f5:	3c 2f                	cmp    $0x2f,%al
801023f7:	74 f2                	je     801023eb <skipelem+0x8d>
  return path;
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023fc:	c9                   	leave  
801023fd:	c3                   	ret    

801023fe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023fe:	55                   	push   %ebp
801023ff:	89 e5                	mov    %esp,%ebp
80102401:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102404:	8b 45 08             	mov    0x8(%ebp),%eax
80102407:	0f b6 00             	movzbl (%eax),%eax
8010240a:	3c 2f                	cmp    $0x2f,%al
8010240c:	75 17                	jne    80102425 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010240e:	83 ec 08             	sub    $0x8,%esp
80102411:	6a 01                	push   $0x1
80102413:	6a 01                	push   $0x1
80102415:	e8 b4 f4 ff ff       	call   801018ce <iget>
8010241a:	83 c4 10             	add    $0x10,%esp
8010241d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102420:	e9 ba 00 00 00       	jmp    801024df <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102425:	e8 ea 1a 00 00       	call   80103f14 <myproc>
8010242a:	8b 40 68             	mov    0x68(%eax),%eax
8010242d:	83 ec 0c             	sub    $0xc,%esp
80102430:	50                   	push   %eax
80102431:	e8 7a f5 ff ff       	call   801019b0 <idup>
80102436:	83 c4 10             	add    $0x10,%esp
80102439:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010243c:	e9 9e 00 00 00       	jmp    801024df <namex+0xe1>
    ilock(ip);
80102441:	83 ec 0c             	sub    $0xc,%esp
80102444:	ff 75 f4             	push   -0xc(%ebp)
80102447:	e8 9e f5 ff ff       	call   801019ea <ilock>
8010244c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010244f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102452:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102456:	66 83 f8 01          	cmp    $0x1,%ax
8010245a:	74 18                	je     80102474 <namex+0x76>
      iunlockput(ip);
8010245c:	83 ec 0c             	sub    $0xc,%esp
8010245f:	ff 75 f4             	push   -0xc(%ebp)
80102462:	e8 b4 f7 ff ff       	call   80101c1b <iunlockput>
80102467:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246a:	b8 00 00 00 00       	mov    $0x0,%eax
8010246f:	e9 a7 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102474:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102478:	74 20                	je     8010249a <namex+0x9c>
8010247a:	8b 45 08             	mov    0x8(%ebp),%eax
8010247d:	0f b6 00             	movzbl (%eax),%eax
80102480:	84 c0                	test   %al,%al
80102482:	75 16                	jne    8010249a <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102484:	83 ec 0c             	sub    $0xc,%esp
80102487:	ff 75 f4             	push   -0xc(%ebp)
8010248a:	e8 6e f6 ff ff       	call   80101afd <iunlock>
8010248f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102495:	e9 81 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010249a:	83 ec 04             	sub    $0x4,%esp
8010249d:	6a 00                	push   $0x0
8010249f:	ff 75 10             	push   0x10(%ebp)
801024a2:	ff 75 f4             	push   -0xc(%ebp)
801024a5:	e8 22 fd ff ff       	call   801021cc <dirlookup>
801024aa:	83 c4 10             	add    $0x10,%esp
801024ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024b4:	75 15                	jne    801024cb <namex+0xcd>
      iunlockput(ip);
801024b6:	83 ec 0c             	sub    $0xc,%esp
801024b9:	ff 75 f4             	push   -0xc(%ebp)
801024bc:	e8 5a f7 ff ff       	call   80101c1b <iunlockput>
801024c1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024c4:	b8 00 00 00 00       	mov    $0x0,%eax
801024c9:	eb 50                	jmp    8010251b <namex+0x11d>
    }
    iunlockput(ip);
801024cb:	83 ec 0c             	sub    $0xc,%esp
801024ce:	ff 75 f4             	push   -0xc(%ebp)
801024d1:	e8 45 f7 ff ff       	call   80101c1b <iunlockput>
801024d6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024df:	83 ec 08             	sub    $0x8,%esp
801024e2:	ff 75 10             	push   0x10(%ebp)
801024e5:	ff 75 08             	push   0x8(%ebp)
801024e8:	e8 71 fe ff ff       	call   8010235e <skipelem>
801024ed:	83 c4 10             	add    $0x10,%esp
801024f0:	89 45 08             	mov    %eax,0x8(%ebp)
801024f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f7:	0f 85 44 ff ff ff    	jne    80102441 <namex+0x43>
  }
  if(nameiparent){
801024fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102501:	74 15                	je     80102518 <namex+0x11a>
    iput(ip);
80102503:	83 ec 0c             	sub    $0xc,%esp
80102506:	ff 75 f4             	push   -0xc(%ebp)
80102509:	e8 3d f6 ff ff       	call   80101b4b <iput>
8010250e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102511:	b8 00 00 00 00       	mov    $0x0,%eax
80102516:	eb 03                	jmp    8010251b <namex+0x11d>
  }
  return ip;
80102518:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010251b:	c9                   	leave  
8010251c:	c3                   	ret    

8010251d <namei>:

struct inode*
namei(char *path)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102523:	83 ec 04             	sub    $0x4,%esp
80102526:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102529:	50                   	push   %eax
8010252a:	6a 00                	push   $0x0
8010252c:	ff 75 08             	push   0x8(%ebp)
8010252f:	e8 ca fe ff ff       	call   801023fe <namex>
80102534:	83 c4 10             	add    $0x10,%esp
}
80102537:	c9                   	leave  
80102538:	c3                   	ret    

80102539 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102539:	55                   	push   %ebp
8010253a:	89 e5                	mov    %esp,%ebp
8010253c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010253f:	83 ec 04             	sub    $0x4,%esp
80102542:	ff 75 0c             	push   0xc(%ebp)
80102545:	6a 01                	push   $0x1
80102547:	ff 75 08             	push   0x8(%ebp)
8010254a:	e8 af fe ff ff       	call   801023fe <namex>
8010254f:	83 c4 10             	add    $0x10,%esp
}
80102552:	c9                   	leave  
80102553:	c3                   	ret    

80102554 <inb>:
{
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
80102557:	83 ec 14             	sub    $0x14,%esp
8010255a:	8b 45 08             	mov    0x8(%ebp),%eax
8010255d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102561:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102565:	89 c2                	mov    %eax,%edx
80102567:	ec                   	in     (%dx),%al
80102568:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010256b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010256f:	c9                   	leave  
80102570:	c3                   	ret    

80102571 <insl>:
{
80102571:	55                   	push   %ebp
80102572:	89 e5                	mov    %esp,%ebp
80102574:	57                   	push   %edi
80102575:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102576:	8b 55 08             	mov    0x8(%ebp),%edx
80102579:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010257c:	8b 45 10             	mov    0x10(%ebp),%eax
8010257f:	89 cb                	mov    %ecx,%ebx
80102581:	89 df                	mov    %ebx,%edi
80102583:	89 c1                	mov    %eax,%ecx
80102585:	fc                   	cld    
80102586:	f3 6d                	rep insl (%dx),%es:(%edi)
80102588:	89 c8                	mov    %ecx,%eax
8010258a:	89 fb                	mov    %edi,%ebx
8010258c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010258f:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102592:	90                   	nop
80102593:	5b                   	pop    %ebx
80102594:	5f                   	pop    %edi
80102595:	5d                   	pop    %ebp
80102596:	c3                   	ret    

80102597 <outb>:
{
80102597:	55                   	push   %ebp
80102598:	89 e5                	mov    %esp,%ebp
8010259a:	83 ec 08             	sub    $0x8,%esp
8010259d:	8b 45 08             	mov    0x8(%ebp),%eax
801025a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801025a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801025a7:	89 d0                	mov    %edx,%eax
801025a9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025ac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025b0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025b4:	ee                   	out    %al,(%dx)
}
801025b5:	90                   	nop
801025b6:	c9                   	leave  
801025b7:	c3                   	ret    

801025b8 <outsl>:
{
801025b8:	55                   	push   %ebp
801025b9:	89 e5                	mov    %esp,%ebp
801025bb:	56                   	push   %esi
801025bc:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025bd:	8b 55 08             	mov    0x8(%ebp),%edx
801025c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025c3:	8b 45 10             	mov    0x10(%ebp),%eax
801025c6:	89 cb                	mov    %ecx,%ebx
801025c8:	89 de                	mov    %ebx,%esi
801025ca:	89 c1                	mov    %eax,%ecx
801025cc:	fc                   	cld    
801025cd:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025cf:	89 c8                	mov    %ecx,%eax
801025d1:	89 f3                	mov    %esi,%ebx
801025d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025d6:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025d9:	90                   	nop
801025da:	5b                   	pop    %ebx
801025db:	5e                   	pop    %esi
801025dc:	5d                   	pop    %ebp
801025dd:	c3                   	ret    

801025de <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025de:	55                   	push   %ebp
801025df:	89 e5                	mov    %esp,%ebp
801025e1:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801025e4:	90                   	nop
801025e5:	68 f7 01 00 00       	push   $0x1f7
801025ea:	e8 65 ff ff ff       	call   80102554 <inb>
801025ef:	83 c4 04             	add    $0x4,%esp
801025f2:	0f b6 c0             	movzbl %al,%eax
801025f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025fb:	25 c0 00 00 00       	and    $0xc0,%eax
80102600:	83 f8 40             	cmp    $0x40,%eax
80102603:	75 e0                	jne    801025e5 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102605:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102609:	74 11                	je     8010261c <idewait+0x3e>
8010260b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010260e:	83 e0 21             	and    $0x21,%eax
80102611:	85 c0                	test   %eax,%eax
80102613:	74 07                	je     8010261c <idewait+0x3e>
    return -1;
80102615:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010261a:	eb 05                	jmp    80102621 <idewait+0x43>
  return 0;
8010261c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102621:	c9                   	leave  
80102622:	c3                   	ret    

80102623 <ideinit>:

void
ideinit(void)
{
80102623:	55                   	push   %ebp
80102624:	89 e5                	mov    %esp,%ebp
80102626:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102629:	83 ec 08             	sub    $0x8,%esp
8010262c:	68 53 a5 10 80       	push   $0x8010a553
80102631:	68 c0 70 11 80       	push   $0x801170c0
80102636:	e8 7b 25 00 00       	call   80104bb6 <initlock>
8010263b:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010263e:	a1 80 9d 11 80       	mov    0x80119d80,%eax
80102643:	83 e8 01             	sub    $0x1,%eax
80102646:	83 ec 08             	sub    $0x8,%esp
80102649:	50                   	push   %eax
8010264a:	6a 0e                	push   $0xe
8010264c:	e8 c1 04 00 00       	call   80102b12 <ioapicenable>
80102651:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102654:	83 ec 0c             	sub    $0xc,%esp
80102657:	6a 00                	push   $0x0
80102659:	e8 80 ff ff ff       	call   801025de <idewait>
8010265e:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102661:	83 ec 08             	sub    $0x8,%esp
80102664:	68 f0 00 00 00       	push   $0xf0
80102669:	68 f6 01 00 00       	push   $0x1f6
8010266e:	e8 24 ff ff ff       	call   80102597 <outb>
80102673:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010267d:	eb 24                	jmp    801026a3 <ideinit+0x80>
    if(inb(0x1f7) != 0){
8010267f:	83 ec 0c             	sub    $0xc,%esp
80102682:	68 f7 01 00 00       	push   $0x1f7
80102687:	e8 c8 fe ff ff       	call   80102554 <inb>
8010268c:	83 c4 10             	add    $0x10,%esp
8010268f:	84 c0                	test   %al,%al
80102691:	74 0c                	je     8010269f <ideinit+0x7c>
      havedisk1 = 1;
80102693:	c7 05 f8 70 11 80 01 	movl   $0x1,0x801170f8
8010269a:	00 00 00 
      break;
8010269d:	eb 0d                	jmp    801026ac <ideinit+0x89>
  for(i=0; i<1000; i++){
8010269f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026a3:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026aa:	7e d3                	jle    8010267f <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026ac:	83 ec 08             	sub    $0x8,%esp
801026af:	68 e0 00 00 00       	push   $0xe0
801026b4:	68 f6 01 00 00       	push   $0x1f6
801026b9:	e8 d9 fe ff ff       	call   80102597 <outb>
801026be:	83 c4 10             	add    $0x10,%esp
}
801026c1:	90                   	nop
801026c2:	c9                   	leave  
801026c3:	c3                   	ret    

801026c4 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026c4:	55                   	push   %ebp
801026c5:	89 e5                	mov    %esp,%ebp
801026c7:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026ca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026ce:	75 0d                	jne    801026dd <idestart+0x19>
    panic("idestart");
801026d0:	83 ec 0c             	sub    $0xc,%esp
801026d3:	68 57 a5 10 80       	push   $0x8010a557
801026d8:	e8 cc de ff ff       	call   801005a9 <panic>
  if(b->blockno >= FSSIZE)
801026dd:	8b 45 08             	mov    0x8(%ebp),%eax
801026e0:	8b 40 08             	mov    0x8(%eax),%eax
801026e3:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026e8:	76 0d                	jbe    801026f7 <idestart+0x33>
    panic("incorrect blockno");
801026ea:	83 ec 0c             	sub    $0xc,%esp
801026ed:	68 60 a5 10 80       	push   $0x8010a560
801026f2:	e8 b2 de ff ff       	call   801005a9 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801026f7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801026fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102701:	8b 50 08             	mov    0x8(%eax),%edx
80102704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102707:	0f af c2             	imul   %edx,%eax
8010270a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010270d:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102711:	75 07                	jne    8010271a <idestart+0x56>
80102713:	b8 20 00 00 00       	mov    $0x20,%eax
80102718:	eb 05                	jmp    8010271f <idestart+0x5b>
8010271a:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010271f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102722:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102726:	75 07                	jne    8010272f <idestart+0x6b>
80102728:	b8 30 00 00 00       	mov    $0x30,%eax
8010272d:	eb 05                	jmp    80102734 <idestart+0x70>
8010272f:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102734:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102737:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010273b:	7e 0d                	jle    8010274a <idestart+0x86>
8010273d:	83 ec 0c             	sub    $0xc,%esp
80102740:	68 57 a5 10 80       	push   $0x8010a557
80102745:	e8 5f de ff ff       	call   801005a9 <panic>

  idewait(0);
8010274a:	83 ec 0c             	sub    $0xc,%esp
8010274d:	6a 00                	push   $0x0
8010274f:	e8 8a fe ff ff       	call   801025de <idewait>
80102754:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102757:	83 ec 08             	sub    $0x8,%esp
8010275a:	6a 00                	push   $0x0
8010275c:	68 f6 03 00 00       	push   $0x3f6
80102761:	e8 31 fe ff ff       	call   80102597 <outb>
80102766:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276c:	0f b6 c0             	movzbl %al,%eax
8010276f:	83 ec 08             	sub    $0x8,%esp
80102772:	50                   	push   %eax
80102773:	68 f2 01 00 00       	push   $0x1f2
80102778:	e8 1a fe ff ff       	call   80102597 <outb>
8010277d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102780:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102783:	0f b6 c0             	movzbl %al,%eax
80102786:	83 ec 08             	sub    $0x8,%esp
80102789:	50                   	push   %eax
8010278a:	68 f3 01 00 00       	push   $0x1f3
8010278f:	e8 03 fe ff ff       	call   80102597 <outb>
80102794:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102797:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010279a:	c1 f8 08             	sar    $0x8,%eax
8010279d:	0f b6 c0             	movzbl %al,%eax
801027a0:	83 ec 08             	sub    $0x8,%esp
801027a3:	50                   	push   %eax
801027a4:	68 f4 01 00 00       	push   $0x1f4
801027a9:	e8 e9 fd ff ff       	call   80102597 <outb>
801027ae:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b4:	c1 f8 10             	sar    $0x10,%eax
801027b7:	0f b6 c0             	movzbl %al,%eax
801027ba:	83 ec 08             	sub    $0x8,%esp
801027bd:	50                   	push   %eax
801027be:	68 f5 01 00 00       	push   $0x1f5
801027c3:	e8 cf fd ff ff       	call   80102597 <outb>
801027c8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027cb:	8b 45 08             	mov    0x8(%ebp),%eax
801027ce:	8b 40 04             	mov    0x4(%eax),%eax
801027d1:	c1 e0 04             	shl    $0x4,%eax
801027d4:	83 e0 10             	and    $0x10,%eax
801027d7:	89 c2                	mov    %eax,%edx
801027d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027dc:	c1 f8 18             	sar    $0x18,%eax
801027df:	83 e0 0f             	and    $0xf,%eax
801027e2:	09 d0                	or     %edx,%eax
801027e4:	83 c8 e0             	or     $0xffffffe0,%eax
801027e7:	0f b6 c0             	movzbl %al,%eax
801027ea:	83 ec 08             	sub    $0x8,%esp
801027ed:	50                   	push   %eax
801027ee:	68 f6 01 00 00       	push   $0x1f6
801027f3:	e8 9f fd ff ff       	call   80102597 <outb>
801027f8:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	8b 00                	mov    (%eax),%eax
80102800:	83 e0 04             	and    $0x4,%eax
80102803:	85 c0                	test   %eax,%eax
80102805:	74 35                	je     8010283c <idestart+0x178>
    outb(0x1f7, write_cmd);
80102807:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010280a:	0f b6 c0             	movzbl %al,%eax
8010280d:	83 ec 08             	sub    $0x8,%esp
80102810:	50                   	push   %eax
80102811:	68 f7 01 00 00       	push   $0x1f7
80102816:	e8 7c fd ff ff       	call   80102597 <outb>
8010281b:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010281e:	8b 45 08             	mov    0x8(%ebp),%eax
80102821:	83 c0 5c             	add    $0x5c,%eax
80102824:	83 ec 04             	sub    $0x4,%esp
80102827:	68 80 00 00 00       	push   $0x80
8010282c:	50                   	push   %eax
8010282d:	68 f0 01 00 00       	push   $0x1f0
80102832:	e8 81 fd ff ff       	call   801025b8 <outsl>
80102837:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010283a:	eb 17                	jmp    80102853 <idestart+0x18f>
    outb(0x1f7, read_cmd);
8010283c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010283f:	0f b6 c0             	movzbl %al,%eax
80102842:	83 ec 08             	sub    $0x8,%esp
80102845:	50                   	push   %eax
80102846:	68 f7 01 00 00       	push   $0x1f7
8010284b:	e8 47 fd ff ff       	call   80102597 <outb>
80102850:	83 c4 10             	add    $0x10,%esp
}
80102853:	90                   	nop
80102854:	c9                   	leave  
80102855:	c3                   	ret    

80102856 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102856:	55                   	push   %ebp
80102857:	89 e5                	mov    %esp,%ebp
80102859:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010285c:	83 ec 0c             	sub    $0xc,%esp
8010285f:	68 c0 70 11 80       	push   $0x801170c0
80102864:	e8 6f 23 00 00       	call   80104bd8 <acquire>
80102869:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010286c:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102871:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102874:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102878:	75 15                	jne    8010288f <ideintr+0x39>
    release(&idelock);
8010287a:	83 ec 0c             	sub    $0xc,%esp
8010287d:	68 c0 70 11 80       	push   $0x801170c0
80102882:	e8 bf 23 00 00       	call   80104c46 <release>
80102887:	83 c4 10             	add    $0x10,%esp
    return;
8010288a:	e9 9a 00 00 00       	jmp    80102929 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010288f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102892:	8b 40 58             	mov    0x58(%eax),%eax
80102895:	a3 f4 70 11 80       	mov    %eax,0x801170f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010289a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289d:	8b 00                	mov    (%eax),%eax
8010289f:	83 e0 04             	and    $0x4,%eax
801028a2:	85 c0                	test   %eax,%eax
801028a4:	75 2d                	jne    801028d3 <ideintr+0x7d>
801028a6:	83 ec 0c             	sub    $0xc,%esp
801028a9:	6a 01                	push   $0x1
801028ab:	e8 2e fd ff ff       	call   801025de <idewait>
801028b0:	83 c4 10             	add    $0x10,%esp
801028b3:	85 c0                	test   %eax,%eax
801028b5:	78 1c                	js     801028d3 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ba:	83 c0 5c             	add    $0x5c,%eax
801028bd:	83 ec 04             	sub    $0x4,%esp
801028c0:	68 80 00 00 00       	push   $0x80
801028c5:	50                   	push   %eax
801028c6:	68 f0 01 00 00       	push   $0x1f0
801028cb:	e8 a1 fc ff ff       	call   80102571 <insl>
801028d0:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d6:	8b 00                	mov    (%eax),%eax
801028d8:	83 c8 02             	or     $0x2,%eax
801028db:	89 c2                	mov    %eax,%edx
801028dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e0:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e5:	8b 00                	mov    (%eax),%eax
801028e7:	83 e0 fb             	and    $0xfffffffb,%eax
801028ea:	89 c2                	mov    %eax,%edx
801028ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ef:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028f1:	83 ec 0c             	sub    $0xc,%esp
801028f4:	ff 75 f4             	push   -0xc(%ebp)
801028f7:	e8 a8 1f 00 00       	call   801048a4 <wakeup>
801028fc:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
801028ff:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102904:	85 c0                	test   %eax,%eax
80102906:	74 11                	je     80102919 <ideintr+0xc3>
    idestart(idequeue);
80102908:	a1 f4 70 11 80       	mov    0x801170f4,%eax
8010290d:	83 ec 0c             	sub    $0xc,%esp
80102910:	50                   	push   %eax
80102911:	e8 ae fd ff ff       	call   801026c4 <idestart>
80102916:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102919:	83 ec 0c             	sub    $0xc,%esp
8010291c:	68 c0 70 11 80       	push   $0x801170c0
80102921:	e8 20 23 00 00       	call   80104c46 <release>
80102926:	83 c4 10             	add    $0x10,%esp
}
80102929:	c9                   	leave  
8010292a:	c3                   	ret    

8010292b <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010292b:	55                   	push   %ebp
8010292c:	89 e5                	mov    %esp,%ebp
8010292e:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;
#if IDE_DEBUG
  cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
80102931:	8b 15 f8 70 11 80    	mov    0x801170f8,%edx
80102937:	8b 45 08             	mov    0x8(%ebp),%eax
8010293a:	8b 40 04             	mov    0x4(%eax),%eax
8010293d:	83 ec 04             	sub    $0x4,%esp
80102940:	52                   	push   %edx
80102941:	50                   	push   %eax
80102942:	68 72 a5 10 80       	push   $0x8010a572
80102947:	e8 a8 da ff ff       	call   801003f4 <cprintf>
8010294c:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
8010294f:	8b 45 08             	mov    0x8(%ebp),%eax
80102952:	83 c0 0c             	add    $0xc,%eax
80102955:	83 ec 0c             	sub    $0xc,%esp
80102958:	50                   	push   %eax
80102959:	e8 e9 21 00 00       	call   80104b47 <holdingsleep>
8010295e:	83 c4 10             	add    $0x10,%esp
80102961:	85 c0                	test   %eax,%eax
80102963:	75 0d                	jne    80102972 <iderw+0x47>
    panic("iderw: buf not locked");
80102965:	83 ec 0c             	sub    $0xc,%esp
80102968:	68 8c a5 10 80       	push   $0x8010a58c
8010296d:	e8 37 dc ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102972:	8b 45 08             	mov    0x8(%ebp),%eax
80102975:	8b 00                	mov    (%eax),%eax
80102977:	83 e0 06             	and    $0x6,%eax
8010297a:	83 f8 02             	cmp    $0x2,%eax
8010297d:	75 0d                	jne    8010298c <iderw+0x61>
    panic("iderw: nothing to do");
8010297f:	83 ec 0c             	sub    $0xc,%esp
80102982:	68 a2 a5 10 80       	push   $0x8010a5a2
80102987:	e8 1d dc ff ff       	call   801005a9 <panic>
  if(b->dev != 0 && !havedisk1)
8010298c:	8b 45 08             	mov    0x8(%ebp),%eax
8010298f:	8b 40 04             	mov    0x4(%eax),%eax
80102992:	85 c0                	test   %eax,%eax
80102994:	74 16                	je     801029ac <iderw+0x81>
80102996:	a1 f8 70 11 80       	mov    0x801170f8,%eax
8010299b:	85 c0                	test   %eax,%eax
8010299d:	75 0d                	jne    801029ac <iderw+0x81>
    panic("iderw: ide disk 1 not present");
8010299f:	83 ec 0c             	sub    $0xc,%esp
801029a2:	68 b7 a5 10 80       	push   $0x8010a5b7
801029a7:	e8 fd db ff ff       	call   801005a9 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029ac:	83 ec 0c             	sub    $0xc,%esp
801029af:	68 c0 70 11 80       	push   $0x801170c0
801029b4:	e8 1f 22 00 00       	call   80104bd8 <acquire>
801029b9:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029bc:	8b 45 08             	mov    0x8(%ebp),%eax
801029bf:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029c6:	c7 45 f4 f4 70 11 80 	movl   $0x801170f4,-0xc(%ebp)
801029cd:	eb 0b                	jmp    801029da <iderw+0xaf>
801029cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d2:	8b 00                	mov    (%eax),%eax
801029d4:	83 c0 58             	add    $0x58,%eax
801029d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029dd:	8b 00                	mov    (%eax),%eax
801029df:	85 c0                	test   %eax,%eax
801029e1:	75 ec                	jne    801029cf <iderw+0xa4>
    ;
  *pp = b;
801029e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e6:	8b 55 08             	mov    0x8(%ebp),%edx
801029e9:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029eb:	a1 f4 70 11 80       	mov    0x801170f4,%eax
801029f0:	39 45 08             	cmp    %eax,0x8(%ebp)
801029f3:	75 23                	jne    80102a18 <iderw+0xed>
    idestart(b);
801029f5:	83 ec 0c             	sub    $0xc,%esp
801029f8:	ff 75 08             	push   0x8(%ebp)
801029fb:	e8 c4 fc ff ff       	call   801026c4 <idestart>
80102a00:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a03:	eb 13                	jmp    80102a18 <iderw+0xed>
    sleep(b, &idelock);
80102a05:	83 ec 08             	sub    $0x8,%esp
80102a08:	68 c0 70 11 80       	push   $0x801170c0
80102a0d:	ff 75 08             	push   0x8(%ebp)
80102a10:	e8 a8 1d 00 00       	call   801047bd <sleep>
80102a15:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a18:	8b 45 08             	mov    0x8(%ebp),%eax
80102a1b:	8b 00                	mov    (%eax),%eax
80102a1d:	83 e0 06             	and    $0x6,%eax
80102a20:	83 f8 02             	cmp    $0x2,%eax
80102a23:	75 e0                	jne    80102a05 <iderw+0xda>
  }


  release(&idelock);
80102a25:	83 ec 0c             	sub    $0xc,%esp
80102a28:	68 c0 70 11 80       	push   $0x801170c0
80102a2d:	e8 14 22 00 00       	call   80104c46 <release>
80102a32:	83 c4 10             	add    $0x10,%esp
}
80102a35:	90                   	nop
80102a36:	c9                   	leave  
80102a37:	c3                   	ret    

80102a38 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a38:	55                   	push   %ebp
80102a39:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a3b:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a40:	8b 55 08             	mov    0x8(%ebp),%edx
80102a43:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a45:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a4a:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a4d:	5d                   	pop    %ebp
80102a4e:	c3                   	ret    

80102a4f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a4f:	55                   	push   %ebp
80102a50:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a52:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a57:	8b 55 08             	mov    0x8(%ebp),%edx
80102a5a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a5c:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a61:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a64:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a67:	90                   	nop
80102a68:	5d                   	pop    %ebp
80102a69:	c3                   	ret    

80102a6a <ioapicinit>:

void
ioapicinit(void)
{
80102a6a:	55                   	push   %ebp
80102a6b:	89 e5                	mov    %esp,%ebp
80102a6d:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a70:	c7 05 fc 70 11 80 00 	movl   $0xfec00000,0x801170fc
80102a77:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a7a:	6a 01                	push   $0x1
80102a7c:	e8 b7 ff ff ff       	call   80102a38 <ioapicread>
80102a81:	83 c4 04             	add    $0x4,%esp
80102a84:	c1 e8 10             	shr    $0x10,%eax
80102a87:	25 ff 00 00 00       	and    $0xff,%eax
80102a8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a8f:	6a 00                	push   $0x0
80102a91:	e8 a2 ff ff ff       	call   80102a38 <ioapicread>
80102a96:	83 c4 04             	add    $0x4,%esp
80102a99:	c1 e8 18             	shr    $0x18,%eax
80102a9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a9f:	0f b6 05 84 9d 11 80 	movzbl 0x80119d84,%eax
80102aa6:	0f b6 c0             	movzbl %al,%eax
80102aa9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102aac:	74 10                	je     80102abe <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102aae:	83 ec 0c             	sub    $0xc,%esp
80102ab1:	68 d8 a5 10 80       	push   $0x8010a5d8
80102ab6:	e8 39 d9 ff ff       	call   801003f4 <cprintf>
80102abb:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102abe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ac5:	eb 3f                	jmp    80102b06 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aca:	83 c0 20             	add    $0x20,%eax
80102acd:	0d 00 00 01 00       	or     $0x10000,%eax
80102ad2:	89 c2                	mov    %eax,%edx
80102ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad7:	83 c0 08             	add    $0x8,%eax
80102ada:	01 c0                	add    %eax,%eax
80102adc:	83 ec 08             	sub    $0x8,%esp
80102adf:	52                   	push   %edx
80102ae0:	50                   	push   %eax
80102ae1:	e8 69 ff ff ff       	call   80102a4f <ioapicwrite>
80102ae6:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aec:	83 c0 08             	add    $0x8,%eax
80102aef:	01 c0                	add    %eax,%eax
80102af1:	83 c0 01             	add    $0x1,%eax
80102af4:	83 ec 08             	sub    $0x8,%esp
80102af7:	6a 00                	push   $0x0
80102af9:	50                   	push   %eax
80102afa:	e8 50 ff ff ff       	call   80102a4f <ioapicwrite>
80102aff:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102b02:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b09:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b0c:	7e b9                	jle    80102ac7 <ioapicinit+0x5d>
  }
}
80102b0e:	90                   	nop
80102b0f:	90                   	nop
80102b10:	c9                   	leave  
80102b11:	c3                   	ret    

80102b12 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b12:	55                   	push   %ebp
80102b13:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b15:	8b 45 08             	mov    0x8(%ebp),%eax
80102b18:	83 c0 20             	add    $0x20,%eax
80102b1b:	89 c2                	mov    %eax,%edx
80102b1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b20:	83 c0 08             	add    $0x8,%eax
80102b23:	01 c0                	add    %eax,%eax
80102b25:	52                   	push   %edx
80102b26:	50                   	push   %eax
80102b27:	e8 23 ff ff ff       	call   80102a4f <ioapicwrite>
80102b2c:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b32:	c1 e0 18             	shl    $0x18,%eax
80102b35:	89 c2                	mov    %eax,%edx
80102b37:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3a:	83 c0 08             	add    $0x8,%eax
80102b3d:	01 c0                	add    %eax,%eax
80102b3f:	83 c0 01             	add    $0x1,%eax
80102b42:	52                   	push   %edx
80102b43:	50                   	push   %eax
80102b44:	e8 06 ff ff ff       	call   80102a4f <ioapicwrite>
80102b49:	83 c4 08             	add    $0x8,%esp
}
80102b4c:	90                   	nop
80102b4d:	c9                   	leave  
80102b4e:	c3                   	ret    

80102b4f <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b4f:	55                   	push   %ebp
80102b50:	89 e5                	mov    %esp,%ebp
80102b52:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b55:	83 ec 08             	sub    $0x8,%esp
80102b58:	68 0a a6 10 80       	push   $0x8010a60a
80102b5d:	68 00 71 11 80       	push   $0x80117100
80102b62:	e8 4f 20 00 00       	call   80104bb6 <initlock>
80102b67:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b6a:	c7 05 34 71 11 80 00 	movl   $0x0,0x80117134
80102b71:	00 00 00 
  freerange(vstart, vend);
80102b74:	83 ec 08             	sub    $0x8,%esp
80102b77:	ff 75 0c             	push   0xc(%ebp)
80102b7a:	ff 75 08             	push   0x8(%ebp)
80102b7d:	e8 2a 00 00 00       	call   80102bac <freerange>
80102b82:	83 c4 10             	add    $0x10,%esp
}
80102b85:	90                   	nop
80102b86:	c9                   	leave  
80102b87:	c3                   	ret    

80102b88 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b88:	55                   	push   %ebp
80102b89:	89 e5                	mov    %esp,%ebp
80102b8b:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b8e:	83 ec 08             	sub    $0x8,%esp
80102b91:	ff 75 0c             	push   0xc(%ebp)
80102b94:	ff 75 08             	push   0x8(%ebp)
80102b97:	e8 10 00 00 00       	call   80102bac <freerange>
80102b9c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b9f:	c7 05 34 71 11 80 01 	movl   $0x1,0x80117134
80102ba6:	00 00 00 
}
80102ba9:	90                   	nop
80102baa:	c9                   	leave  
80102bab:	c3                   	ret    

80102bac <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bac:	55                   	push   %ebp
80102bad:	89 e5                	mov    %esp,%ebp
80102baf:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb5:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc2:	eb 15                	jmp    80102bd9 <freerange+0x2d>
    kfree(p);
80102bc4:	83 ec 0c             	sub    $0xc,%esp
80102bc7:	ff 75 f4             	push   -0xc(%ebp)
80102bca:	e8 1b 00 00 00       	call   80102bea <kfree>
80102bcf:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bd2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bdc:	05 00 10 00 00       	add    $0x1000,%eax
80102be1:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102be4:	73 de                	jae    80102bc4 <freerange+0x18>
}
80102be6:	90                   	nop
80102be7:	90                   	nop
80102be8:	c9                   	leave  
80102be9:	c3                   	ret    

80102bea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bea:	55                   	push   %ebp
80102beb:	89 e5                	mov    %esp,%ebp
80102bed:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf3:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bf8:	85 c0                	test   %eax,%eax
80102bfa:	75 18                	jne    80102c14 <kfree+0x2a>
80102bfc:	81 7d 08 00 c0 11 80 	cmpl   $0x8011c000,0x8(%ebp)
80102c03:	72 0f                	jb     80102c14 <kfree+0x2a>
80102c05:	8b 45 08             	mov    0x8(%ebp),%eax
80102c08:	05 00 00 00 80       	add    $0x80000000,%eax
80102c0d:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102c12:	76 0d                	jbe    80102c21 <kfree+0x37>
    panic("kfree");
80102c14:	83 ec 0c             	sub    $0xc,%esp
80102c17:	68 0f a6 10 80       	push   $0x8010a60f
80102c1c:	e8 88 d9 ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c21:	83 ec 04             	sub    $0x4,%esp
80102c24:	68 00 10 00 00       	push   $0x1000
80102c29:	6a 01                	push   $0x1
80102c2b:	ff 75 08             	push   0x8(%ebp)
80102c2e:	e8 1b 22 00 00       	call   80104e4e <memset>
80102c33:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c36:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c3b:	85 c0                	test   %eax,%eax
80102c3d:	74 10                	je     80102c4f <kfree+0x65>
    acquire(&kmem.lock);
80102c3f:	83 ec 0c             	sub    $0xc,%esp
80102c42:	68 00 71 11 80       	push   $0x80117100
80102c47:	e8 8c 1f 00 00       	call   80104bd8 <acquire>
80102c4c:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c55:	8b 15 38 71 11 80    	mov    0x80117138,%edx
80102c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c5e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c63:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102c68:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c6d:	85 c0                	test   %eax,%eax
80102c6f:	74 10                	je     80102c81 <kfree+0x97>
    release(&kmem.lock);
80102c71:	83 ec 0c             	sub    $0xc,%esp
80102c74:	68 00 71 11 80       	push   $0x80117100
80102c79:	e8 c8 1f 00 00       	call   80104c46 <release>
80102c7e:	83 c4 10             	add    $0x10,%esp
}
80102c81:	90                   	nop
80102c82:	c9                   	leave  
80102c83:	c3                   	ret    

80102c84 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c84:	55                   	push   %ebp
80102c85:	89 e5                	mov    %esp,%ebp
80102c87:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c8a:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c8f:	85 c0                	test   %eax,%eax
80102c91:	74 10                	je     80102ca3 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c93:	83 ec 0c             	sub    $0xc,%esp
80102c96:	68 00 71 11 80       	push   $0x80117100
80102c9b:	e8 38 1f 00 00       	call   80104bd8 <acquire>
80102ca0:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102ca3:	a1 38 71 11 80       	mov    0x80117138,%eax
80102ca8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102caf:	74 0a                	je     80102cbb <kalloc+0x37>
    kmem.freelist = r->next;
80102cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb4:	8b 00                	mov    (%eax),%eax
80102cb6:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102cbb:	a1 34 71 11 80       	mov    0x80117134,%eax
80102cc0:	85 c0                	test   %eax,%eax
80102cc2:	74 10                	je     80102cd4 <kalloc+0x50>
    release(&kmem.lock);
80102cc4:	83 ec 0c             	sub    $0xc,%esp
80102cc7:	68 00 71 11 80       	push   $0x80117100
80102ccc:	e8 75 1f 00 00       	call   80104c46 <release>
80102cd1:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cd7:	c9                   	leave  
80102cd8:	c3                   	ret    

80102cd9 <inb>:
{
80102cd9:	55                   	push   %ebp
80102cda:	89 e5                	mov    %esp,%ebp
80102cdc:	83 ec 14             	sub    $0x14,%esp
80102cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ce6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cea:	89 c2                	mov    %eax,%edx
80102cec:	ec                   	in     (%dx),%al
80102ced:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cf0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cf4:	c9                   	leave  
80102cf5:	c3                   	ret    

80102cf6 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cf6:	55                   	push   %ebp
80102cf7:	89 e5                	mov    %esp,%ebp
80102cf9:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cfc:	6a 64                	push   $0x64
80102cfe:	e8 d6 ff ff ff       	call   80102cd9 <inb>
80102d03:	83 c4 04             	add    $0x4,%esp
80102d06:	0f b6 c0             	movzbl %al,%eax
80102d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d0f:	83 e0 01             	and    $0x1,%eax
80102d12:	85 c0                	test   %eax,%eax
80102d14:	75 0a                	jne    80102d20 <kbdgetc+0x2a>
    return -1;
80102d16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d1b:	e9 23 01 00 00       	jmp    80102e43 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d20:	6a 60                	push   $0x60
80102d22:	e8 b2 ff ff ff       	call   80102cd9 <inb>
80102d27:	83 c4 04             	add    $0x4,%esp
80102d2a:	0f b6 c0             	movzbl %al,%eax
80102d2d:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d30:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d37:	75 17                	jne    80102d50 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d39:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d3e:	83 c8 40             	or     $0x40,%eax
80102d41:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d46:	b8 00 00 00 00       	mov    $0x0,%eax
80102d4b:	e9 f3 00 00 00       	jmp    80102e43 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d53:	25 80 00 00 00       	and    $0x80,%eax
80102d58:	85 c0                	test   %eax,%eax
80102d5a:	74 45                	je     80102da1 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d5c:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d61:	83 e0 40             	and    $0x40,%eax
80102d64:	85 c0                	test   %eax,%eax
80102d66:	75 08                	jne    80102d70 <kbdgetc+0x7a>
80102d68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d6b:	83 e0 7f             	and    $0x7f,%eax
80102d6e:	eb 03                	jmp    80102d73 <kbdgetc+0x7d>
80102d70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d73:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d79:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102d7e:	0f b6 00             	movzbl (%eax),%eax
80102d81:	83 c8 40             	or     $0x40,%eax
80102d84:	0f b6 c0             	movzbl %al,%eax
80102d87:	f7 d0                	not    %eax
80102d89:	89 c2                	mov    %eax,%edx
80102d8b:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d90:	21 d0                	and    %edx,%eax
80102d92:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d97:	b8 00 00 00 00       	mov    $0x0,%eax
80102d9c:	e9 a2 00 00 00       	jmp    80102e43 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102da1:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102da6:	83 e0 40             	and    $0x40,%eax
80102da9:	85 c0                	test   %eax,%eax
80102dab:	74 14                	je     80102dc1 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dad:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102db4:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102db9:	83 e0 bf             	and    $0xffffffbf,%eax
80102dbc:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  }

  shift |= shiftcode[data];
80102dc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc4:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102dc9:	0f b6 00             	movzbl (%eax),%eax
80102dcc:	0f b6 d0             	movzbl %al,%edx
80102dcf:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dd4:	09 d0                	or     %edx,%eax
80102dd6:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  shift ^= togglecode[data];
80102ddb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dde:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102de3:	0f b6 00             	movzbl (%eax),%eax
80102de6:	0f b6 d0             	movzbl %al,%edx
80102de9:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dee:	31 d0                	xor    %edx,%eax
80102df0:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  c = charcode[shift & (CTL | SHIFT)][data];
80102df5:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dfa:	83 e0 03             	and    $0x3,%eax
80102dfd:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102e04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e07:	01 d0                	add    %edx,%eax
80102e09:	0f b6 00             	movzbl (%eax),%eax
80102e0c:	0f b6 c0             	movzbl %al,%eax
80102e0f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e12:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102e17:	83 e0 08             	and    $0x8,%eax
80102e1a:	85 c0                	test   %eax,%eax
80102e1c:	74 22                	je     80102e40 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e1e:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e22:	76 0c                	jbe    80102e30 <kbdgetc+0x13a>
80102e24:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e28:	77 06                	ja     80102e30 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e2a:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e2e:	eb 10                	jmp    80102e40 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e30:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e34:	76 0a                	jbe    80102e40 <kbdgetc+0x14a>
80102e36:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e3a:	77 04                	ja     80102e40 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e3c:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e40:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e43:	c9                   	leave  
80102e44:	c3                   	ret    

80102e45 <kbdintr>:

void
kbdintr(void)
{
80102e45:	55                   	push   %ebp
80102e46:	89 e5                	mov    %esp,%ebp
80102e48:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e4b:	83 ec 0c             	sub    $0xc,%esp
80102e4e:	68 f6 2c 10 80       	push   $0x80102cf6
80102e53:	e8 7e d9 ff ff       	call   801007d6 <consoleintr>
80102e58:	83 c4 10             	add    $0x10,%esp
}
80102e5b:	90                   	nop
80102e5c:	c9                   	leave  
80102e5d:	c3                   	ret    

80102e5e <inb>:
{
80102e5e:	55                   	push   %ebp
80102e5f:	89 e5                	mov    %esp,%ebp
80102e61:	83 ec 14             	sub    $0x14,%esp
80102e64:	8b 45 08             	mov    0x8(%ebp),%eax
80102e67:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e6b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e6f:	89 c2                	mov    %eax,%edx
80102e71:	ec                   	in     (%dx),%al
80102e72:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e75:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e79:	c9                   	leave  
80102e7a:	c3                   	ret    

80102e7b <outb>:
{
80102e7b:	55                   	push   %ebp
80102e7c:	89 e5                	mov    %esp,%ebp
80102e7e:	83 ec 08             	sub    $0x8,%esp
80102e81:	8b 45 08             	mov    0x8(%ebp),%eax
80102e84:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e87:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e8b:	89 d0                	mov    %edx,%eax
80102e8d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e90:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e94:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e98:	ee                   	out    %al,(%dx)
}
80102e99:	90                   	nop
80102e9a:	c9                   	leave  
80102e9b:	c3                   	ret    

80102e9c <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102e9c:	55                   	push   %ebp
80102e9d:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e9f:	8b 15 40 71 11 80    	mov    0x80117140,%edx
80102ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ea8:	c1 e0 02             	shl    $0x2,%eax
80102eab:	01 c2                	add    %eax,%edx
80102ead:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eb0:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102eb2:	a1 40 71 11 80       	mov    0x80117140,%eax
80102eb7:	83 c0 20             	add    $0x20,%eax
80102eba:	8b 00                	mov    (%eax),%eax
}
80102ebc:	90                   	nop
80102ebd:	5d                   	pop    %ebp
80102ebe:	c3                   	ret    

80102ebf <lapicinit>:

void
lapicinit(void)
{
80102ebf:	55                   	push   %ebp
80102ec0:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ec2:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ec7:	85 c0                	test   %eax,%eax
80102ec9:	0f 84 0c 01 00 00    	je     80102fdb <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ecf:	68 3f 01 00 00       	push   $0x13f
80102ed4:	6a 3c                	push   $0x3c
80102ed6:	e8 c1 ff ff ff       	call   80102e9c <lapicw>
80102edb:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ede:	6a 0b                	push   $0xb
80102ee0:	68 f8 00 00 00       	push   $0xf8
80102ee5:	e8 b2 ff ff ff       	call   80102e9c <lapicw>
80102eea:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102eed:	68 20 00 02 00       	push   $0x20020
80102ef2:	68 c8 00 00 00       	push   $0xc8
80102ef7:	e8 a0 ff ff ff       	call   80102e9c <lapicw>
80102efc:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102eff:	68 80 96 98 00       	push   $0x989680
80102f04:	68 e0 00 00 00       	push   $0xe0
80102f09:	e8 8e ff ff ff       	call   80102e9c <lapicw>
80102f0e:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f11:	68 00 00 01 00       	push   $0x10000
80102f16:	68 d4 00 00 00       	push   $0xd4
80102f1b:	e8 7c ff ff ff       	call   80102e9c <lapicw>
80102f20:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f23:	68 00 00 01 00       	push   $0x10000
80102f28:	68 d8 00 00 00       	push   $0xd8
80102f2d:	e8 6a ff ff ff       	call   80102e9c <lapicw>
80102f32:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f35:	a1 40 71 11 80       	mov    0x80117140,%eax
80102f3a:	83 c0 30             	add    $0x30,%eax
80102f3d:	8b 00                	mov    (%eax),%eax
80102f3f:	c1 e8 10             	shr    $0x10,%eax
80102f42:	25 fc 00 00 00       	and    $0xfc,%eax
80102f47:	85 c0                	test   %eax,%eax
80102f49:	74 12                	je     80102f5d <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f4b:	68 00 00 01 00       	push   $0x10000
80102f50:	68 d0 00 00 00       	push   $0xd0
80102f55:	e8 42 ff ff ff       	call   80102e9c <lapicw>
80102f5a:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f5d:	6a 33                	push   $0x33
80102f5f:	68 dc 00 00 00       	push   $0xdc
80102f64:	e8 33 ff ff ff       	call   80102e9c <lapicw>
80102f69:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f6c:	6a 00                	push   $0x0
80102f6e:	68 a0 00 00 00       	push   $0xa0
80102f73:	e8 24 ff ff ff       	call   80102e9c <lapicw>
80102f78:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f7b:	6a 00                	push   $0x0
80102f7d:	68 a0 00 00 00       	push   $0xa0
80102f82:	e8 15 ff ff ff       	call   80102e9c <lapicw>
80102f87:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f8a:	6a 00                	push   $0x0
80102f8c:	6a 2c                	push   $0x2c
80102f8e:	e8 09 ff ff ff       	call   80102e9c <lapicw>
80102f93:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f96:	6a 00                	push   $0x0
80102f98:	68 c4 00 00 00       	push   $0xc4
80102f9d:	e8 fa fe ff ff       	call   80102e9c <lapicw>
80102fa2:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fa5:	68 00 85 08 00       	push   $0x88500
80102faa:	68 c0 00 00 00       	push   $0xc0
80102faf:	e8 e8 fe ff ff       	call   80102e9c <lapicw>
80102fb4:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fb7:	90                   	nop
80102fb8:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fbd:	05 00 03 00 00       	add    $0x300,%eax
80102fc2:	8b 00                	mov    (%eax),%eax
80102fc4:	25 00 10 00 00       	and    $0x1000,%eax
80102fc9:	85 c0                	test   %eax,%eax
80102fcb:	75 eb                	jne    80102fb8 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fcd:	6a 00                	push   $0x0
80102fcf:	6a 20                	push   $0x20
80102fd1:	e8 c6 fe ff ff       	call   80102e9c <lapicw>
80102fd6:	83 c4 08             	add    $0x8,%esp
80102fd9:	eb 01                	jmp    80102fdc <lapicinit+0x11d>
    return;
80102fdb:	90                   	nop
}
80102fdc:	c9                   	leave  
80102fdd:	c3                   	ret    

80102fde <lapicid>:

int
lapicid(void)
{
80102fde:	55                   	push   %ebp
80102fdf:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102fe1:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fe6:	85 c0                	test   %eax,%eax
80102fe8:	75 07                	jne    80102ff1 <lapicid+0x13>
    return 0;
80102fea:	b8 00 00 00 00       	mov    $0x0,%eax
80102fef:	eb 0d                	jmp    80102ffe <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102ff1:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ff6:	83 c0 20             	add    $0x20,%eax
80102ff9:	8b 00                	mov    (%eax),%eax
80102ffb:	c1 e8 18             	shr    $0x18,%eax
}
80102ffe:	5d                   	pop    %ebp
80102fff:	c3                   	ret    

80103000 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103000:	55                   	push   %ebp
80103001:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103003:	a1 40 71 11 80       	mov    0x80117140,%eax
80103008:	85 c0                	test   %eax,%eax
8010300a:	74 0c                	je     80103018 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010300c:	6a 00                	push   $0x0
8010300e:	6a 2c                	push   $0x2c
80103010:	e8 87 fe ff ff       	call   80102e9c <lapicw>
80103015:	83 c4 08             	add    $0x8,%esp
}
80103018:	90                   	nop
80103019:	c9                   	leave  
8010301a:	c3                   	ret    

8010301b <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010301b:	55                   	push   %ebp
8010301c:	89 e5                	mov    %esp,%ebp
}
8010301e:	90                   	nop
8010301f:	5d                   	pop    %ebp
80103020:	c3                   	ret    

80103021 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103021:	55                   	push   %ebp
80103022:	89 e5                	mov    %esp,%ebp
80103024:	83 ec 14             	sub    $0x14,%esp
80103027:	8b 45 08             	mov    0x8(%ebp),%eax
8010302a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010302d:	6a 0f                	push   $0xf
8010302f:	6a 70                	push   $0x70
80103031:	e8 45 fe ff ff       	call   80102e7b <outb>
80103036:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103039:	6a 0a                	push   $0xa
8010303b:	6a 71                	push   $0x71
8010303d:	e8 39 fe ff ff       	call   80102e7b <outb>
80103042:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103045:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010304c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010304f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103054:	8b 45 0c             	mov    0xc(%ebp),%eax
80103057:	c1 e8 04             	shr    $0x4,%eax
8010305a:	89 c2                	mov    %eax,%edx
8010305c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010305f:	83 c0 02             	add    $0x2,%eax
80103062:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103065:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103069:	c1 e0 18             	shl    $0x18,%eax
8010306c:	50                   	push   %eax
8010306d:	68 c4 00 00 00       	push   $0xc4
80103072:	e8 25 fe ff ff       	call   80102e9c <lapicw>
80103077:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010307a:	68 00 c5 00 00       	push   $0xc500
8010307f:	68 c0 00 00 00       	push   $0xc0
80103084:	e8 13 fe ff ff       	call   80102e9c <lapicw>
80103089:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010308c:	68 c8 00 00 00       	push   $0xc8
80103091:	e8 85 ff ff ff       	call   8010301b <microdelay>
80103096:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103099:	68 00 85 00 00       	push   $0x8500
8010309e:	68 c0 00 00 00       	push   $0xc0
801030a3:	e8 f4 fd ff ff       	call   80102e9c <lapicw>
801030a8:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030ab:	6a 64                	push   $0x64
801030ad:	e8 69 ff ff ff       	call   8010301b <microdelay>
801030b2:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030bc:	eb 3d                	jmp    801030fb <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030be:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030c2:	c1 e0 18             	shl    $0x18,%eax
801030c5:	50                   	push   %eax
801030c6:	68 c4 00 00 00       	push   $0xc4
801030cb:	e8 cc fd ff ff       	call   80102e9c <lapicw>
801030d0:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801030d6:	c1 e8 0c             	shr    $0xc,%eax
801030d9:	80 cc 06             	or     $0x6,%ah
801030dc:	50                   	push   %eax
801030dd:	68 c0 00 00 00       	push   $0xc0
801030e2:	e8 b5 fd ff ff       	call   80102e9c <lapicw>
801030e7:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030ea:	68 c8 00 00 00       	push   $0xc8
801030ef:	e8 27 ff ff ff       	call   8010301b <microdelay>
801030f4:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801030f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030fb:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030ff:	7e bd                	jle    801030be <lapicstartap+0x9d>
  }
}
80103101:	90                   	nop
80103102:	90                   	nop
80103103:	c9                   	leave  
80103104:	c3                   	ret    

80103105 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103105:	55                   	push   %ebp
80103106:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103108:	8b 45 08             	mov    0x8(%ebp),%eax
8010310b:	0f b6 c0             	movzbl %al,%eax
8010310e:	50                   	push   %eax
8010310f:	6a 70                	push   $0x70
80103111:	e8 65 fd ff ff       	call   80102e7b <outb>
80103116:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103119:	68 c8 00 00 00       	push   $0xc8
8010311e:	e8 f8 fe ff ff       	call   8010301b <microdelay>
80103123:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103126:	6a 71                	push   $0x71
80103128:	e8 31 fd ff ff       	call   80102e5e <inb>
8010312d:	83 c4 04             	add    $0x4,%esp
80103130:	0f b6 c0             	movzbl %al,%eax
}
80103133:	c9                   	leave  
80103134:	c3                   	ret    

80103135 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103135:	55                   	push   %ebp
80103136:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103138:	6a 00                	push   $0x0
8010313a:	e8 c6 ff ff ff       	call   80103105 <cmos_read>
8010313f:	83 c4 04             	add    $0x4,%esp
80103142:	8b 55 08             	mov    0x8(%ebp),%edx
80103145:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103147:	6a 02                	push   $0x2
80103149:	e8 b7 ff ff ff       	call   80103105 <cmos_read>
8010314e:	83 c4 04             	add    $0x4,%esp
80103151:	8b 55 08             	mov    0x8(%ebp),%edx
80103154:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103157:	6a 04                	push   $0x4
80103159:	e8 a7 ff ff ff       	call   80103105 <cmos_read>
8010315e:	83 c4 04             	add    $0x4,%esp
80103161:	8b 55 08             	mov    0x8(%ebp),%edx
80103164:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103167:	6a 07                	push   $0x7
80103169:	e8 97 ff ff ff       	call   80103105 <cmos_read>
8010316e:	83 c4 04             	add    $0x4,%esp
80103171:	8b 55 08             	mov    0x8(%ebp),%edx
80103174:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103177:	6a 08                	push   $0x8
80103179:	e8 87 ff ff ff       	call   80103105 <cmos_read>
8010317e:	83 c4 04             	add    $0x4,%esp
80103181:	8b 55 08             	mov    0x8(%ebp),%edx
80103184:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103187:	6a 09                	push   $0x9
80103189:	e8 77 ff ff ff       	call   80103105 <cmos_read>
8010318e:	83 c4 04             	add    $0x4,%esp
80103191:	8b 55 08             	mov    0x8(%ebp),%edx
80103194:	89 42 14             	mov    %eax,0x14(%edx)
}
80103197:	90                   	nop
80103198:	c9                   	leave  
80103199:	c3                   	ret    

8010319a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010319a:	55                   	push   %ebp
8010319b:	89 e5                	mov    %esp,%ebp
8010319d:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031a0:	6a 0b                	push   $0xb
801031a2:	e8 5e ff ff ff       	call   80103105 <cmos_read>
801031a7:	83 c4 04             	add    $0x4,%esp
801031aa:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b0:	83 e0 04             	and    $0x4,%eax
801031b3:	85 c0                	test   %eax,%eax
801031b5:	0f 94 c0             	sete   %al
801031b8:	0f b6 c0             	movzbl %al,%eax
801031bb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031be:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031c1:	50                   	push   %eax
801031c2:	e8 6e ff ff ff       	call   80103135 <fill_rtcdate>
801031c7:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031ca:	6a 0a                	push   $0xa
801031cc:	e8 34 ff ff ff       	call   80103105 <cmos_read>
801031d1:	83 c4 04             	add    $0x4,%esp
801031d4:	25 80 00 00 00       	and    $0x80,%eax
801031d9:	85 c0                	test   %eax,%eax
801031db:	75 27                	jne    80103204 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031dd:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031e0:	50                   	push   %eax
801031e1:	e8 4f ff ff ff       	call   80103135 <fill_rtcdate>
801031e6:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031e9:	83 ec 04             	sub    $0x4,%esp
801031ec:	6a 18                	push   $0x18
801031ee:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031f1:	50                   	push   %eax
801031f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031f5:	50                   	push   %eax
801031f6:	e8 ba 1c 00 00       	call   80104eb5 <memcmp>
801031fb:	83 c4 10             	add    $0x10,%esp
801031fe:	85 c0                	test   %eax,%eax
80103200:	74 05                	je     80103207 <cmostime+0x6d>
80103202:	eb ba                	jmp    801031be <cmostime+0x24>
        continue;
80103204:	90                   	nop
    fill_rtcdate(&t1);
80103205:	eb b7                	jmp    801031be <cmostime+0x24>
      break;
80103207:	90                   	nop
  }

  // convert
  if(bcd) {
80103208:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010320c:	0f 84 b4 00 00 00    	je     801032c6 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103212:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103215:	c1 e8 04             	shr    $0x4,%eax
80103218:	89 c2                	mov    %eax,%edx
8010321a:	89 d0                	mov    %edx,%eax
8010321c:	c1 e0 02             	shl    $0x2,%eax
8010321f:	01 d0                	add    %edx,%eax
80103221:	01 c0                	add    %eax,%eax
80103223:	89 c2                	mov    %eax,%edx
80103225:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103228:	83 e0 0f             	and    $0xf,%eax
8010322b:	01 d0                	add    %edx,%eax
8010322d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103230:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103233:	c1 e8 04             	shr    $0x4,%eax
80103236:	89 c2                	mov    %eax,%edx
80103238:	89 d0                	mov    %edx,%eax
8010323a:	c1 e0 02             	shl    $0x2,%eax
8010323d:	01 d0                	add    %edx,%eax
8010323f:	01 c0                	add    %eax,%eax
80103241:	89 c2                	mov    %eax,%edx
80103243:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103246:	83 e0 0f             	and    $0xf,%eax
80103249:	01 d0                	add    %edx,%eax
8010324b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010324e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103251:	c1 e8 04             	shr    $0x4,%eax
80103254:	89 c2                	mov    %eax,%edx
80103256:	89 d0                	mov    %edx,%eax
80103258:	c1 e0 02             	shl    $0x2,%eax
8010325b:	01 d0                	add    %edx,%eax
8010325d:	01 c0                	add    %eax,%eax
8010325f:	89 c2                	mov    %eax,%edx
80103261:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103264:	83 e0 0f             	and    $0xf,%eax
80103267:	01 d0                	add    %edx,%eax
80103269:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010326c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010326f:	c1 e8 04             	shr    $0x4,%eax
80103272:	89 c2                	mov    %eax,%edx
80103274:	89 d0                	mov    %edx,%eax
80103276:	c1 e0 02             	shl    $0x2,%eax
80103279:	01 d0                	add    %edx,%eax
8010327b:	01 c0                	add    %eax,%eax
8010327d:	89 c2                	mov    %eax,%edx
8010327f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103282:	83 e0 0f             	and    $0xf,%eax
80103285:	01 d0                	add    %edx,%eax
80103287:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010328a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010328d:	c1 e8 04             	shr    $0x4,%eax
80103290:	89 c2                	mov    %eax,%edx
80103292:	89 d0                	mov    %edx,%eax
80103294:	c1 e0 02             	shl    $0x2,%eax
80103297:	01 d0                	add    %edx,%eax
80103299:	01 c0                	add    %eax,%eax
8010329b:	89 c2                	mov    %eax,%edx
8010329d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032a0:	83 e0 0f             	and    $0xf,%eax
801032a3:	01 d0                	add    %edx,%eax
801032a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032ab:	c1 e8 04             	shr    $0x4,%eax
801032ae:	89 c2                	mov    %eax,%edx
801032b0:	89 d0                	mov    %edx,%eax
801032b2:	c1 e0 02             	shl    $0x2,%eax
801032b5:	01 d0                	add    %edx,%eax
801032b7:	01 c0                	add    %eax,%eax
801032b9:	89 c2                	mov    %eax,%edx
801032bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032be:	83 e0 0f             	and    $0xf,%eax
801032c1:	01 d0                	add    %edx,%eax
801032c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032c6:	8b 45 08             	mov    0x8(%ebp),%eax
801032c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032cc:	89 10                	mov    %edx,(%eax)
801032ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032d1:	89 50 04             	mov    %edx,0x4(%eax)
801032d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032d7:	89 50 08             	mov    %edx,0x8(%eax)
801032da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032dd:	89 50 0c             	mov    %edx,0xc(%eax)
801032e0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032e3:	89 50 10             	mov    %edx,0x10(%eax)
801032e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032e9:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032ec:	8b 45 08             	mov    0x8(%ebp),%eax
801032ef:	8b 40 14             	mov    0x14(%eax),%eax
801032f2:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032f8:	8b 45 08             	mov    0x8(%ebp),%eax
801032fb:	89 50 14             	mov    %edx,0x14(%eax)
}
801032fe:	90                   	nop
801032ff:	c9                   	leave  
80103300:	c3                   	ret    

80103301 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103301:	55                   	push   %ebp
80103302:	89 e5                	mov    %esp,%ebp
80103304:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103307:	83 ec 08             	sub    $0x8,%esp
8010330a:	68 15 a6 10 80       	push   $0x8010a615
8010330f:	68 60 71 11 80       	push   $0x80117160
80103314:	e8 9d 18 00 00       	call   80104bb6 <initlock>
80103319:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010331c:	83 ec 08             	sub    $0x8,%esp
8010331f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103322:	50                   	push   %eax
80103323:	ff 75 08             	push   0x8(%ebp)
80103326:	e8 a3 e0 ff ff       	call   801013ce <readsb>
8010332b:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010332e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103331:	a3 94 71 11 80       	mov    %eax,0x80117194
  log.size = sb.nlog;
80103336:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103339:	a3 98 71 11 80       	mov    %eax,0x80117198
  log.dev = dev;
8010333e:	8b 45 08             	mov    0x8(%ebp),%eax
80103341:	a3 a4 71 11 80       	mov    %eax,0x801171a4
  recover_from_log();
80103346:	e8 b3 01 00 00       	call   801034fe <recover_from_log>
}
8010334b:	90                   	nop
8010334c:	c9                   	leave  
8010334d:	c3                   	ret    

8010334e <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010334e:	55                   	push   %ebp
8010334f:	89 e5                	mov    %esp,%ebp
80103351:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103354:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010335b:	e9 95 00 00 00       	jmp    801033f5 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103360:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103369:	01 d0                	add    %edx,%eax
8010336b:	83 c0 01             	add    $0x1,%eax
8010336e:	89 c2                	mov    %eax,%edx
80103370:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103375:	83 ec 08             	sub    $0x8,%esp
80103378:	52                   	push   %edx
80103379:	50                   	push   %eax
8010337a:	e8 82 ce ff ff       	call   80100201 <bread>
8010337f:	83 c4 10             	add    $0x10,%esp
80103382:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103388:	83 c0 10             	add    $0x10,%eax
8010338b:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
80103392:	89 c2                	mov    %eax,%edx
80103394:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103399:	83 ec 08             	sub    $0x8,%esp
8010339c:	52                   	push   %edx
8010339d:	50                   	push   %eax
8010339e:	e8 5e ce ff ff       	call   80100201 <bread>
801033a3:	83 c4 10             	add    $0x10,%esp
801033a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ac:	8d 50 5c             	lea    0x5c(%eax),%edx
801033af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033b2:	83 c0 5c             	add    $0x5c,%eax
801033b5:	83 ec 04             	sub    $0x4,%esp
801033b8:	68 00 02 00 00       	push   $0x200
801033bd:	52                   	push   %edx
801033be:	50                   	push   %eax
801033bf:	e8 49 1b 00 00       	call   80104f0d <memmove>
801033c4:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033c7:	83 ec 0c             	sub    $0xc,%esp
801033ca:	ff 75 ec             	push   -0x14(%ebp)
801033cd:	e8 68 ce ff ff       	call   8010023a <bwrite>
801033d2:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801033d5:	83 ec 0c             	sub    $0xc,%esp
801033d8:	ff 75 f0             	push   -0x10(%ebp)
801033db:	e8 a3 ce ff ff       	call   80100283 <brelse>
801033e0:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033e3:	83 ec 0c             	sub    $0xc,%esp
801033e6:	ff 75 ec             	push   -0x14(%ebp)
801033e9:	e8 95 ce ff ff       	call   80100283 <brelse>
801033ee:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033f5:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801033fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801033fd:	0f 8c 5d ff ff ff    	jl     80103360 <install_trans+0x12>
  }
}
80103403:	90                   	nop
80103404:	90                   	nop
80103405:	c9                   	leave  
80103406:	c3                   	ret    

80103407 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103407:	55                   	push   %ebp
80103408:	89 e5                	mov    %esp,%ebp
8010340a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010340d:	a1 94 71 11 80       	mov    0x80117194,%eax
80103412:	89 c2                	mov    %eax,%edx
80103414:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103419:	83 ec 08             	sub    $0x8,%esp
8010341c:	52                   	push   %edx
8010341d:	50                   	push   %eax
8010341e:	e8 de cd ff ff       	call   80100201 <bread>
80103423:	83 c4 10             	add    $0x10,%esp
80103426:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010342c:	83 c0 5c             	add    $0x5c,%eax
8010342f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103432:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103435:	8b 00                	mov    (%eax),%eax
80103437:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  for (i = 0; i < log.lh.n; i++) {
8010343c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103443:	eb 1b                	jmp    80103460 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103445:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103448:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010344b:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010344f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103452:	83 c2 10             	add    $0x10,%edx
80103455:	89 04 95 6c 71 11 80 	mov    %eax,-0x7fee8e94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010345c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103460:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103465:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103468:	7c db                	jl     80103445 <read_head+0x3e>
  }
  brelse(buf);
8010346a:	83 ec 0c             	sub    $0xc,%esp
8010346d:	ff 75 f0             	push   -0x10(%ebp)
80103470:	e8 0e ce ff ff       	call   80100283 <brelse>
80103475:	83 c4 10             	add    $0x10,%esp
}
80103478:	90                   	nop
80103479:	c9                   	leave  
8010347a:	c3                   	ret    

8010347b <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010347b:	55                   	push   %ebp
8010347c:	89 e5                	mov    %esp,%ebp
8010347e:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103481:	a1 94 71 11 80       	mov    0x80117194,%eax
80103486:	89 c2                	mov    %eax,%edx
80103488:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010348d:	83 ec 08             	sub    $0x8,%esp
80103490:	52                   	push   %edx
80103491:	50                   	push   %eax
80103492:	e8 6a cd ff ff       	call   80100201 <bread>
80103497:	83 c4 10             	add    $0x10,%esp
8010349a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010349d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a0:	83 c0 5c             	add    $0x5c,%eax
801034a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034a6:	8b 15 a8 71 11 80    	mov    0x801171a8,%edx
801034ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034af:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034b8:	eb 1b                	jmp    801034d5 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034bd:	83 c0 10             	add    $0x10,%eax
801034c0:	8b 0c 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%ecx
801034c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034cd:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034d5:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801034da:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034dd:	7c db                	jl     801034ba <write_head+0x3f>
  }
  bwrite(buf);
801034df:	83 ec 0c             	sub    $0xc,%esp
801034e2:	ff 75 f0             	push   -0x10(%ebp)
801034e5:	e8 50 cd ff ff       	call   8010023a <bwrite>
801034ea:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034ed:	83 ec 0c             	sub    $0xc,%esp
801034f0:	ff 75 f0             	push   -0x10(%ebp)
801034f3:	e8 8b cd ff ff       	call   80100283 <brelse>
801034f8:	83 c4 10             	add    $0x10,%esp
}
801034fb:	90                   	nop
801034fc:	c9                   	leave  
801034fd:	c3                   	ret    

801034fe <recover_from_log>:

static void
recover_from_log(void)
{
801034fe:	55                   	push   %ebp
801034ff:	89 e5                	mov    %esp,%ebp
80103501:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103504:	e8 fe fe ff ff       	call   80103407 <read_head>
  install_trans(); // if committed, copy from log to disk
80103509:	e8 40 fe ff ff       	call   8010334e <install_trans>
  log.lh.n = 0;
8010350e:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
80103515:	00 00 00 
  write_head(); // clear the log
80103518:	e8 5e ff ff ff       	call   8010347b <write_head>
}
8010351d:	90                   	nop
8010351e:	c9                   	leave  
8010351f:	c3                   	ret    

80103520 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103520:	55                   	push   %ebp
80103521:	89 e5                	mov    %esp,%ebp
80103523:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103526:	83 ec 0c             	sub    $0xc,%esp
80103529:	68 60 71 11 80       	push   $0x80117160
8010352e:	e8 a5 16 00 00       	call   80104bd8 <acquire>
80103533:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103536:	a1 a0 71 11 80       	mov    0x801171a0,%eax
8010353b:	85 c0                	test   %eax,%eax
8010353d:	74 17                	je     80103556 <begin_op+0x36>
      sleep(&log, &log.lock);
8010353f:	83 ec 08             	sub    $0x8,%esp
80103542:	68 60 71 11 80       	push   $0x80117160
80103547:	68 60 71 11 80       	push   $0x80117160
8010354c:	e8 6c 12 00 00       	call   801047bd <sleep>
80103551:	83 c4 10             	add    $0x10,%esp
80103554:	eb e0                	jmp    80103536 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103556:	8b 0d a8 71 11 80    	mov    0x801171a8,%ecx
8010355c:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103561:	8d 50 01             	lea    0x1(%eax),%edx
80103564:	89 d0                	mov    %edx,%eax
80103566:	c1 e0 02             	shl    $0x2,%eax
80103569:	01 d0                	add    %edx,%eax
8010356b:	01 c0                	add    %eax,%eax
8010356d:	01 c8                	add    %ecx,%eax
8010356f:	83 f8 1e             	cmp    $0x1e,%eax
80103572:	7e 17                	jle    8010358b <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103574:	83 ec 08             	sub    $0x8,%esp
80103577:	68 60 71 11 80       	push   $0x80117160
8010357c:	68 60 71 11 80       	push   $0x80117160
80103581:	e8 37 12 00 00       	call   801047bd <sleep>
80103586:	83 c4 10             	add    $0x10,%esp
80103589:	eb ab                	jmp    80103536 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010358b:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103590:	83 c0 01             	add    $0x1,%eax
80103593:	a3 9c 71 11 80       	mov    %eax,0x8011719c
      release(&log.lock);
80103598:	83 ec 0c             	sub    $0xc,%esp
8010359b:	68 60 71 11 80       	push   $0x80117160
801035a0:	e8 a1 16 00 00       	call   80104c46 <release>
801035a5:	83 c4 10             	add    $0x10,%esp
      break;
801035a8:	90                   	nop
    }
  }
}
801035a9:	90                   	nop
801035aa:	c9                   	leave  
801035ab:	c3                   	ret    

801035ac <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035ac:	55                   	push   %ebp
801035ad:	89 e5                	mov    %esp,%ebp
801035af:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035b9:	83 ec 0c             	sub    $0xc,%esp
801035bc:	68 60 71 11 80       	push   $0x80117160
801035c1:	e8 12 16 00 00       	call   80104bd8 <acquire>
801035c6:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035c9:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035ce:	83 e8 01             	sub    $0x1,%eax
801035d1:	a3 9c 71 11 80       	mov    %eax,0x8011719c
  if(log.committing)
801035d6:	a1 a0 71 11 80       	mov    0x801171a0,%eax
801035db:	85 c0                	test   %eax,%eax
801035dd:	74 0d                	je     801035ec <end_op+0x40>
    panic("log.committing");
801035df:	83 ec 0c             	sub    $0xc,%esp
801035e2:	68 19 a6 10 80       	push   $0x8010a619
801035e7:	e8 bd cf ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801035ec:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035f1:	85 c0                	test   %eax,%eax
801035f3:	75 13                	jne    80103608 <end_op+0x5c>
    do_commit = 1;
801035f5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035fc:	c7 05 a0 71 11 80 01 	movl   $0x1,0x801171a0
80103603:	00 00 00 
80103606:	eb 10                	jmp    80103618 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103608:	83 ec 0c             	sub    $0xc,%esp
8010360b:	68 60 71 11 80       	push   $0x80117160
80103610:	e8 8f 12 00 00       	call   801048a4 <wakeup>
80103615:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103618:	83 ec 0c             	sub    $0xc,%esp
8010361b:	68 60 71 11 80       	push   $0x80117160
80103620:	e8 21 16 00 00       	call   80104c46 <release>
80103625:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103628:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010362c:	74 3f                	je     8010366d <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010362e:	e8 f6 00 00 00       	call   80103729 <commit>
    acquire(&log.lock);
80103633:	83 ec 0c             	sub    $0xc,%esp
80103636:	68 60 71 11 80       	push   $0x80117160
8010363b:	e8 98 15 00 00       	call   80104bd8 <acquire>
80103640:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103643:	c7 05 a0 71 11 80 00 	movl   $0x0,0x801171a0
8010364a:	00 00 00 
    wakeup(&log);
8010364d:	83 ec 0c             	sub    $0xc,%esp
80103650:	68 60 71 11 80       	push   $0x80117160
80103655:	e8 4a 12 00 00       	call   801048a4 <wakeup>
8010365a:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010365d:	83 ec 0c             	sub    $0xc,%esp
80103660:	68 60 71 11 80       	push   $0x80117160
80103665:	e8 dc 15 00 00       	call   80104c46 <release>
8010366a:	83 c4 10             	add    $0x10,%esp
  }
}
8010366d:	90                   	nop
8010366e:	c9                   	leave  
8010366f:	c3                   	ret    

80103670 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103670:	55                   	push   %ebp
80103671:	89 e5                	mov    %esp,%ebp
80103673:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010367d:	e9 95 00 00 00       	jmp    80103717 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103682:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010368b:	01 d0                	add    %edx,%eax
8010368d:	83 c0 01             	add    $0x1,%eax
80103690:	89 c2                	mov    %eax,%edx
80103692:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103697:	83 ec 08             	sub    $0x8,%esp
8010369a:	52                   	push   %edx
8010369b:	50                   	push   %eax
8010369c:	e8 60 cb ff ff       	call   80100201 <bread>
801036a1:	83 c4 10             	add    $0x10,%esp
801036a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036aa:	83 c0 10             	add    $0x10,%eax
801036ad:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801036b4:	89 c2                	mov    %eax,%edx
801036b6:	a1 a4 71 11 80       	mov    0x801171a4,%eax
801036bb:	83 ec 08             	sub    $0x8,%esp
801036be:	52                   	push   %edx
801036bf:	50                   	push   %eax
801036c0:	e8 3c cb ff ff       	call   80100201 <bread>
801036c5:	83 c4 10             	add    $0x10,%esp
801036c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036ce:	8d 50 5c             	lea    0x5c(%eax),%edx
801036d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036d4:	83 c0 5c             	add    $0x5c,%eax
801036d7:	83 ec 04             	sub    $0x4,%esp
801036da:	68 00 02 00 00       	push   $0x200
801036df:	52                   	push   %edx
801036e0:	50                   	push   %eax
801036e1:	e8 27 18 00 00       	call   80104f0d <memmove>
801036e6:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036e9:	83 ec 0c             	sub    $0xc,%esp
801036ec:	ff 75 f0             	push   -0x10(%ebp)
801036ef:	e8 46 cb ff ff       	call   8010023a <bwrite>
801036f4:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801036f7:	83 ec 0c             	sub    $0xc,%esp
801036fa:	ff 75 ec             	push   -0x14(%ebp)
801036fd:	e8 81 cb ff ff       	call   80100283 <brelse>
80103702:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103705:	83 ec 0c             	sub    $0xc,%esp
80103708:	ff 75 f0             	push   -0x10(%ebp)
8010370b:	e8 73 cb ff ff       	call   80100283 <brelse>
80103710:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103713:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103717:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010371c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010371f:	0f 8c 5d ff ff ff    	jl     80103682 <write_log+0x12>
  }
}
80103725:	90                   	nop
80103726:	90                   	nop
80103727:	c9                   	leave  
80103728:	c3                   	ret    

80103729 <commit>:

static void
commit()
{
80103729:	55                   	push   %ebp
8010372a:	89 e5                	mov    %esp,%ebp
8010372c:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010372f:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	7e 1e                	jle    80103756 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103738:	e8 33 ff ff ff       	call   80103670 <write_log>
    write_head();    // Write header to disk -- the real commit
8010373d:	e8 39 fd ff ff       	call   8010347b <write_head>
    install_trans(); // Now install writes to home locations
80103742:	e8 07 fc ff ff       	call   8010334e <install_trans>
    log.lh.n = 0;
80103747:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
8010374e:	00 00 00 
    write_head();    // Erase the transaction from the log
80103751:	e8 25 fd ff ff       	call   8010347b <write_head>
  }
}
80103756:	90                   	nop
80103757:	c9                   	leave  
80103758:	c3                   	ret    

80103759 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103759:	55                   	push   %ebp
8010375a:	89 e5                	mov    %esp,%ebp
8010375c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010375f:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103764:	83 f8 1d             	cmp    $0x1d,%eax
80103767:	7f 12                	jg     8010377b <log_write+0x22>
80103769:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010376e:	8b 15 98 71 11 80    	mov    0x80117198,%edx
80103774:	83 ea 01             	sub    $0x1,%edx
80103777:	39 d0                	cmp    %edx,%eax
80103779:	7c 0d                	jl     80103788 <log_write+0x2f>
    panic("too big a transaction");
8010377b:	83 ec 0c             	sub    $0xc,%esp
8010377e:	68 28 a6 10 80       	push   $0x8010a628
80103783:	e8 21 ce ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
80103788:	a1 9c 71 11 80       	mov    0x8011719c,%eax
8010378d:	85 c0                	test   %eax,%eax
8010378f:	7f 0d                	jg     8010379e <log_write+0x45>
    panic("log_write outside of trans");
80103791:	83 ec 0c             	sub    $0xc,%esp
80103794:	68 3e a6 10 80       	push   $0x8010a63e
80103799:	e8 0b ce ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	68 60 71 11 80       	push   $0x80117160
801037a6:	e8 2d 14 00 00       	call   80104bd8 <acquire>
801037ab:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037b5:	eb 1d                	jmp    801037d4 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ba:	83 c0 10             	add    $0x10,%eax
801037bd:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801037c4:	89 c2                	mov    %eax,%edx
801037c6:	8b 45 08             	mov    0x8(%ebp),%eax
801037c9:	8b 40 08             	mov    0x8(%eax),%eax
801037cc:	39 c2                	cmp    %eax,%edx
801037ce:	74 10                	je     801037e0 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801037d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037d4:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037d9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037dc:	7c d9                	jl     801037b7 <log_write+0x5e>
801037de:	eb 01                	jmp    801037e1 <log_write+0x88>
      break;
801037e0:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037e1:	8b 45 08             	mov    0x8(%ebp),%eax
801037e4:	8b 40 08             	mov    0x8(%eax),%eax
801037e7:	89 c2                	mov    %eax,%edx
801037e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ec:	83 c0 10             	add    $0x10,%eax
801037ef:	89 14 85 6c 71 11 80 	mov    %edx,-0x7fee8e94(,%eax,4)
  if (i == log.lh.n)
801037f6:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037fb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037fe:	75 0d                	jne    8010380d <log_write+0xb4>
    log.lh.n++;
80103800:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103805:	83 c0 01             	add    $0x1,%eax
80103808:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  b->flags |= B_DIRTY; // prevent eviction
8010380d:	8b 45 08             	mov    0x8(%ebp),%eax
80103810:	8b 00                	mov    (%eax),%eax
80103812:	83 c8 04             	or     $0x4,%eax
80103815:	89 c2                	mov    %eax,%edx
80103817:	8b 45 08             	mov    0x8(%ebp),%eax
8010381a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010381c:	83 ec 0c             	sub    $0xc,%esp
8010381f:	68 60 71 11 80       	push   $0x80117160
80103824:	e8 1d 14 00 00       	call   80104c46 <release>
80103829:	83 c4 10             	add    $0x10,%esp
}
8010382c:	90                   	nop
8010382d:	c9                   	leave  
8010382e:	c3                   	ret    

8010382f <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010382f:	55                   	push   %ebp
80103830:	89 e5                	mov    %esp,%ebp
80103832:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103835:	8b 55 08             	mov    0x8(%ebp),%edx
80103838:	8b 45 0c             	mov    0xc(%ebp),%eax
8010383b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010383e:	f0 87 02             	lock xchg %eax,(%edx)
80103841:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103844:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103847:	c9                   	leave  
80103848:	c3                   	ret    

80103849 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103849:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010384d:	83 e4 f0             	and    $0xfffffff0,%esp
80103850:	ff 71 fc             	push   -0x4(%ecx)
80103853:	55                   	push   %ebp
80103854:	89 e5                	mov    %esp,%ebp
80103856:	51                   	push   %ecx
80103857:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
8010385a:	e8 de 49 00 00       	call   8010823d <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010385f:	83 ec 08             	sub    $0x8,%esp
80103862:	68 00 00 40 80       	push   $0x80400000
80103867:	68 00 c0 11 80       	push   $0x8011c000
8010386c:	e8 de f2 ff ff       	call   80102b4f <kinit1>
80103871:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103874:	e8 de 3f 00 00       	call   80107857 <kvmalloc>
  mpinit_uefi();
80103879:	e8 85 47 00 00       	call   80108003 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010387e:	e8 3c f6 ff ff       	call   80102ebf <lapicinit>
  seginit();       // segment descriptors
80103883:	e8 67 3a 00 00       	call   801072ef <seginit>
  picinit();    // disable pic
80103888:	e8 9d 01 00 00       	call   80103a2a <picinit>
  ioapicinit();    // another interrupt controller
8010388d:	e8 d8 f1 ff ff       	call   80102a6a <ioapicinit>
  consoleinit();   // console hardware
80103892:	e8 68 d2 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
80103897:	e8 ec 2d 00 00       	call   80106688 <uartinit>
  pinit();         // process table
8010389c:	e8 c2 05 00 00       	call   80103e63 <pinit>
  tvinit();        // trap vectors
801038a1:	e8 b3 29 00 00       	call   80106259 <tvinit>
  binit();         // buffer cache
801038a6:	e8 bb c7 ff ff       	call   80100066 <binit>
  fileinit();      // file table
801038ab:	e8 0f d7 ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801038b0:	e8 6e ed ff ff       	call   80102623 <ideinit>
  startothers();   // start other processors
801038b5:	e8 8a 00 00 00       	call   80103944 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038ba:	83 ec 08             	sub    $0x8,%esp
801038bd:	68 00 00 00 a0       	push   $0xa0000000
801038c2:	68 00 00 40 80       	push   $0x80400000
801038c7:	e8 bc f2 ff ff       	call   80102b88 <kinit2>
801038cc:	83 c4 10             	add    $0x10,%esp
  pci_init();
801038cf:	e8 c2 4b 00 00       	call   80108496 <pci_init>
  arp_scan();
801038d4:	e8 f9 58 00 00       	call   801091d2 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801038d9:	e8 63 07 00 00       	call   80104041 <userinit>

  mpmain();        // finish this processor's setup
801038de:	e8 1a 00 00 00       	call   801038fd <mpmain>

801038e3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038e3:	55                   	push   %ebp
801038e4:	89 e5                	mov    %esp,%ebp
801038e6:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038e9:	e8 81 3f 00 00       	call   8010786f <switchkvm>
  seginit();
801038ee:	e8 fc 39 00 00       	call   801072ef <seginit>
  lapicinit();
801038f3:	e8 c7 f5 ff ff       	call   80102ebf <lapicinit>
  mpmain();
801038f8:	e8 00 00 00 00       	call   801038fd <mpmain>

801038fd <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038fd:	55                   	push   %ebp
801038fe:	89 e5                	mov    %esp,%ebp
80103900:	53                   	push   %ebx
80103901:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103904:	e8 78 05 00 00       	call   80103e81 <cpuid>
80103909:	89 c3                	mov    %eax,%ebx
8010390b:	e8 71 05 00 00       	call   80103e81 <cpuid>
80103910:	83 ec 04             	sub    $0x4,%esp
80103913:	53                   	push   %ebx
80103914:	50                   	push   %eax
80103915:	68 59 a6 10 80       	push   $0x8010a659
8010391a:	e8 d5 ca ff ff       	call   801003f4 <cprintf>
8010391f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103922:	e8 a8 2a 00 00       	call   801063cf <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103927:	e8 70 05 00 00       	call   80103e9c <mycpu>
8010392c:	05 a0 00 00 00       	add    $0xa0,%eax
80103931:	83 ec 08             	sub    $0x8,%esp
80103934:	6a 01                	push   $0x1
80103936:	50                   	push   %eax
80103937:	e8 f3 fe ff ff       	call   8010382f <xchg>
8010393c:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010393f:	e8 88 0c 00 00       	call   801045cc <scheduler>

80103944 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103944:	55                   	push   %ebp
80103945:	89 e5                	mov    %esp,%ebp
80103947:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010394a:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103951:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103956:	83 ec 04             	sub    $0x4,%esp
80103959:	50                   	push   %eax
8010395a:	68 18 f5 10 80       	push   $0x8010f518
8010395f:	ff 75 f0             	push   -0x10(%ebp)
80103962:	e8 a6 15 00 00       	call   80104f0d <memmove>
80103967:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010396a:	c7 45 f4 c0 9a 11 80 	movl   $0x80119ac0,-0xc(%ebp)
80103971:	eb 79                	jmp    801039ec <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103973:	e8 24 05 00 00       	call   80103e9c <mycpu>
80103978:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010397b:	74 67                	je     801039e4 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010397d:	e8 02 f3 ff ff       	call   80102c84 <kalloc>
80103982:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103988:	83 e8 04             	sub    $0x4,%eax
8010398b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010398e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103994:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103999:	83 e8 08             	sub    $0x8,%eax
8010399c:	c7 00 e3 38 10 80    	movl   $0x801038e3,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039a2:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801039a7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b0:	83 e8 0c             	sub    $0xc,%eax
801039b3:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c1:	0f b6 00             	movzbl (%eax),%eax
801039c4:	0f b6 c0             	movzbl %al,%eax
801039c7:	83 ec 08             	sub    $0x8,%esp
801039ca:	52                   	push   %edx
801039cb:	50                   	push   %eax
801039cc:	e8 50 f6 ff ff       	call   80103021 <lapicstartap>
801039d1:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039d4:	90                   	nop
801039d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039de:	85 c0                	test   %eax,%eax
801039e0:	74 f3                	je     801039d5 <startothers+0x91>
801039e2:	eb 01                	jmp    801039e5 <startothers+0xa1>
      continue;
801039e4:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801039e5:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039ec:	a1 80 9d 11 80       	mov    0x80119d80,%eax
801039f1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f7:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
801039fc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039ff:	0f 82 6e ff ff ff    	jb     80103973 <startothers+0x2f>
      ;
  }
}
80103a05:	90                   	nop
80103a06:	90                   	nop
80103a07:	c9                   	leave  
80103a08:	c3                   	ret    

80103a09 <outb>:
{
80103a09:	55                   	push   %ebp
80103a0a:	89 e5                	mov    %esp,%ebp
80103a0c:	83 ec 08             	sub    $0x8,%esp
80103a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a12:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a15:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a19:	89 d0                	mov    %edx,%eax
80103a1b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a1e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a22:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a26:	ee                   	out    %al,(%dx)
}
80103a27:	90                   	nop
80103a28:	c9                   	leave  
80103a29:	c3                   	ret    

80103a2a <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103a2a:	55                   	push   %ebp
80103a2b:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103a2d:	68 ff 00 00 00       	push   $0xff
80103a32:	6a 21                	push   $0x21
80103a34:	e8 d0 ff ff ff       	call   80103a09 <outb>
80103a39:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103a3c:	68 ff 00 00 00       	push   $0xff
80103a41:	68 a1 00 00 00       	push   $0xa1
80103a46:	e8 be ff ff ff       	call   80103a09 <outb>
80103a4b:	83 c4 08             	add    $0x8,%esp
}
80103a4e:	90                   	nop
80103a4f:	c9                   	leave  
80103a50:	c3                   	ret    

80103a51 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103a51:	55                   	push   %ebp
80103a52:	89 e5                	mov    %esp,%ebp
80103a54:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103a57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a61:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103a67:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a6a:	8b 10                	mov    (%eax),%edx
80103a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6f:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103a71:	e8 67 d5 ff ff       	call   80100fdd <filealloc>
80103a76:	8b 55 08             	mov    0x8(%ebp),%edx
80103a79:	89 02                	mov    %eax,(%edx)
80103a7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7e:	8b 00                	mov    (%eax),%eax
80103a80:	85 c0                	test   %eax,%eax
80103a82:	0f 84 c8 00 00 00    	je     80103b50 <pipealloc+0xff>
80103a88:	e8 50 d5 ff ff       	call   80100fdd <filealloc>
80103a8d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a90:	89 02                	mov    %eax,(%edx)
80103a92:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a95:	8b 00                	mov    (%eax),%eax
80103a97:	85 c0                	test   %eax,%eax
80103a99:	0f 84 b1 00 00 00    	je     80103b50 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103a9f:	e8 e0 f1 ff ff       	call   80102c84 <kalloc>
80103aa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103aa7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103aab:	0f 84 a2 00 00 00    	je     80103b53 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
80103ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab4:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103abb:	00 00 00 
  p->writeopen = 1;
80103abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac1:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103ac8:	00 00 00 
  p->nwrite = 0;
80103acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ace:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ad5:	00 00 00 
  p->nread = 0;
80103ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103adb:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ae2:	00 00 00 
  initlock(&p->lock, "pipe");
80103ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae8:	83 ec 08             	sub    $0x8,%esp
80103aeb:	68 6d a6 10 80       	push   $0x8010a66d
80103af0:	50                   	push   %eax
80103af1:	e8 c0 10 00 00       	call   80104bb6 <initlock>
80103af6:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103af9:	8b 45 08             	mov    0x8(%ebp),%eax
80103afc:	8b 00                	mov    (%eax),%eax
80103afe:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103b04:	8b 45 08             	mov    0x8(%ebp),%eax
80103b07:	8b 00                	mov    (%eax),%eax
80103b09:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80103b10:	8b 00                	mov    (%eax),%eax
80103b12:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103b16:	8b 45 08             	mov    0x8(%ebp),%eax
80103b19:	8b 00                	mov    (%eax),%eax
80103b1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b1e:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103b21:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b24:	8b 00                	mov    (%eax),%eax
80103b26:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b2f:	8b 00                	mov    (%eax),%eax
80103b31:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103b35:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b38:	8b 00                	mov    (%eax),%eax
80103b3a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b41:	8b 00                	mov    (%eax),%eax
80103b43:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b46:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103b49:	b8 00 00 00 00       	mov    $0x0,%eax
80103b4e:	eb 51                	jmp    80103ba1 <pipealloc+0x150>
    goto bad;
80103b50:	90                   	nop
80103b51:	eb 01                	jmp    80103b54 <pipealloc+0x103>
    goto bad;
80103b53:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103b54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b58:	74 0e                	je     80103b68 <pipealloc+0x117>
    kfree((char*)p);
80103b5a:	83 ec 0c             	sub    $0xc,%esp
80103b5d:	ff 75 f4             	push   -0xc(%ebp)
80103b60:	e8 85 f0 ff ff       	call   80102bea <kfree>
80103b65:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103b68:	8b 45 08             	mov    0x8(%ebp),%eax
80103b6b:	8b 00                	mov    (%eax),%eax
80103b6d:	85 c0                	test   %eax,%eax
80103b6f:	74 11                	je     80103b82 <pipealloc+0x131>
    fileclose(*f0);
80103b71:	8b 45 08             	mov    0x8(%ebp),%eax
80103b74:	8b 00                	mov    (%eax),%eax
80103b76:	83 ec 0c             	sub    $0xc,%esp
80103b79:	50                   	push   %eax
80103b7a:	e8 1c d5 ff ff       	call   8010109b <fileclose>
80103b7f:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103b82:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b85:	8b 00                	mov    (%eax),%eax
80103b87:	85 c0                	test   %eax,%eax
80103b89:	74 11                	je     80103b9c <pipealloc+0x14b>
    fileclose(*f1);
80103b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b8e:	8b 00                	mov    (%eax),%eax
80103b90:	83 ec 0c             	sub    $0xc,%esp
80103b93:	50                   	push   %eax
80103b94:	e8 02 d5 ff ff       	call   8010109b <fileclose>
80103b99:	83 c4 10             	add    $0x10,%esp
  return -1;
80103b9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103ba1:	c9                   	leave  
80103ba2:	c3                   	ret    

80103ba3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103ba3:	55                   	push   %ebp
80103ba4:	89 e5                	mov    %esp,%ebp
80103ba6:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80103bac:	83 ec 0c             	sub    $0xc,%esp
80103baf:	50                   	push   %eax
80103bb0:	e8 23 10 00 00       	call   80104bd8 <acquire>
80103bb5:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103bb8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103bbc:	74 23                	je     80103be1 <pipeclose+0x3e>
    p->writeopen = 0;
80103bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc1:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103bc8:	00 00 00 
    wakeup(&p->nread);
80103bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80103bce:	05 34 02 00 00       	add    $0x234,%eax
80103bd3:	83 ec 0c             	sub    $0xc,%esp
80103bd6:	50                   	push   %eax
80103bd7:	e8 c8 0c 00 00       	call   801048a4 <wakeup>
80103bdc:	83 c4 10             	add    $0x10,%esp
80103bdf:	eb 21                	jmp    80103c02 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103be1:	8b 45 08             	mov    0x8(%ebp),%eax
80103be4:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103beb:	00 00 00 
    wakeup(&p->nwrite);
80103bee:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf1:	05 38 02 00 00       	add    $0x238,%eax
80103bf6:	83 ec 0c             	sub    $0xc,%esp
80103bf9:	50                   	push   %eax
80103bfa:	e8 a5 0c 00 00       	call   801048a4 <wakeup>
80103bff:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103c02:	8b 45 08             	mov    0x8(%ebp),%eax
80103c05:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c0b:	85 c0                	test   %eax,%eax
80103c0d:	75 2c                	jne    80103c3b <pipeclose+0x98>
80103c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103c12:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103c18:	85 c0                	test   %eax,%eax
80103c1a:	75 1f                	jne    80103c3b <pipeclose+0x98>
    release(&p->lock);
80103c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103c1f:	83 ec 0c             	sub    $0xc,%esp
80103c22:	50                   	push   %eax
80103c23:	e8 1e 10 00 00       	call   80104c46 <release>
80103c28:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103c2b:	83 ec 0c             	sub    $0xc,%esp
80103c2e:	ff 75 08             	push   0x8(%ebp)
80103c31:	e8 b4 ef ff ff       	call   80102bea <kfree>
80103c36:	83 c4 10             	add    $0x10,%esp
80103c39:	eb 10                	jmp    80103c4b <pipeclose+0xa8>
  } else
    release(&p->lock);
80103c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3e:	83 ec 0c             	sub    $0xc,%esp
80103c41:	50                   	push   %eax
80103c42:	e8 ff 0f 00 00       	call   80104c46 <release>
80103c47:	83 c4 10             	add    $0x10,%esp
}
80103c4a:	90                   	nop
80103c4b:	90                   	nop
80103c4c:	c9                   	leave  
80103c4d:	c3                   	ret    

80103c4e <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103c4e:	55                   	push   %ebp
80103c4f:	89 e5                	mov    %esp,%ebp
80103c51:	53                   	push   %ebx
80103c52:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103c55:	8b 45 08             	mov    0x8(%ebp),%eax
80103c58:	83 ec 0c             	sub    $0xc,%esp
80103c5b:	50                   	push   %eax
80103c5c:	e8 77 0f 00 00       	call   80104bd8 <acquire>
80103c61:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103c64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c6b:	e9 ad 00 00 00       	jmp    80103d1d <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103c70:	8b 45 08             	mov    0x8(%ebp),%eax
80103c73:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c79:	85 c0                	test   %eax,%eax
80103c7b:	74 0c                	je     80103c89 <pipewrite+0x3b>
80103c7d:	e8 92 02 00 00       	call   80103f14 <myproc>
80103c82:	8b 40 24             	mov    0x24(%eax),%eax
80103c85:	85 c0                	test   %eax,%eax
80103c87:	74 19                	je     80103ca2 <pipewrite+0x54>
        release(&p->lock);
80103c89:	8b 45 08             	mov    0x8(%ebp),%eax
80103c8c:	83 ec 0c             	sub    $0xc,%esp
80103c8f:	50                   	push   %eax
80103c90:	e8 b1 0f 00 00       	call   80104c46 <release>
80103c95:	83 c4 10             	add    $0x10,%esp
        return -1;
80103c98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103c9d:	e9 a9 00 00 00       	jmp    80103d4b <pipewrite+0xfd>
      }
      wakeup(&p->nread);
80103ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ca5:	05 34 02 00 00       	add    $0x234,%eax
80103caa:	83 ec 0c             	sub    $0xc,%esp
80103cad:	50                   	push   %eax
80103cae:	e8 f1 0b 00 00       	call   801048a4 <wakeup>
80103cb3:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb9:	8b 55 08             	mov    0x8(%ebp),%edx
80103cbc:	81 c2 38 02 00 00    	add    $0x238,%edx
80103cc2:	83 ec 08             	sub    $0x8,%esp
80103cc5:	50                   	push   %eax
80103cc6:	52                   	push   %edx
80103cc7:	e8 f1 0a 00 00       	call   801047bd <sleep>
80103ccc:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd2:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103cdb:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103ce1:	05 00 02 00 00       	add    $0x200,%eax
80103ce6:	39 c2                	cmp    %eax,%edx
80103ce8:	74 86                	je     80103c70 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103cea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ced:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cf0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103cfc:	8d 48 01             	lea    0x1(%eax),%ecx
80103cff:	8b 55 08             	mov    0x8(%ebp),%edx
80103d02:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103d08:	25 ff 01 00 00       	and    $0x1ff,%eax
80103d0d:	89 c1                	mov    %eax,%ecx
80103d0f:	0f b6 13             	movzbl (%ebx),%edx
80103d12:	8b 45 08             	mov    0x8(%ebp),%eax
80103d15:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103d19:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d20:	3b 45 10             	cmp    0x10(%ebp),%eax
80103d23:	7c aa                	jl     80103ccf <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103d25:	8b 45 08             	mov    0x8(%ebp),%eax
80103d28:	05 34 02 00 00       	add    $0x234,%eax
80103d2d:	83 ec 0c             	sub    $0xc,%esp
80103d30:	50                   	push   %eax
80103d31:	e8 6e 0b 00 00       	call   801048a4 <wakeup>
80103d36:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103d39:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3c:	83 ec 0c             	sub    $0xc,%esp
80103d3f:	50                   	push   %eax
80103d40:	e8 01 0f 00 00       	call   80104c46 <release>
80103d45:	83 c4 10             	add    $0x10,%esp
  return n;
80103d48:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103d4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d4e:	c9                   	leave  
80103d4f:	c3                   	ret    

80103d50 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103d50:	55                   	push   %ebp
80103d51:	89 e5                	mov    %esp,%ebp
80103d53:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103d56:	8b 45 08             	mov    0x8(%ebp),%eax
80103d59:	83 ec 0c             	sub    $0xc,%esp
80103d5c:	50                   	push   %eax
80103d5d:	e8 76 0e 00 00       	call   80104bd8 <acquire>
80103d62:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103d65:	eb 3e                	jmp    80103da5 <piperead+0x55>
    if(myproc()->killed){
80103d67:	e8 a8 01 00 00       	call   80103f14 <myproc>
80103d6c:	8b 40 24             	mov    0x24(%eax),%eax
80103d6f:	85 c0                	test   %eax,%eax
80103d71:	74 19                	je     80103d8c <piperead+0x3c>
      release(&p->lock);
80103d73:	8b 45 08             	mov    0x8(%ebp),%eax
80103d76:	83 ec 0c             	sub    $0xc,%esp
80103d79:	50                   	push   %eax
80103d7a:	e8 c7 0e 00 00       	call   80104c46 <release>
80103d7f:	83 c4 10             	add    $0x10,%esp
      return -1;
80103d82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d87:	e9 be 00 00 00       	jmp    80103e4a <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8f:	8b 55 08             	mov    0x8(%ebp),%edx
80103d92:	81 c2 34 02 00 00    	add    $0x234,%edx
80103d98:	83 ec 08             	sub    $0x8,%esp
80103d9b:	50                   	push   %eax
80103d9c:	52                   	push   %edx
80103d9d:	e8 1b 0a 00 00       	call   801047bd <sleep>
80103da2:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103da5:	8b 45 08             	mov    0x8(%ebp),%eax
80103da8:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dae:	8b 45 08             	mov    0x8(%ebp),%eax
80103db1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103db7:	39 c2                	cmp    %eax,%edx
80103db9:	75 0d                	jne    80103dc8 <piperead+0x78>
80103dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbe:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103dc4:	85 c0                	test   %eax,%eax
80103dc6:	75 9f                	jne    80103d67 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103dc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dcf:	eb 48                	jmp    80103e19 <piperead+0xc9>
    if(p->nread == p->nwrite)
80103dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dda:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103de3:	39 c2                	cmp    %eax,%edx
80103de5:	74 3c                	je     80103e23 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103de7:	8b 45 08             	mov    0x8(%ebp),%eax
80103dea:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103df0:	8d 48 01             	lea    0x1(%eax),%ecx
80103df3:	8b 55 08             	mov    0x8(%ebp),%edx
80103df6:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103dfc:	25 ff 01 00 00       	and    $0x1ff,%eax
80103e01:	89 c1                	mov    %eax,%ecx
80103e03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e09:	01 c2                	add    %eax,%edx
80103e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e0e:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103e13:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103e15:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1c:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e1f:	7c b0                	jl     80103dd1 <piperead+0x81>
80103e21:	eb 01                	jmp    80103e24 <piperead+0xd4>
      break;
80103e23:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103e24:	8b 45 08             	mov    0x8(%ebp),%eax
80103e27:	05 38 02 00 00       	add    $0x238,%eax
80103e2c:	83 ec 0c             	sub    $0xc,%esp
80103e2f:	50                   	push   %eax
80103e30:	e8 6f 0a 00 00       	call   801048a4 <wakeup>
80103e35:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103e38:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3b:	83 ec 0c             	sub    $0xc,%esp
80103e3e:	50                   	push   %eax
80103e3f:	e8 02 0e 00 00       	call   80104c46 <release>
80103e44:	83 c4 10             	add    $0x10,%esp
  return i;
80103e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103e4a:	c9                   	leave  
80103e4b:	c3                   	ret    

80103e4c <readeflags>:
{
80103e4c:	55                   	push   %ebp
80103e4d:	89 e5                	mov    %esp,%ebp
80103e4f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103e52:	9c                   	pushf  
80103e53:	58                   	pop    %eax
80103e54:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103e57:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103e5a:	c9                   	leave  
80103e5b:	c3                   	ret    

80103e5c <sti>:
{
80103e5c:	55                   	push   %ebp
80103e5d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103e5f:	fb                   	sti    
}
80103e60:	90                   	nop
80103e61:	5d                   	pop    %ebp
80103e62:	c3                   	ret    

80103e63 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103e63:	55                   	push   %ebp
80103e64:	89 e5                	mov    %esp,%ebp
80103e66:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103e69:	83 ec 08             	sub    $0x8,%esp
80103e6c:	68 74 a6 10 80       	push   $0x8010a674
80103e71:	68 40 72 11 80       	push   $0x80117240
80103e76:	e8 3b 0d 00 00       	call   80104bb6 <initlock>
80103e7b:	83 c4 10             	add    $0x10,%esp
}
80103e7e:	90                   	nop
80103e7f:	c9                   	leave  
80103e80:	c3                   	ret    

80103e81 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103e81:	55                   	push   %ebp
80103e82:	89 e5                	mov    %esp,%ebp
80103e84:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103e87:	e8 10 00 00 00       	call   80103e9c <mycpu>
80103e8c:	2d c0 9a 11 80       	sub    $0x80119ac0,%eax
80103e91:	c1 f8 04             	sar    $0x4,%eax
80103e94:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103e9a:	c9                   	leave  
80103e9b:	c3                   	ret    

80103e9c <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103e9c:	55                   	push   %ebp
80103e9d:	89 e5                	mov    %esp,%ebp
80103e9f:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103ea2:	e8 a5 ff ff ff       	call   80103e4c <readeflags>
80103ea7:	25 00 02 00 00       	and    $0x200,%eax
80103eac:	85 c0                	test   %eax,%eax
80103eae:	74 0d                	je     80103ebd <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80103eb0:	83 ec 0c             	sub    $0xc,%esp
80103eb3:	68 7c a6 10 80       	push   $0x8010a67c
80103eb8:	e8 ec c6 ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
80103ebd:	e8 1c f1 ff ff       	call   80102fde <lapicid>
80103ec2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103ec5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ecc:	eb 2d                	jmp    80103efb <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
80103ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ed7:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
80103edc:	0f b6 00             	movzbl (%eax),%eax
80103edf:	0f b6 c0             	movzbl %al,%eax
80103ee2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103ee5:	75 10                	jne    80103ef7 <mycpu+0x5b>
      return &cpus[i];
80103ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eea:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ef0:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
80103ef5:	eb 1b                	jmp    80103f12 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103ef7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103efb:	a1 80 9d 11 80       	mov    0x80119d80,%eax
80103f00:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103f03:	7c c9                	jl     80103ece <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103f05:	83 ec 0c             	sub    $0xc,%esp
80103f08:	68 a2 a6 10 80       	push   $0x8010a6a2
80103f0d:	e8 97 c6 ff ff       	call   801005a9 <panic>
}
80103f12:	c9                   	leave  
80103f13:	c3                   	ret    

80103f14 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103f14:	55                   	push   %ebp
80103f15:	89 e5                	mov    %esp,%ebp
80103f17:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();       // 인터럽트 막고
80103f1a:	e8 24 0e 00 00       	call   80104d43 <pushcli>
  c = mycpu();     // 현재 CPU의 구조체 포인터 가져오고
80103f1f:	e8 78 ff ff ff       	call   80103e9c <mycpu>
80103f24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;     // 현재 CPU가 실행 중인 프로세스 가져옴
80103f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f2a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103f30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();        // 인터럽트 다시 허용
80103f33:	e8 58 0e 00 00       	call   80104d90 <popcli>
  return p;
80103f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f3b:	c9                   	leave  
80103f3c:	c3                   	ret    

80103f3d <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103f3d:	55                   	push   %ebp
80103f3e:	89 e5                	mov    %esp,%ebp
80103f40:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103f43:	83 ec 0c             	sub    $0xc,%esp
80103f46:	68 40 72 11 80       	push   $0x80117240
80103f4b:	e8 88 0c 00 00       	call   80104bd8 <acquire>
80103f50:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f53:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80103f5a:	eb 0e                	jmp    80103f6a <allocproc+0x2d>
    if(p->state == UNUSED){
80103f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f5f:	8b 40 0c             	mov    0xc(%eax),%eax
80103f62:	85 c0                	test   %eax,%eax
80103f64:	74 27                	je     80103f8d <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f66:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103f6a:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80103f71:	72 e9                	jb     80103f5c <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103f73:	83 ec 0c             	sub    $0xc,%esp
80103f76:	68 40 72 11 80       	push   $0x80117240
80103f7b:	e8 c6 0c 00 00       	call   80104c46 <release>
80103f80:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f83:	b8 00 00 00 00       	mov    $0x0,%eax
80103f88:	e9 b2 00 00 00       	jmp    8010403f <allocproc+0x102>
      goto found;
80103f8d:	90                   	nop

found:
  p->state = EMBRYO;
80103f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f91:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103f98:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103f9d:	8d 50 01             	lea    0x1(%eax),%edx
80103fa0:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103fa6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fa9:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103fac:	83 ec 0c             	sub    $0xc,%esp
80103faf:	68 40 72 11 80       	push   $0x80117240
80103fb4:	e8 8d 0c 00 00       	call   80104c46 <release>
80103fb9:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103fbc:	e8 c3 ec ff ff       	call   80102c84 <kalloc>
80103fc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fc4:	89 42 08             	mov    %eax,0x8(%edx)
80103fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fca:	8b 40 08             	mov    0x8(%eax),%eax
80103fcd:	85 c0                	test   %eax,%eax
80103fcf:	75 11                	jne    80103fe2 <allocproc+0xa5>
    p->state = UNUSED;
80103fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103fdb:	b8 00 00 00 00       	mov    $0x0,%eax
80103fe0:	eb 5d                	jmp    8010403f <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe5:	8b 40 08             	mov    0x8(%eax),%eax
80103fe8:	05 00 10 00 00       	add    $0x1000,%eax
80103fed:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103ff0:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ffa:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103ffd:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104001:	ba 13 62 10 80       	mov    $0x80106213,%edx
80104006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104009:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010400b:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010400f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104012:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104015:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010401e:	83 ec 04             	sub    $0x4,%esp
80104021:	6a 14                	push   $0x14
80104023:	6a 00                	push   $0x0
80104025:	50                   	push   %eax
80104026:	e8 23 0e 00 00       	call   80104e4e <memset>
8010402b:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010402e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104031:	8b 40 1c             	mov    0x1c(%eax),%eax
80104034:	ba 77 47 10 80       	mov    $0x80104777,%edx
80104039:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010403c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010403f:	c9                   	leave  
80104040:	c3                   	ret    

80104041 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104041:	55                   	push   %ebp
80104042:	89 e5                	mov    %esp,%ebp
80104044:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104047:	e8 f1 fe ff ff       	call   80103f3d <allocproc>
8010404c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010404f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104052:	a3 74 92 11 80       	mov    %eax,0x80119274
  if((p->pgdir = setupkvm()) == 0){
80104057:	e8 0f 37 00 00       	call   8010776b <setupkvm>
8010405c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010405f:	89 42 04             	mov    %eax,0x4(%edx)
80104062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104065:	8b 40 04             	mov    0x4(%eax),%eax
80104068:	85 c0                	test   %eax,%eax
8010406a:	75 0d                	jne    80104079 <userinit+0x38>
    panic("userinit: out of memory?");
8010406c:	83 ec 0c             	sub    $0xc,%esp
8010406f:	68 b2 a6 10 80       	push   $0x8010a6b2
80104074:	e8 30 c5 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104079:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010407e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104081:	8b 40 04             	mov    0x4(%eax),%eax
80104084:	83 ec 04             	sub    $0x4,%esp
80104087:	52                   	push   %edx
80104088:	68 ec f4 10 80       	push   $0x8010f4ec
8010408d:	50                   	push   %eax
8010408e:	e8 94 39 00 00       	call   80107a27 <inituvm>
80104093:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104099:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010409f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a2:	8b 40 18             	mov    0x18(%eax),%eax
801040a5:	83 ec 04             	sub    $0x4,%esp
801040a8:	6a 4c                	push   $0x4c
801040aa:	6a 00                	push   $0x0
801040ac:	50                   	push   %eax
801040ad:	e8 9c 0d 00 00       	call   80104e4e <memset>
801040b2:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801040b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b8:	8b 40 18             	mov    0x18(%eax),%eax
801040bb:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801040c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c4:	8b 40 18             	mov    0x18(%eax),%eax
801040c7:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801040cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d0:	8b 50 18             	mov    0x18(%eax),%edx
801040d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d6:	8b 40 18             	mov    0x18(%eax),%eax
801040d9:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040dd:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801040e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e4:	8b 50 18             	mov    0x18(%eax),%edx
801040e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ea:	8b 40 18             	mov    0x18(%eax),%eax
801040ed:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040f1:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801040f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f8:	8b 40 18             	mov    0x18(%eax),%eax
801040fb:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104105:	8b 40 18             	mov    0x18(%eax),%eax
80104108:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010410f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104112:	8b 40 18             	mov    0x18(%eax),%eax
80104115:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010411c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411f:	83 c0 6c             	add    $0x6c,%eax
80104122:	83 ec 04             	sub    $0x4,%esp
80104125:	6a 10                	push   $0x10
80104127:	68 cb a6 10 80       	push   $0x8010a6cb
8010412c:	50                   	push   %eax
8010412d:	e8 1f 0f 00 00       	call   80105051 <safestrcpy>
80104132:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104135:	83 ec 0c             	sub    $0xc,%esp
80104138:	68 d4 a6 10 80       	push   $0x8010a6d4
8010413d:	e8 db e3 ff ff       	call   8010251d <namei>
80104142:	83 c4 10             	add    $0x10,%esp
80104145:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104148:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010414b:	83 ec 0c             	sub    $0xc,%esp
8010414e:	68 40 72 11 80       	push   $0x80117240
80104153:	e8 80 0a 00 00       	call   80104bd8 <acquire>
80104158:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
8010415b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104165:	83 ec 0c             	sub    $0xc,%esp
80104168:	68 40 72 11 80       	push   $0x80117240
8010416d:	e8 d4 0a 00 00       	call   80104c46 <release>
80104172:	83 c4 10             	add    $0x10,%esp
}
80104175:	90                   	nop
80104176:	c9                   	leave  
80104177:	c3                   	ret    

80104178 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104178:	55                   	push   %ebp
80104179:	89 e5                	mov    %esp,%ebp
8010417b:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010417e:	e8 91 fd ff ff       	call   80103f14 <myproc>
80104183:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104186:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104189:	8b 00                	mov    (%eax),%eax
8010418b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010418e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104192:	7e 2e                	jle    801041c2 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104194:	8b 55 08             	mov    0x8(%ebp),%edx
80104197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419a:	01 c2                	add    %eax,%edx
8010419c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010419f:	8b 40 04             	mov    0x4(%eax),%eax
801041a2:	83 ec 04             	sub    $0x4,%esp
801041a5:	52                   	push   %edx
801041a6:	ff 75 f4             	push   -0xc(%ebp)
801041a9:	50                   	push   %eax
801041aa:	e8 b5 39 00 00       	call   80107b64 <allocuvm>
801041af:	83 c4 10             	add    $0x10,%esp
801041b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041b9:	75 3b                	jne    801041f6 <growproc+0x7e>
      return -1;
801041bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041c0:	eb 4f                	jmp    80104211 <growproc+0x99>
  } else if(n < 0){
801041c2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801041c6:	79 2e                	jns    801041f6 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801041c8:	8b 55 08             	mov    0x8(%ebp),%edx
801041cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ce:	01 c2                	add    %eax,%edx
801041d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041d3:	8b 40 04             	mov    0x4(%eax),%eax
801041d6:	83 ec 04             	sub    $0x4,%esp
801041d9:	52                   	push   %edx
801041da:	ff 75 f4             	push   -0xc(%ebp)
801041dd:	50                   	push   %eax
801041de:	e8 86 3a 00 00       	call   80107c69 <deallocuvm>
801041e3:	83 c4 10             	add    $0x10,%esp
801041e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041ed:	75 07                	jne    801041f6 <growproc+0x7e>
      return -1;
801041ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041f4:	eb 1b                	jmp    80104211 <growproc+0x99>
  }
  curproc->sz = sz;
801041f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041fc:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801041fe:	83 ec 0c             	sub    $0xc,%esp
80104201:	ff 75 f0             	push   -0x10(%ebp)
80104204:	e8 7f 36 00 00       	call   80107888 <switchuvm>
80104209:	83 c4 10             	add    $0x10,%esp
  return 0;
8010420c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104211:	c9                   	leave  
80104212:	c3                   	ret    

80104213 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104213:	55                   	push   %ebp
80104214:	89 e5                	mov    %esp,%ebp
80104216:	57                   	push   %edi
80104217:	56                   	push   %esi
80104218:	53                   	push   %ebx
80104219:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010421c:	e8 f3 fc ff ff       	call   80103f14 <myproc>
80104221:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104224:	e8 14 fd ff ff       	call   80103f3d <allocproc>
80104229:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010422c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104230:	75 0a                	jne    8010423c <fork+0x29>
    return -1;
80104232:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104237:	e9 48 01 00 00       	jmp    80104384 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010423c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010423f:	8b 10                	mov    (%eax),%edx
80104241:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104244:	8b 40 04             	mov    0x4(%eax),%eax
80104247:	83 ec 08             	sub    $0x8,%esp
8010424a:	52                   	push   %edx
8010424b:	50                   	push   %eax
8010424c:	e8 b6 3b 00 00       	call   80107e07 <copyuvm>
80104251:	83 c4 10             	add    $0x10,%esp
80104254:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104257:	89 42 04             	mov    %eax,0x4(%edx)
8010425a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010425d:	8b 40 04             	mov    0x4(%eax),%eax
80104260:	85 c0                	test   %eax,%eax
80104262:	75 30                	jne    80104294 <fork+0x81>
    kfree(np->kstack);
80104264:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104267:	8b 40 08             	mov    0x8(%eax),%eax
8010426a:	83 ec 0c             	sub    $0xc,%esp
8010426d:	50                   	push   %eax
8010426e:	e8 77 e9 ff ff       	call   80102bea <kfree>
80104273:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104276:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104279:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104280:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104283:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010428a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010428f:	e9 f0 00 00 00       	jmp    80104384 <fork+0x171>
  }
  np->sz = curproc->sz;
80104294:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104297:	8b 10                	mov    (%eax),%edx
80104299:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010429c:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010429e:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801042a4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801042a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042aa:	8b 48 18             	mov    0x18(%eax),%ecx
801042ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042b0:	8b 40 18             	mov    0x18(%eax),%eax
801042b3:	89 c2                	mov    %eax,%edx
801042b5:	89 cb                	mov    %ecx,%ebx
801042b7:	b8 13 00 00 00       	mov    $0x13,%eax
801042bc:	89 d7                	mov    %edx,%edi
801042be:	89 de                	mov    %ebx,%esi
801042c0:	89 c1                	mov    %eax,%ecx
801042c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801042c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042c7:	8b 40 18             	mov    0x18(%eax),%eax
801042ca:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801042d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801042d8:	eb 3b                	jmp    80104315 <fork+0x102>
    if(curproc->ofile[i])
801042da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042e0:	83 c2 08             	add    $0x8,%edx
801042e3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042e7:	85 c0                	test   %eax,%eax
801042e9:	74 26                	je     80104311 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
801042eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042f1:	83 c2 08             	add    $0x8,%edx
801042f4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042f8:	83 ec 0c             	sub    $0xc,%esp
801042fb:	50                   	push   %eax
801042fc:	e8 49 cd ff ff       	call   8010104a <filedup>
80104301:	83 c4 10             	add    $0x10,%esp
80104304:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104307:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010430a:	83 c1 08             	add    $0x8,%ecx
8010430d:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104311:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104315:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104319:	7e bf                	jle    801042da <fork+0xc7>
  np->cwd = idup(curproc->cwd);
8010431b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010431e:	8b 40 68             	mov    0x68(%eax),%eax
80104321:	83 ec 0c             	sub    $0xc,%esp
80104324:	50                   	push   %eax
80104325:	e8 86 d6 ff ff       	call   801019b0 <idup>
8010432a:	83 c4 10             	add    $0x10,%esp
8010432d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104330:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104333:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104336:	8d 50 6c             	lea    0x6c(%eax),%edx
80104339:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010433c:	83 c0 6c             	add    $0x6c,%eax
8010433f:	83 ec 04             	sub    $0x4,%esp
80104342:	6a 10                	push   $0x10
80104344:	52                   	push   %edx
80104345:	50                   	push   %eax
80104346:	e8 06 0d 00 00       	call   80105051 <safestrcpy>
8010434b:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010434e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104351:	8b 40 10             	mov    0x10(%eax),%eax
80104354:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104357:	83 ec 0c             	sub    $0xc,%esp
8010435a:	68 40 72 11 80       	push   $0x80117240
8010435f:	e8 74 08 00 00       	call   80104bd8 <acquire>
80104364:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104367:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010436a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104371:	83 ec 0c             	sub    $0xc,%esp
80104374:	68 40 72 11 80       	push   $0x80117240
80104379:	e8 c8 08 00 00       	call   80104c46 <release>
8010437e:	83 c4 10             	add    $0x10,%esp

  return pid;
80104381:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104384:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104387:	5b                   	pop    %ebx
80104388:	5e                   	pop    %esi
80104389:	5f                   	pop    %edi
8010438a:	5d                   	pop    %ebp
8010438b:	c3                   	ret    

8010438c <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010438c:	55                   	push   %ebp
8010438d:	89 e5                	mov    %esp,%ebp
8010438f:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104392:	e8 7d fb ff ff       	call   80103f14 <myproc>
80104397:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010439a:	a1 74 92 11 80       	mov    0x80119274,%eax
8010439f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801043a2:	75 0d                	jne    801043b1 <exit+0x25>
    panic("init exiting");
801043a4:	83 ec 0c             	sub    $0xc,%esp
801043a7:	68 d6 a6 10 80       	push   $0x8010a6d6
801043ac:	e8 f8 c1 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801043b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801043b8:	eb 3f                	jmp    801043f9 <exit+0x6d>
    if(curproc->ofile[fd]){
801043ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043c0:	83 c2 08             	add    $0x8,%edx
801043c3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043c7:	85 c0                	test   %eax,%eax
801043c9:	74 2a                	je     801043f5 <exit+0x69>
      fileclose(curproc->ofile[fd]);
801043cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043d1:	83 c2 08             	add    $0x8,%edx
801043d4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043d8:	83 ec 0c             	sub    $0xc,%esp
801043db:	50                   	push   %eax
801043dc:	e8 ba cc ff ff       	call   8010109b <fileclose>
801043e1:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801043e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043ea:	83 c2 08             	add    $0x8,%edx
801043ed:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801043f4:	00 
  for(fd = 0; fd < NOFILE; fd++){
801043f5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801043f9:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801043fd:	7e bb                	jle    801043ba <exit+0x2e>
    }
  }

  begin_op();
801043ff:	e8 1c f1 ff ff       	call   80103520 <begin_op>
  iput(curproc->cwd);
80104404:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104407:	8b 40 68             	mov    0x68(%eax),%eax
8010440a:	83 ec 0c             	sub    $0xc,%esp
8010440d:	50                   	push   %eax
8010440e:	e8 38 d7 ff ff       	call   80101b4b <iput>
80104413:	83 c4 10             	add    $0x10,%esp
  end_op();
80104416:	e8 91 f1 ff ff       	call   801035ac <end_op>
  curproc->cwd = 0;
8010441b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010441e:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104425:	83 ec 0c             	sub    $0xc,%esp
80104428:	68 40 72 11 80       	push   $0x80117240
8010442d:	e8 a6 07 00 00       	call   80104bd8 <acquire>
80104432:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104435:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104438:	8b 40 14             	mov    0x14(%eax),%eax
8010443b:	83 ec 0c             	sub    $0xc,%esp
8010443e:	50                   	push   %eax
8010443f:	e8 20 04 00 00       	call   80104864 <wakeup1>
80104444:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104447:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
8010444e:	eb 37                	jmp    80104487 <exit+0xfb>
    if(p->parent == curproc){
80104450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104453:	8b 40 14             	mov    0x14(%eax),%eax
80104456:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104459:	75 28                	jne    80104483 <exit+0xf7>
      p->parent = initproc;
8010445b:	8b 15 74 92 11 80    	mov    0x80119274,%edx
80104461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104464:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104467:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446a:	8b 40 0c             	mov    0xc(%eax),%eax
8010446d:	83 f8 05             	cmp    $0x5,%eax
80104470:	75 11                	jne    80104483 <exit+0xf7>
        wakeup1(initproc);
80104472:	a1 74 92 11 80       	mov    0x80119274,%eax
80104477:	83 ec 0c             	sub    $0xc,%esp
8010447a:	50                   	push   %eax
8010447b:	e8 e4 03 00 00       	call   80104864 <wakeup1>
80104480:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104483:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104487:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
8010448e:	72 c0                	jb     80104450 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104490:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104493:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010449a:	e8 e5 01 00 00       	call   80104684 <sched>
  panic("zombie exit");
8010449f:	83 ec 0c             	sub    $0xc,%esp
801044a2:	68 e3 a6 10 80       	push   $0x8010a6e3
801044a7:	e8 fd c0 ff ff       	call   801005a9 <panic>

801044ac <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801044ac:	55                   	push   %ebp
801044ad:	89 e5                	mov    %esp,%ebp
801044af:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801044b2:	e8 5d fa ff ff       	call   80103f14 <myproc>
801044b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801044ba:	83 ec 0c             	sub    $0xc,%esp
801044bd:	68 40 72 11 80       	push   $0x80117240
801044c2:	e8 11 07 00 00       	call   80104bd8 <acquire>
801044c7:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801044ca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044d1:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801044d8:	e9 a1 00 00 00       	jmp    8010457e <wait+0xd2>
      if(p->parent != curproc)
801044dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e0:	8b 40 14             	mov    0x14(%eax),%eax
801044e3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801044e6:	0f 85 8d 00 00 00    	jne    80104579 <wait+0xcd>
        continue;
      havekids = 1;
801044ec:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801044f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f6:	8b 40 0c             	mov    0xc(%eax),%eax
801044f9:	83 f8 05             	cmp    $0x5,%eax
801044fc:	75 7c                	jne    8010457a <wait+0xce>
        // Found one.
        pid = p->pid;
801044fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104501:	8b 40 10             	mov    0x10(%eax),%eax
80104504:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450a:	8b 40 08             	mov    0x8(%eax),%eax
8010450d:	83 ec 0c             	sub    $0xc,%esp
80104510:	50                   	push   %eax
80104511:	e8 d4 e6 ff ff       	call   80102bea <kfree>
80104516:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104526:	8b 40 04             	mov    0x4(%eax),%eax
80104529:	83 ec 0c             	sub    $0xc,%esp
8010452c:	50                   	push   %eax
8010452d:	e8 fb 37 00 00       	call   80107d2d <freevm>
80104532:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104538:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010453f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104542:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454c:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104553:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010455a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104564:	83 ec 0c             	sub    $0xc,%esp
80104567:	68 40 72 11 80       	push   $0x80117240
8010456c:	e8 d5 06 00 00       	call   80104c46 <release>
80104571:	83 c4 10             	add    $0x10,%esp
        return pid;
80104574:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104577:	eb 51                	jmp    801045ca <wait+0x11e>
        continue;
80104579:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010457a:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010457e:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80104585:	0f 82 52 ff ff ff    	jb     801044dd <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010458b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010458f:	74 0a                	je     8010459b <wait+0xef>
80104591:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104594:	8b 40 24             	mov    0x24(%eax),%eax
80104597:	85 c0                	test   %eax,%eax
80104599:	74 17                	je     801045b2 <wait+0x106>
      release(&ptable.lock);
8010459b:	83 ec 0c             	sub    $0xc,%esp
8010459e:	68 40 72 11 80       	push   $0x80117240
801045a3:	e8 9e 06 00 00       	call   80104c46 <release>
801045a8:	83 c4 10             	add    $0x10,%esp
      return -1;
801045ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b0:	eb 18                	jmp    801045ca <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801045b2:	83 ec 08             	sub    $0x8,%esp
801045b5:	68 40 72 11 80       	push   $0x80117240
801045ba:	ff 75 ec             	push   -0x14(%ebp)
801045bd:	e8 fb 01 00 00       	call   801047bd <sleep>
801045c2:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801045c5:	e9 00 ff ff ff       	jmp    801044ca <wait+0x1e>
  }
}
801045ca:	c9                   	leave  
801045cb:	c3                   	ret    

801045cc <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801045cc:	55                   	push   %ebp
801045cd:	89 e5                	mov    %esp,%ebp
801045cf:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801045d2:	e8 c5 f8 ff ff       	call   80103e9c <mycpu>
801045d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801045da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045dd:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801045e4:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801045e7:	e8 70 f8 ff ff       	call   80103e5c <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801045ec:	83 ec 0c             	sub    $0xc,%esp
801045ef:	68 40 72 11 80       	push   $0x80117240
801045f4:	e8 df 05 00 00       	call   80104bd8 <acquire>
801045f9:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045fc:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104603:	eb 61                	jmp    80104666 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104608:	8b 40 0c             	mov    0xc(%eax),%eax
8010460b:	83 f8 03             	cmp    $0x3,%eax
8010460e:	75 51                	jne    80104661 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104613:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104616:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
8010461c:	83 ec 0c             	sub    $0xc,%esp
8010461f:	ff 75 f4             	push   -0xc(%ebp)
80104622:	e8 61 32 00 00       	call   80107888 <switchuvm>
80104627:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010462a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462d:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104637:	8b 40 1c             	mov    0x1c(%eax),%eax
8010463a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010463d:	83 c2 04             	add    $0x4,%edx
80104640:	83 ec 08             	sub    $0x8,%esp
80104643:	50                   	push   %eax
80104644:	52                   	push   %edx
80104645:	e8 79 0a 00 00       	call   801050c3 <swtch>
8010464a:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010464d:	e8 1d 32 00 00       	call   8010786f <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104652:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104655:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010465c:	00 00 00 
8010465f:	eb 01                	jmp    80104662 <scheduler+0x96>
        continue;
80104661:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104662:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104666:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
8010466d:	72 96                	jb     80104605 <scheduler+0x39>
    }
    release(&ptable.lock);
8010466f:	83 ec 0c             	sub    $0xc,%esp
80104672:	68 40 72 11 80       	push   $0x80117240
80104677:	e8 ca 05 00 00       	call   80104c46 <release>
8010467c:	83 c4 10             	add    $0x10,%esp
    sti();
8010467f:	e9 63 ff ff ff       	jmp    801045e7 <scheduler+0x1b>

80104684 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104684:	55                   	push   %ebp
80104685:	89 e5                	mov    %esp,%ebp
80104687:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010468a:	e8 85 f8 ff ff       	call   80103f14 <myproc>
8010468f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104692:	83 ec 0c             	sub    $0xc,%esp
80104695:	68 40 72 11 80       	push   $0x80117240
8010469a:	e8 74 06 00 00       	call   80104d13 <holding>
8010469f:	83 c4 10             	add    $0x10,%esp
801046a2:	85 c0                	test   %eax,%eax
801046a4:	75 0d                	jne    801046b3 <sched+0x2f>
    panic("sched ptable.lock");
801046a6:	83 ec 0c             	sub    $0xc,%esp
801046a9:	68 ef a6 10 80       	push   $0x8010a6ef
801046ae:	e8 f6 be ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801046b3:	e8 e4 f7 ff ff       	call   80103e9c <mycpu>
801046b8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801046be:	83 f8 01             	cmp    $0x1,%eax
801046c1:	74 0d                	je     801046d0 <sched+0x4c>
    panic("sched locks");
801046c3:	83 ec 0c             	sub    $0xc,%esp
801046c6:	68 01 a7 10 80       	push   $0x8010a701
801046cb:	e8 d9 be ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d3:	8b 40 0c             	mov    0xc(%eax),%eax
801046d6:	83 f8 04             	cmp    $0x4,%eax
801046d9:	75 0d                	jne    801046e8 <sched+0x64>
    panic("sched running");
801046db:	83 ec 0c             	sub    $0xc,%esp
801046de:	68 0d a7 10 80       	push   $0x8010a70d
801046e3:	e8 c1 be ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801046e8:	e8 5f f7 ff ff       	call   80103e4c <readeflags>
801046ed:	25 00 02 00 00       	and    $0x200,%eax
801046f2:	85 c0                	test   %eax,%eax
801046f4:	74 0d                	je     80104703 <sched+0x7f>
    panic("sched interruptible");
801046f6:	83 ec 0c             	sub    $0xc,%esp
801046f9:	68 1b a7 10 80       	push   $0x8010a71b
801046fe:	e8 a6 be ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104703:	e8 94 f7 ff ff       	call   80103e9c <mycpu>
80104708:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010470e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104711:	e8 86 f7 ff ff       	call   80103e9c <mycpu>
80104716:	8b 40 04             	mov    0x4(%eax),%eax
80104719:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010471c:	83 c2 1c             	add    $0x1c,%edx
8010471f:	83 ec 08             	sub    $0x8,%esp
80104722:	50                   	push   %eax
80104723:	52                   	push   %edx
80104724:	e8 9a 09 00 00       	call   801050c3 <swtch>
80104729:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010472c:	e8 6b f7 ff ff       	call   80103e9c <mycpu>
80104731:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104734:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
8010473a:	90                   	nop
8010473b:	c9                   	leave  
8010473c:	c3                   	ret    

8010473d <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010473d:	55                   	push   %ebp
8010473e:	89 e5                	mov    %esp,%ebp
80104740:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104743:	83 ec 0c             	sub    $0xc,%esp
80104746:	68 40 72 11 80       	push   $0x80117240
8010474b:	e8 88 04 00 00       	call   80104bd8 <acquire>
80104750:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104753:	e8 bc f7 ff ff       	call   80103f14 <myproc>
80104758:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010475f:	e8 20 ff ff ff       	call   80104684 <sched>
  release(&ptable.lock);
80104764:	83 ec 0c             	sub    $0xc,%esp
80104767:	68 40 72 11 80       	push   $0x80117240
8010476c:	e8 d5 04 00 00       	call   80104c46 <release>
80104771:	83 c4 10             	add    $0x10,%esp
}
80104774:	90                   	nop
80104775:	c9                   	leave  
80104776:	c3                   	ret    

80104777 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104777:	55                   	push   %ebp
80104778:	89 e5                	mov    %esp,%ebp
8010477a:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010477d:	83 ec 0c             	sub    $0xc,%esp
80104780:	68 40 72 11 80       	push   $0x80117240
80104785:	e8 bc 04 00 00       	call   80104c46 <release>
8010478a:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010478d:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104792:	85 c0                	test   %eax,%eax
80104794:	74 24                	je     801047ba <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104796:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010479d:	00 00 00 
    iinit(ROOTDEV);
801047a0:	83 ec 0c             	sub    $0xc,%esp
801047a3:	6a 01                	push   $0x1
801047a5:	e8 ce ce ff ff       	call   80101678 <iinit>
801047aa:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801047ad:	83 ec 0c             	sub    $0xc,%esp
801047b0:	6a 01                	push   $0x1
801047b2:	e8 4a eb ff ff       	call   80103301 <initlog>
801047b7:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801047ba:	90                   	nop
801047bb:	c9                   	leave  
801047bc:	c3                   	ret    

801047bd <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801047bd:	55                   	push   %ebp
801047be:	89 e5                	mov    %esp,%ebp
801047c0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801047c3:	e8 4c f7 ff ff       	call   80103f14 <myproc>
801047c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801047cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047cf:	75 0d                	jne    801047de <sleep+0x21>
    panic("sleep");
801047d1:	83 ec 0c             	sub    $0xc,%esp
801047d4:	68 2f a7 10 80       	push   $0x8010a72f
801047d9:	e8 cb bd ff ff       	call   801005a9 <panic>

  if(lk == 0)
801047de:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801047e2:	75 0d                	jne    801047f1 <sleep+0x34>
    panic("sleep without lk");
801047e4:	83 ec 0c             	sub    $0xc,%esp
801047e7:	68 35 a7 10 80       	push   $0x8010a735
801047ec:	e8 b8 bd ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801047f1:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
801047f8:	74 1e                	je     80104818 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
801047fa:	83 ec 0c             	sub    $0xc,%esp
801047fd:	68 40 72 11 80       	push   $0x80117240
80104802:	e8 d1 03 00 00       	call   80104bd8 <acquire>
80104807:	83 c4 10             	add    $0x10,%esp
    release(lk);
8010480a:	83 ec 0c             	sub    $0xc,%esp
8010480d:	ff 75 0c             	push   0xc(%ebp)
80104810:	e8 31 04 00 00       	call   80104c46 <release>
80104815:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481b:	8b 55 08             	mov    0x8(%ebp),%edx
8010481e:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104824:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010482b:	e8 54 fe ff ff       	call   80104684 <sched>

  // Tidy up.
  p->chan = 0;
80104830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104833:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010483a:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104841:	74 1e                	je     80104861 <sleep+0xa4>
    release(&ptable.lock);
80104843:	83 ec 0c             	sub    $0xc,%esp
80104846:	68 40 72 11 80       	push   $0x80117240
8010484b:	e8 f6 03 00 00       	call   80104c46 <release>
80104850:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104853:	83 ec 0c             	sub    $0xc,%esp
80104856:	ff 75 0c             	push   0xc(%ebp)
80104859:	e8 7a 03 00 00       	call   80104bd8 <acquire>
8010485e:	83 c4 10             	add    $0x10,%esp
  }
}
80104861:	90                   	nop
80104862:	c9                   	leave  
80104863:	c3                   	ret    

80104864 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104864:	55                   	push   %ebp
80104865:	89 e5                	mov    %esp,%ebp
80104867:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010486a:	c7 45 fc 74 72 11 80 	movl   $0x80117274,-0x4(%ebp)
80104871:	eb 24                	jmp    80104897 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104873:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104876:	8b 40 0c             	mov    0xc(%eax),%eax
80104879:	83 f8 02             	cmp    $0x2,%eax
8010487c:	75 15                	jne    80104893 <wakeup1+0x2f>
8010487e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104881:	8b 40 20             	mov    0x20(%eax),%eax
80104884:	39 45 08             	cmp    %eax,0x8(%ebp)
80104887:	75 0a                	jne    80104893 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104889:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010488c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104893:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104897:	81 7d fc 74 92 11 80 	cmpl   $0x80119274,-0x4(%ebp)
8010489e:	72 d3                	jb     80104873 <wakeup1+0xf>
}
801048a0:	90                   	nop
801048a1:	90                   	nop
801048a2:	c9                   	leave  
801048a3:	c3                   	ret    

801048a4 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801048a4:	55                   	push   %ebp
801048a5:	89 e5                	mov    %esp,%ebp
801048a7:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801048aa:	83 ec 0c             	sub    $0xc,%esp
801048ad:	68 40 72 11 80       	push   $0x80117240
801048b2:	e8 21 03 00 00       	call   80104bd8 <acquire>
801048b7:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801048ba:	83 ec 0c             	sub    $0xc,%esp
801048bd:	ff 75 08             	push   0x8(%ebp)
801048c0:	e8 9f ff ff ff       	call   80104864 <wakeup1>
801048c5:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801048c8:	83 ec 0c             	sub    $0xc,%esp
801048cb:	68 40 72 11 80       	push   $0x80117240
801048d0:	e8 71 03 00 00       	call   80104c46 <release>
801048d5:	83 c4 10             	add    $0x10,%esp
}
801048d8:	90                   	nop
801048d9:	c9                   	leave  
801048da:	c3                   	ret    

801048db <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801048db:	55                   	push   %ebp
801048dc:	89 e5                	mov    %esp,%ebp
801048de:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801048e1:	83 ec 0c             	sub    $0xc,%esp
801048e4:	68 40 72 11 80       	push   $0x80117240
801048e9:	e8 ea 02 00 00       	call   80104bd8 <acquire>
801048ee:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048f1:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801048f8:	eb 45                	jmp    8010493f <kill+0x64>
    if(p->pid == pid){
801048fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fd:	8b 40 10             	mov    0x10(%eax),%eax
80104900:	39 45 08             	cmp    %eax,0x8(%ebp)
80104903:	75 36                	jne    8010493b <kill+0x60>
      p->killed = 1;
80104905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104908:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010490f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104912:	8b 40 0c             	mov    0xc(%eax),%eax
80104915:	83 f8 02             	cmp    $0x2,%eax
80104918:	75 0a                	jne    80104924 <kill+0x49>
        p->state = RUNNABLE;
8010491a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104924:	83 ec 0c             	sub    $0xc,%esp
80104927:	68 40 72 11 80       	push   $0x80117240
8010492c:	e8 15 03 00 00       	call   80104c46 <release>
80104931:	83 c4 10             	add    $0x10,%esp
      return 0;
80104934:	b8 00 00 00 00       	mov    $0x0,%eax
80104939:	eb 22                	jmp    8010495d <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010493b:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010493f:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80104946:	72 b2                	jb     801048fa <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104948:	83 ec 0c             	sub    $0xc,%esp
8010494b:	68 40 72 11 80       	push   $0x80117240
80104950:	e8 f1 02 00 00       	call   80104c46 <release>
80104955:	83 c4 10             	add    $0x10,%esp
  return -1;
80104958:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010495d:	c9                   	leave  
8010495e:	c3                   	ret    

8010495f <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010495f:	55                   	push   %ebp
80104960:	89 e5                	mov    %esp,%ebp
80104962:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104965:	c7 45 f0 74 72 11 80 	movl   $0x80117274,-0x10(%ebp)
8010496c:	e9 d7 00 00 00       	jmp    80104a48 <procdump+0xe9>
    if(p->state == UNUSED)
80104971:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104974:	8b 40 0c             	mov    0xc(%eax),%eax
80104977:	85 c0                	test   %eax,%eax
80104979:	0f 84 c4 00 00 00    	je     80104a43 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010497f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104982:	8b 40 0c             	mov    0xc(%eax),%eax
80104985:	83 f8 05             	cmp    $0x5,%eax
80104988:	77 23                	ja     801049ad <procdump+0x4e>
8010498a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010498d:	8b 40 0c             	mov    0xc(%eax),%eax
80104990:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104997:	85 c0                	test   %eax,%eax
80104999:	74 12                	je     801049ad <procdump+0x4e>
      state = states[p->state];
8010499b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010499e:	8b 40 0c             	mov    0xc(%eax),%eax
801049a1:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801049a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801049ab:	eb 07                	jmp    801049b4 <procdump+0x55>
    else
      state = "???";
801049ad:	c7 45 ec 46 a7 10 80 	movl   $0x8010a746,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801049b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049b7:	8d 50 6c             	lea    0x6c(%eax),%edx
801049ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049bd:	8b 40 10             	mov    0x10(%eax),%eax
801049c0:	52                   	push   %edx
801049c1:	ff 75 ec             	push   -0x14(%ebp)
801049c4:	50                   	push   %eax
801049c5:	68 4a a7 10 80       	push   $0x8010a74a
801049ca:	e8 25 ba ff ff       	call   801003f4 <cprintf>
801049cf:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801049d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049d5:	8b 40 0c             	mov    0xc(%eax),%eax
801049d8:	83 f8 02             	cmp    $0x2,%eax
801049db:	75 54                	jne    80104a31 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801049dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049e0:	8b 40 1c             	mov    0x1c(%eax),%eax
801049e3:	8b 40 0c             	mov    0xc(%eax),%eax
801049e6:	83 c0 08             	add    $0x8,%eax
801049e9:	89 c2                	mov    %eax,%edx
801049eb:	83 ec 08             	sub    $0x8,%esp
801049ee:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801049f1:	50                   	push   %eax
801049f2:	52                   	push   %edx
801049f3:	e8 a0 02 00 00       	call   80104c98 <getcallerpcs>
801049f8:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801049fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a02:	eb 1c                	jmp    80104a20 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a07:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a0b:	83 ec 08             	sub    $0x8,%esp
80104a0e:	50                   	push   %eax
80104a0f:	68 53 a7 10 80       	push   $0x8010a753
80104a14:	e8 db b9 ff ff       	call   801003f4 <cprintf>
80104a19:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104a1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a20:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104a24:	7f 0b                	jg     80104a31 <procdump+0xd2>
80104a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a29:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a2d:	85 c0                	test   %eax,%eax
80104a2f:	75 d3                	jne    80104a04 <procdump+0xa5>
    }
    cprintf("\n");
80104a31:	83 ec 0c             	sub    $0xc,%esp
80104a34:	68 57 a7 10 80       	push   $0x8010a757
80104a39:	e8 b6 b9 ff ff       	call   801003f4 <cprintf>
80104a3e:	83 c4 10             	add    $0x10,%esp
80104a41:	eb 01                	jmp    80104a44 <procdump+0xe5>
      continue;
80104a43:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a44:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104a48:	81 7d f0 74 92 11 80 	cmpl   $0x80119274,-0x10(%ebp)
80104a4f:	0f 82 1c ff ff ff    	jb     80104971 <procdump+0x12>
  }
}
80104a55:	90                   	nop
80104a56:	90                   	nop
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
80104a68:	68 83 a7 10 80       	push   $0x8010a783
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
80104abc:	e8 fc fc ff ff       	call   801047bd <sleep>
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
80104ad6:	e8 39 f4 ff ff       	call   80103f14 <myproc>
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
80104b2a:	e8 75 fd ff ff       	call   801048a4 <wakeup>
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
80104bfa:	68 8e a7 10 80       	push   $0x8010a78e
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
80104c22:	e8 75 f2 ff ff       	call   80103e9c <mycpu>
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
80104c61:	68 96 a7 10 80       	push   $0x8010a796
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
80104d29:	e8 6e f1 ff ff       	call   80103e9c <mycpu>
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
80104d56:	e8 41 f1 ff ff       	call   80103e9c <mycpu>
80104d5b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d61:	85 c0                	test   %eax,%eax
80104d63:	75 14                	jne    80104d79 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104d65:	e8 32 f1 ff ff       	call   80103e9c <mycpu>
80104d6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d6d:	81 e2 00 02 00 00    	and    $0x200,%edx
80104d73:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104d79:	e8 1e f1 ff ff       	call   80103e9c <mycpu>
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
80104da7:	68 9e a7 10 80       	push   $0x8010a79e
80104dac:	e8 f8 b7 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104db1:	e8 e6 f0 ff ff       	call   80103e9c <mycpu>
80104db6:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104dbc:	83 ea 01             	sub    $0x1,%edx
80104dbf:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104dc5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104dcb:	85 c0                	test   %eax,%eax
80104dcd:	79 0d                	jns    80104ddc <popcli+0x4c>
    panic("popcli");
80104dcf:	83 ec 0c             	sub    $0xc,%esp
80104dd2:	68 b5 a7 10 80       	push   $0x8010a7b5
80104dd7:	e8 cd b7 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104ddc:	e8 bb f0 ff ff       	call   80103e9c <mycpu>
80104de1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104de7:	85 c0                	test   %eax,%eax
80104de9:	75 14                	jne    80104dff <popcli+0x6f>
80104deb:	e8 ac f0 ff ff       	call   80103e9c <mycpu>
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
801050db:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801050de:	e8 31 ee ff ff       	call   80103f14 <myproc>
801050e3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801050e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e9:	8b 00                	mov    (%eax),%eax
801050eb:	39 45 08             	cmp    %eax,0x8(%ebp)
801050ee:	73 0f                	jae    801050ff <fetchint+0x27>
801050f0:	8b 45 08             	mov    0x8(%ebp),%eax
801050f3:	8d 50 04             	lea    0x4(%eax),%edx
801050f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f9:	8b 00                	mov    (%eax),%eax
801050fb:	39 c2                	cmp    %eax,%edx
801050fd:	76 07                	jbe    80105106 <fetchint+0x2e>
    return -1;
801050ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105104:	eb 0f                	jmp    80105115 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105106:	8b 45 08             	mov    0x8(%ebp),%eax
80105109:	8b 10                	mov    (%eax),%edx
8010510b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010510e:	89 10                	mov    %edx,(%eax)
  return 0;
80105110:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105115:	c9                   	leave  
80105116:	c3                   	ret    

80105117 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105117:	55                   	push   %ebp
80105118:	89 e5                	mov    %esp,%ebp
8010511a:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010511d:	e8 f2 ed ff ff       	call   80103f14 <myproc>
80105122:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105125:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105128:	8b 00                	mov    (%eax),%eax
8010512a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010512d:	72 07                	jb     80105136 <fetchstr+0x1f>
    return -1;
8010512f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105134:	eb 41                	jmp    80105177 <fetchstr+0x60>
  *pp = (char*)addr;
80105136:	8b 55 08             	mov    0x8(%ebp),%edx
80105139:	8b 45 0c             	mov    0xc(%ebp),%eax
8010513c:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010513e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105141:	8b 00                	mov    (%eax),%eax
80105143:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105146:	8b 45 0c             	mov    0xc(%ebp),%eax
80105149:	8b 00                	mov    (%eax),%eax
8010514b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010514e:	eb 1a                	jmp    8010516a <fetchstr+0x53>
    if(*s == 0)
80105150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105153:	0f b6 00             	movzbl (%eax),%eax
80105156:	84 c0                	test   %al,%al
80105158:	75 0c                	jne    80105166 <fetchstr+0x4f>
      return s - *pp;
8010515a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010515d:	8b 10                	mov    (%eax),%edx
8010515f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105162:	29 d0                	sub    %edx,%eax
80105164:	eb 11                	jmp    80105177 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80105166:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010516a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105170:	72 de                	jb     80105150 <fetchstr+0x39>
  }
  return -1;
80105172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105177:	c9                   	leave  
80105178:	c3                   	ret    

80105179 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105179:	55                   	push   %ebp
8010517a:	89 e5                	mov    %esp,%ebp
8010517c:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010517f:	e8 90 ed ff ff       	call   80103f14 <myproc>
80105184:	8b 40 18             	mov    0x18(%eax),%eax
80105187:	8b 50 44             	mov    0x44(%eax),%edx
8010518a:	8b 45 08             	mov    0x8(%ebp),%eax
8010518d:	c1 e0 02             	shl    $0x2,%eax
80105190:	01 d0                	add    %edx,%eax
80105192:	83 c0 04             	add    $0x4,%eax
80105195:	83 ec 08             	sub    $0x8,%esp
80105198:	ff 75 0c             	push   0xc(%ebp)
8010519b:	50                   	push   %eax
8010519c:	e8 37 ff ff ff       	call   801050d8 <fetchint>
801051a1:	83 c4 10             	add    $0x10,%esp
}
801051a4:	c9                   	leave  
801051a5:	c3                   	ret    

801051a6 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801051a6:	55                   	push   %ebp
801051a7:	89 e5                	mov    %esp,%ebp
801051a9:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801051ac:	e8 63 ed ff ff       	call   80103f14 <myproc>
801051b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801051b4:	83 ec 08             	sub    $0x8,%esp
801051b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051ba:	50                   	push   %eax
801051bb:	ff 75 08             	push   0x8(%ebp)
801051be:	e8 b6 ff ff ff       	call   80105179 <argint>
801051c3:	83 c4 10             	add    $0x10,%esp
801051c6:	85 c0                	test   %eax,%eax
801051c8:	79 07                	jns    801051d1 <argptr+0x2b>
    return -1;
801051ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051cf:	eb 3b                	jmp    8010520c <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801051d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051d5:	78 1f                	js     801051f6 <argptr+0x50>
801051d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051da:	8b 00                	mov    (%eax),%eax
801051dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051df:	39 d0                	cmp    %edx,%eax
801051e1:	76 13                	jbe    801051f6 <argptr+0x50>
801051e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051e6:	89 c2                	mov    %eax,%edx
801051e8:	8b 45 10             	mov    0x10(%ebp),%eax
801051eb:	01 c2                	add    %eax,%edx
801051ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f0:	8b 00                	mov    (%eax),%eax
801051f2:	39 c2                	cmp    %eax,%edx
801051f4:	76 07                	jbe    801051fd <argptr+0x57>
    return -1;
801051f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051fb:	eb 0f                	jmp    8010520c <argptr+0x66>
  *pp = (char*)i;
801051fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105200:	89 c2                	mov    %eax,%edx
80105202:	8b 45 0c             	mov    0xc(%ebp),%eax
80105205:	89 10                	mov    %edx,(%eax)
  return 0;
80105207:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010520c:	c9                   	leave  
8010520d:	c3                   	ret    

8010520e <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010520e:	55                   	push   %ebp
8010520f:	89 e5                	mov    %esp,%ebp
80105211:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105214:	83 ec 08             	sub    $0x8,%esp
80105217:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010521a:	50                   	push   %eax
8010521b:	ff 75 08             	push   0x8(%ebp)
8010521e:	e8 56 ff ff ff       	call   80105179 <argint>
80105223:	83 c4 10             	add    $0x10,%esp
80105226:	85 c0                	test   %eax,%eax
80105228:	79 07                	jns    80105231 <argstr+0x23>
    return -1;
8010522a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010522f:	eb 12                	jmp    80105243 <argstr+0x35>
  return fetchstr(addr, pp);
80105231:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105234:	83 ec 08             	sub    $0x8,%esp
80105237:	ff 75 0c             	push   0xc(%ebp)
8010523a:	50                   	push   %eax
8010523b:	e8 d7 fe ff ff       	call   80105117 <fetchstr>
80105240:	83 c4 10             	add    $0x10,%esp
}
80105243:	c9                   	leave  
80105244:	c3                   	ret    

80105245 <syscall>:
[SYS_uthread_init] sys_uthread_init,
};

void
syscall(void)
{
80105245:	55                   	push   %ebp
80105246:	89 e5                	mov    %esp,%ebp
80105248:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
8010524b:	e8 c4 ec ff ff       	call   80103f14 <myproc>
80105250:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105253:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105256:	8b 40 18             	mov    0x18(%eax),%eax
80105259:	8b 40 1c             	mov    0x1c(%eax),%eax
8010525c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010525f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105263:	7e 2f                	jle    80105294 <syscall+0x4f>
80105265:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105268:	83 f8 16             	cmp    $0x16,%eax
8010526b:	77 27                	ja     80105294 <syscall+0x4f>
8010526d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105270:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105277:	85 c0                	test   %eax,%eax
80105279:	74 19                	je     80105294 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
8010527b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010527e:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105285:	ff d0                	call   *%eax
80105287:	89 c2                	mov    %eax,%edx
80105289:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010528c:	8b 40 18             	mov    0x18(%eax),%eax
8010528f:	89 50 1c             	mov    %edx,0x1c(%eax)
80105292:	eb 2c                	jmp    801052c0 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105294:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105297:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010529a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529d:	8b 40 10             	mov    0x10(%eax),%eax
801052a0:	ff 75 f0             	push   -0x10(%ebp)
801052a3:	52                   	push   %edx
801052a4:	50                   	push   %eax
801052a5:	68 bc a7 10 80       	push   $0x8010a7bc
801052aa:	e8 45 b1 ff ff       	call   801003f4 <cprintf>
801052af:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801052b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b5:	8b 40 18             	mov    0x18(%eax),%eax
801052b8:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801052bf:	90                   	nop
801052c0:	90                   	nop
801052c1:	c9                   	leave  
801052c2:	c3                   	ret    

801052c3 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801052c3:	55                   	push   %ebp
801052c4:	89 e5                	mov    %esp,%ebp
801052c6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801052c9:	83 ec 08             	sub    $0x8,%esp
801052cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052cf:	50                   	push   %eax
801052d0:	ff 75 08             	push   0x8(%ebp)
801052d3:	e8 a1 fe ff ff       	call   80105179 <argint>
801052d8:	83 c4 10             	add    $0x10,%esp
801052db:	85 c0                	test   %eax,%eax
801052dd:	79 07                	jns    801052e6 <argfd+0x23>
    return -1;
801052df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052e4:	eb 4f                	jmp    80105335 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801052e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052e9:	85 c0                	test   %eax,%eax
801052eb:	78 20                	js     8010530d <argfd+0x4a>
801052ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052f0:	83 f8 0f             	cmp    $0xf,%eax
801052f3:	7f 18                	jg     8010530d <argfd+0x4a>
801052f5:	e8 1a ec ff ff       	call   80103f14 <myproc>
801052fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052fd:	83 c2 08             	add    $0x8,%edx
80105300:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105304:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105307:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010530b:	75 07                	jne    80105314 <argfd+0x51>
    return -1;
8010530d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105312:	eb 21                	jmp    80105335 <argfd+0x72>
  if(pfd)
80105314:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105318:	74 08                	je     80105322 <argfd+0x5f>
    *pfd = fd;
8010531a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010531d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105320:	89 10                	mov    %edx,(%eax)
  if(pf)
80105322:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105326:	74 08                	je     80105330 <argfd+0x6d>
    *pf = f;
80105328:	8b 45 10             	mov    0x10(%ebp),%eax
8010532b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010532e:	89 10                	mov    %edx,(%eax)
  return 0;
80105330:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105335:	c9                   	leave  
80105336:	c3                   	ret    

80105337 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105337:	55                   	push   %ebp
80105338:	89 e5                	mov    %esp,%ebp
8010533a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010533d:	e8 d2 eb ff ff       	call   80103f14 <myproc>
80105342:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010534c:	eb 2a                	jmp    80105378 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
8010534e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105351:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105354:	83 c2 08             	add    $0x8,%edx
80105357:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010535b:	85 c0                	test   %eax,%eax
8010535d:	75 15                	jne    80105374 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
8010535f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105362:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105365:	8d 4a 08             	lea    0x8(%edx),%ecx
80105368:	8b 55 08             	mov    0x8(%ebp),%edx
8010536b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010536f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105372:	eb 0f                	jmp    80105383 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105374:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105378:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010537c:	7e d0                	jle    8010534e <fdalloc+0x17>
    }
  }
  return -1;
8010537e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105383:	c9                   	leave  
80105384:	c3                   	ret    

80105385 <sys_dup>:

int
sys_dup(void)
{
80105385:	55                   	push   %ebp
80105386:	89 e5                	mov    %esp,%ebp
80105388:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010538b:	83 ec 04             	sub    $0x4,%esp
8010538e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105391:	50                   	push   %eax
80105392:	6a 00                	push   $0x0
80105394:	6a 00                	push   $0x0
80105396:	e8 28 ff ff ff       	call   801052c3 <argfd>
8010539b:	83 c4 10             	add    $0x10,%esp
8010539e:	85 c0                	test   %eax,%eax
801053a0:	79 07                	jns    801053a9 <sys_dup+0x24>
    return -1;
801053a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a7:	eb 31                	jmp    801053da <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801053a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ac:	83 ec 0c             	sub    $0xc,%esp
801053af:	50                   	push   %eax
801053b0:	e8 82 ff ff ff       	call   80105337 <fdalloc>
801053b5:	83 c4 10             	add    $0x10,%esp
801053b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053bf:	79 07                	jns    801053c8 <sys_dup+0x43>
    return -1;
801053c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053c6:	eb 12                	jmp    801053da <sys_dup+0x55>
  filedup(f);
801053c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053cb:	83 ec 0c             	sub    $0xc,%esp
801053ce:	50                   	push   %eax
801053cf:	e8 76 bc ff ff       	call   8010104a <filedup>
801053d4:	83 c4 10             	add    $0x10,%esp
  return fd;
801053d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801053da:	c9                   	leave  
801053db:	c3                   	ret    

801053dc <sys_read>:

int
sys_read(void)
{
801053dc:	55                   	push   %ebp
801053dd:	89 e5                	mov    %esp,%ebp
801053df:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053e2:	83 ec 04             	sub    $0x4,%esp
801053e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053e8:	50                   	push   %eax
801053e9:	6a 00                	push   $0x0
801053eb:	6a 00                	push   $0x0
801053ed:	e8 d1 fe ff ff       	call   801052c3 <argfd>
801053f2:	83 c4 10             	add    $0x10,%esp
801053f5:	85 c0                	test   %eax,%eax
801053f7:	78 2e                	js     80105427 <sys_read+0x4b>
801053f9:	83 ec 08             	sub    $0x8,%esp
801053fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053ff:	50                   	push   %eax
80105400:	6a 02                	push   $0x2
80105402:	e8 72 fd ff ff       	call   80105179 <argint>
80105407:	83 c4 10             	add    $0x10,%esp
8010540a:	85 c0                	test   %eax,%eax
8010540c:	78 19                	js     80105427 <sys_read+0x4b>
8010540e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105411:	83 ec 04             	sub    $0x4,%esp
80105414:	50                   	push   %eax
80105415:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105418:	50                   	push   %eax
80105419:	6a 01                	push   $0x1
8010541b:	e8 86 fd ff ff       	call   801051a6 <argptr>
80105420:	83 c4 10             	add    $0x10,%esp
80105423:	85 c0                	test   %eax,%eax
80105425:	79 07                	jns    8010542e <sys_read+0x52>
    return -1;
80105427:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010542c:	eb 17                	jmp    80105445 <sys_read+0x69>
  return fileread(f, p, n);
8010542e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105431:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105437:	83 ec 04             	sub    $0x4,%esp
8010543a:	51                   	push   %ecx
8010543b:	52                   	push   %edx
8010543c:	50                   	push   %eax
8010543d:	e8 98 bd ff ff       	call   801011da <fileread>
80105442:	83 c4 10             	add    $0x10,%esp
}
80105445:	c9                   	leave  
80105446:	c3                   	ret    

80105447 <sys_write>:

int
sys_write(void)
{
80105447:	55                   	push   %ebp
80105448:	89 e5                	mov    %esp,%ebp
8010544a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010544d:	83 ec 04             	sub    $0x4,%esp
80105450:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105453:	50                   	push   %eax
80105454:	6a 00                	push   $0x0
80105456:	6a 00                	push   $0x0
80105458:	e8 66 fe ff ff       	call   801052c3 <argfd>
8010545d:	83 c4 10             	add    $0x10,%esp
80105460:	85 c0                	test   %eax,%eax
80105462:	78 2e                	js     80105492 <sys_write+0x4b>
80105464:	83 ec 08             	sub    $0x8,%esp
80105467:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010546a:	50                   	push   %eax
8010546b:	6a 02                	push   $0x2
8010546d:	e8 07 fd ff ff       	call   80105179 <argint>
80105472:	83 c4 10             	add    $0x10,%esp
80105475:	85 c0                	test   %eax,%eax
80105477:	78 19                	js     80105492 <sys_write+0x4b>
80105479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010547c:	83 ec 04             	sub    $0x4,%esp
8010547f:	50                   	push   %eax
80105480:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105483:	50                   	push   %eax
80105484:	6a 01                	push   $0x1
80105486:	e8 1b fd ff ff       	call   801051a6 <argptr>
8010548b:	83 c4 10             	add    $0x10,%esp
8010548e:	85 c0                	test   %eax,%eax
80105490:	79 07                	jns    80105499 <sys_write+0x52>
    return -1;
80105492:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105497:	eb 17                	jmp    801054b0 <sys_write+0x69>
  return filewrite(f, p, n);
80105499:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010549c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010549f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054a2:	83 ec 04             	sub    $0x4,%esp
801054a5:	51                   	push   %ecx
801054a6:	52                   	push   %edx
801054a7:	50                   	push   %eax
801054a8:	e8 e5 bd ff ff       	call   80101292 <filewrite>
801054ad:	83 c4 10             	add    $0x10,%esp
}
801054b0:	c9                   	leave  
801054b1:	c3                   	ret    

801054b2 <sys_close>:

int
sys_close(void)
{
801054b2:	55                   	push   %ebp
801054b3:	89 e5                	mov    %esp,%ebp
801054b5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801054b8:	83 ec 04             	sub    $0x4,%esp
801054bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054be:	50                   	push   %eax
801054bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054c2:	50                   	push   %eax
801054c3:	6a 00                	push   $0x0
801054c5:	e8 f9 fd ff ff       	call   801052c3 <argfd>
801054ca:	83 c4 10             	add    $0x10,%esp
801054cd:	85 c0                	test   %eax,%eax
801054cf:	79 07                	jns    801054d8 <sys_close+0x26>
    return -1;
801054d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054d6:	eb 27                	jmp    801054ff <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801054d8:	e8 37 ea ff ff       	call   80103f14 <myproc>
801054dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054e0:	83 c2 08             	add    $0x8,%edx
801054e3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801054ea:	00 
  fileclose(f);
801054eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054ee:	83 ec 0c             	sub    $0xc,%esp
801054f1:	50                   	push   %eax
801054f2:	e8 a4 bb ff ff       	call   8010109b <fileclose>
801054f7:	83 c4 10             	add    $0x10,%esp
  return 0;
801054fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054ff:	c9                   	leave  
80105500:	c3                   	ret    

80105501 <sys_fstat>:

int
sys_fstat(void)
{
80105501:	55                   	push   %ebp
80105502:	89 e5                	mov    %esp,%ebp
80105504:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105507:	83 ec 04             	sub    $0x4,%esp
8010550a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010550d:	50                   	push   %eax
8010550e:	6a 00                	push   $0x0
80105510:	6a 00                	push   $0x0
80105512:	e8 ac fd ff ff       	call   801052c3 <argfd>
80105517:	83 c4 10             	add    $0x10,%esp
8010551a:	85 c0                	test   %eax,%eax
8010551c:	78 17                	js     80105535 <sys_fstat+0x34>
8010551e:	83 ec 04             	sub    $0x4,%esp
80105521:	6a 14                	push   $0x14
80105523:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105526:	50                   	push   %eax
80105527:	6a 01                	push   $0x1
80105529:	e8 78 fc ff ff       	call   801051a6 <argptr>
8010552e:	83 c4 10             	add    $0x10,%esp
80105531:	85 c0                	test   %eax,%eax
80105533:	79 07                	jns    8010553c <sys_fstat+0x3b>
    return -1;
80105535:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010553a:	eb 13                	jmp    8010554f <sys_fstat+0x4e>
  return filestat(f, st);
8010553c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010553f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105542:	83 ec 08             	sub    $0x8,%esp
80105545:	52                   	push   %edx
80105546:	50                   	push   %eax
80105547:	e8 37 bc ff ff       	call   80101183 <filestat>
8010554c:	83 c4 10             	add    $0x10,%esp
}
8010554f:	c9                   	leave  
80105550:	c3                   	ret    

80105551 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105551:	55                   	push   %ebp
80105552:	89 e5                	mov    %esp,%ebp
80105554:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105557:	83 ec 08             	sub    $0x8,%esp
8010555a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010555d:	50                   	push   %eax
8010555e:	6a 00                	push   $0x0
80105560:	e8 a9 fc ff ff       	call   8010520e <argstr>
80105565:	83 c4 10             	add    $0x10,%esp
80105568:	85 c0                	test   %eax,%eax
8010556a:	78 15                	js     80105581 <sys_link+0x30>
8010556c:	83 ec 08             	sub    $0x8,%esp
8010556f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105572:	50                   	push   %eax
80105573:	6a 01                	push   $0x1
80105575:	e8 94 fc ff ff       	call   8010520e <argstr>
8010557a:	83 c4 10             	add    $0x10,%esp
8010557d:	85 c0                	test   %eax,%eax
8010557f:	79 0a                	jns    8010558b <sys_link+0x3a>
    return -1;
80105581:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105586:	e9 68 01 00 00       	jmp    801056f3 <sys_link+0x1a2>

  begin_op();
8010558b:	e8 90 df ff ff       	call   80103520 <begin_op>
  if((ip = namei(old)) == 0){
80105590:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105593:	83 ec 0c             	sub    $0xc,%esp
80105596:	50                   	push   %eax
80105597:	e8 81 cf ff ff       	call   8010251d <namei>
8010559c:	83 c4 10             	add    $0x10,%esp
8010559f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055a6:	75 0f                	jne    801055b7 <sys_link+0x66>
    end_op();
801055a8:	e8 ff df ff ff       	call   801035ac <end_op>
    return -1;
801055ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055b2:	e9 3c 01 00 00       	jmp    801056f3 <sys_link+0x1a2>
  }

  ilock(ip);
801055b7:	83 ec 0c             	sub    $0xc,%esp
801055ba:	ff 75 f4             	push   -0xc(%ebp)
801055bd:	e8 28 c4 ff ff       	call   801019ea <ilock>
801055c2:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801055c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055cc:	66 83 f8 01          	cmp    $0x1,%ax
801055d0:	75 1d                	jne    801055ef <sys_link+0x9e>
    iunlockput(ip);
801055d2:	83 ec 0c             	sub    $0xc,%esp
801055d5:	ff 75 f4             	push   -0xc(%ebp)
801055d8:	e8 3e c6 ff ff       	call   80101c1b <iunlockput>
801055dd:	83 c4 10             	add    $0x10,%esp
    end_op();
801055e0:	e8 c7 df ff ff       	call   801035ac <end_op>
    return -1;
801055e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ea:	e9 04 01 00 00       	jmp    801056f3 <sys_link+0x1a2>
  }

  ip->nlink++;
801055ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055f6:	83 c0 01             	add    $0x1,%eax
801055f9:	89 c2                	mov    %eax,%edx
801055fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055fe:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105602:	83 ec 0c             	sub    $0xc,%esp
80105605:	ff 75 f4             	push   -0xc(%ebp)
80105608:	e8 00 c2 ff ff       	call   8010180d <iupdate>
8010560d:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105610:	83 ec 0c             	sub    $0xc,%esp
80105613:	ff 75 f4             	push   -0xc(%ebp)
80105616:	e8 e2 c4 ff ff       	call   80101afd <iunlock>
8010561b:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010561e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105621:	83 ec 08             	sub    $0x8,%esp
80105624:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105627:	52                   	push   %edx
80105628:	50                   	push   %eax
80105629:	e8 0b cf ff ff       	call   80102539 <nameiparent>
8010562e:	83 c4 10             	add    $0x10,%esp
80105631:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105634:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105638:	74 71                	je     801056ab <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010563a:	83 ec 0c             	sub    $0xc,%esp
8010563d:	ff 75 f0             	push   -0x10(%ebp)
80105640:	e8 a5 c3 ff ff       	call   801019ea <ilock>
80105645:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105648:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010564b:	8b 10                	mov    (%eax),%edx
8010564d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105650:	8b 00                	mov    (%eax),%eax
80105652:	39 c2                	cmp    %eax,%edx
80105654:	75 1d                	jne    80105673 <sys_link+0x122>
80105656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105659:	8b 40 04             	mov    0x4(%eax),%eax
8010565c:	83 ec 04             	sub    $0x4,%esp
8010565f:	50                   	push   %eax
80105660:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105663:	50                   	push   %eax
80105664:	ff 75 f0             	push   -0x10(%ebp)
80105667:	e8 1a cc ff ff       	call   80102286 <dirlink>
8010566c:	83 c4 10             	add    $0x10,%esp
8010566f:	85 c0                	test   %eax,%eax
80105671:	79 10                	jns    80105683 <sys_link+0x132>
    iunlockput(dp);
80105673:	83 ec 0c             	sub    $0xc,%esp
80105676:	ff 75 f0             	push   -0x10(%ebp)
80105679:	e8 9d c5 ff ff       	call   80101c1b <iunlockput>
8010567e:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105681:	eb 29                	jmp    801056ac <sys_link+0x15b>
  }
  iunlockput(dp);
80105683:	83 ec 0c             	sub    $0xc,%esp
80105686:	ff 75 f0             	push   -0x10(%ebp)
80105689:	e8 8d c5 ff ff       	call   80101c1b <iunlockput>
8010568e:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105691:	83 ec 0c             	sub    $0xc,%esp
80105694:	ff 75 f4             	push   -0xc(%ebp)
80105697:	e8 af c4 ff ff       	call   80101b4b <iput>
8010569c:	83 c4 10             	add    $0x10,%esp

  end_op();
8010569f:	e8 08 df ff ff       	call   801035ac <end_op>

  return 0;
801056a4:	b8 00 00 00 00       	mov    $0x0,%eax
801056a9:	eb 48                	jmp    801056f3 <sys_link+0x1a2>
    goto bad;
801056ab:	90                   	nop

bad:
  ilock(ip);
801056ac:	83 ec 0c             	sub    $0xc,%esp
801056af:	ff 75 f4             	push   -0xc(%ebp)
801056b2:	e8 33 c3 ff ff       	call   801019ea <ilock>
801056b7:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801056ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056bd:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056c1:	83 e8 01             	sub    $0x1,%eax
801056c4:	89 c2                	mov    %eax,%edx
801056c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c9:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801056cd:	83 ec 0c             	sub    $0xc,%esp
801056d0:	ff 75 f4             	push   -0xc(%ebp)
801056d3:	e8 35 c1 ff ff       	call   8010180d <iupdate>
801056d8:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801056db:	83 ec 0c             	sub    $0xc,%esp
801056de:	ff 75 f4             	push   -0xc(%ebp)
801056e1:	e8 35 c5 ff ff       	call   80101c1b <iunlockput>
801056e6:	83 c4 10             	add    $0x10,%esp
  end_op();
801056e9:	e8 be de ff ff       	call   801035ac <end_op>
  return -1;
801056ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056f3:	c9                   	leave  
801056f4:	c3                   	ret    

801056f5 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801056f5:	55                   	push   %ebp
801056f6:	89 e5                	mov    %esp,%ebp
801056f8:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056fb:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105702:	eb 40                	jmp    80105744 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105707:	6a 10                	push   $0x10
80105709:	50                   	push   %eax
8010570a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010570d:	50                   	push   %eax
8010570e:	ff 75 08             	push   0x8(%ebp)
80105711:	e8 c0 c7 ff ff       	call   80101ed6 <readi>
80105716:	83 c4 10             	add    $0x10,%esp
80105719:	83 f8 10             	cmp    $0x10,%eax
8010571c:	74 0d                	je     8010572b <isdirempty+0x36>
      panic("isdirempty: readi");
8010571e:	83 ec 0c             	sub    $0xc,%esp
80105721:	68 d8 a7 10 80       	push   $0x8010a7d8
80105726:	e8 7e ae ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
8010572b:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010572f:	66 85 c0             	test   %ax,%ax
80105732:	74 07                	je     8010573b <isdirempty+0x46>
      return 0;
80105734:	b8 00 00 00 00       	mov    $0x0,%eax
80105739:	eb 1b                	jmp    80105756 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010573b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010573e:	83 c0 10             	add    $0x10,%eax
80105741:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105744:	8b 45 08             	mov    0x8(%ebp),%eax
80105747:	8b 50 58             	mov    0x58(%eax),%edx
8010574a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010574d:	39 c2                	cmp    %eax,%edx
8010574f:	77 b3                	ja     80105704 <isdirempty+0xf>
  }
  return 1;
80105751:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105756:	c9                   	leave  
80105757:	c3                   	ret    

80105758 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105758:	55                   	push   %ebp
80105759:	89 e5                	mov    %esp,%ebp
8010575b:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010575e:	83 ec 08             	sub    $0x8,%esp
80105761:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105764:	50                   	push   %eax
80105765:	6a 00                	push   $0x0
80105767:	e8 a2 fa ff ff       	call   8010520e <argstr>
8010576c:	83 c4 10             	add    $0x10,%esp
8010576f:	85 c0                	test   %eax,%eax
80105771:	79 0a                	jns    8010577d <sys_unlink+0x25>
    return -1;
80105773:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105778:	e9 bf 01 00 00       	jmp    8010593c <sys_unlink+0x1e4>

  begin_op();
8010577d:	e8 9e dd ff ff       	call   80103520 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105782:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105785:	83 ec 08             	sub    $0x8,%esp
80105788:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010578b:	52                   	push   %edx
8010578c:	50                   	push   %eax
8010578d:	e8 a7 cd ff ff       	call   80102539 <nameiparent>
80105792:	83 c4 10             	add    $0x10,%esp
80105795:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105798:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010579c:	75 0f                	jne    801057ad <sys_unlink+0x55>
    end_op();
8010579e:	e8 09 de ff ff       	call   801035ac <end_op>
    return -1;
801057a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057a8:	e9 8f 01 00 00       	jmp    8010593c <sys_unlink+0x1e4>
  }

  ilock(dp);
801057ad:	83 ec 0c             	sub    $0xc,%esp
801057b0:	ff 75 f4             	push   -0xc(%ebp)
801057b3:	e8 32 c2 ff ff       	call   801019ea <ilock>
801057b8:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801057bb:	83 ec 08             	sub    $0x8,%esp
801057be:	68 ea a7 10 80       	push   $0x8010a7ea
801057c3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057c6:	50                   	push   %eax
801057c7:	e8 e5 c9 ff ff       	call   801021b1 <namecmp>
801057cc:	83 c4 10             	add    $0x10,%esp
801057cf:	85 c0                	test   %eax,%eax
801057d1:	0f 84 49 01 00 00    	je     80105920 <sys_unlink+0x1c8>
801057d7:	83 ec 08             	sub    $0x8,%esp
801057da:	68 ec a7 10 80       	push   $0x8010a7ec
801057df:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057e2:	50                   	push   %eax
801057e3:	e8 c9 c9 ff ff       	call   801021b1 <namecmp>
801057e8:	83 c4 10             	add    $0x10,%esp
801057eb:	85 c0                	test   %eax,%eax
801057ed:	0f 84 2d 01 00 00    	je     80105920 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801057f3:	83 ec 04             	sub    $0x4,%esp
801057f6:	8d 45 c8             	lea    -0x38(%ebp),%eax
801057f9:	50                   	push   %eax
801057fa:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057fd:	50                   	push   %eax
801057fe:	ff 75 f4             	push   -0xc(%ebp)
80105801:	e8 c6 c9 ff ff       	call   801021cc <dirlookup>
80105806:	83 c4 10             	add    $0x10,%esp
80105809:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010580c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105810:	0f 84 0d 01 00 00    	je     80105923 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105816:	83 ec 0c             	sub    $0xc,%esp
80105819:	ff 75 f0             	push   -0x10(%ebp)
8010581c:	e8 c9 c1 ff ff       	call   801019ea <ilock>
80105821:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105824:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105827:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010582b:	66 85 c0             	test   %ax,%ax
8010582e:	7f 0d                	jg     8010583d <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105830:	83 ec 0c             	sub    $0xc,%esp
80105833:	68 ef a7 10 80       	push   $0x8010a7ef
80105838:	e8 6c ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010583d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105840:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105844:	66 83 f8 01          	cmp    $0x1,%ax
80105848:	75 25                	jne    8010586f <sys_unlink+0x117>
8010584a:	83 ec 0c             	sub    $0xc,%esp
8010584d:	ff 75 f0             	push   -0x10(%ebp)
80105850:	e8 a0 fe ff ff       	call   801056f5 <isdirempty>
80105855:	83 c4 10             	add    $0x10,%esp
80105858:	85 c0                	test   %eax,%eax
8010585a:	75 13                	jne    8010586f <sys_unlink+0x117>
    iunlockput(ip);
8010585c:	83 ec 0c             	sub    $0xc,%esp
8010585f:	ff 75 f0             	push   -0x10(%ebp)
80105862:	e8 b4 c3 ff ff       	call   80101c1b <iunlockput>
80105867:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010586a:	e9 b5 00 00 00       	jmp    80105924 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
8010586f:	83 ec 04             	sub    $0x4,%esp
80105872:	6a 10                	push   $0x10
80105874:	6a 00                	push   $0x0
80105876:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105879:	50                   	push   %eax
8010587a:	e8 cf f5 ff ff       	call   80104e4e <memset>
8010587f:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105882:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105885:	6a 10                	push   $0x10
80105887:	50                   	push   %eax
80105888:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010588b:	50                   	push   %eax
8010588c:	ff 75 f4             	push   -0xc(%ebp)
8010588f:	e8 97 c7 ff ff       	call   8010202b <writei>
80105894:	83 c4 10             	add    $0x10,%esp
80105897:	83 f8 10             	cmp    $0x10,%eax
8010589a:	74 0d                	je     801058a9 <sys_unlink+0x151>
    panic("unlink: writei");
8010589c:	83 ec 0c             	sub    $0xc,%esp
8010589f:	68 01 a8 10 80       	push   $0x8010a801
801058a4:	e8 00 ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801058a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ac:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801058b0:	66 83 f8 01          	cmp    $0x1,%ax
801058b4:	75 21                	jne    801058d7 <sys_unlink+0x17f>
    dp->nlink--;
801058b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058bd:	83 e8 01             	sub    $0x1,%eax
801058c0:	89 c2                	mov    %eax,%edx
801058c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c5:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801058c9:	83 ec 0c             	sub    $0xc,%esp
801058cc:	ff 75 f4             	push   -0xc(%ebp)
801058cf:	e8 39 bf ff ff       	call   8010180d <iupdate>
801058d4:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801058d7:	83 ec 0c             	sub    $0xc,%esp
801058da:	ff 75 f4             	push   -0xc(%ebp)
801058dd:	e8 39 c3 ff ff       	call   80101c1b <iunlockput>
801058e2:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801058e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058ec:	83 e8 01             	sub    $0x1,%eax
801058ef:	89 c2                	mov    %eax,%edx
801058f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f4:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801058f8:	83 ec 0c             	sub    $0xc,%esp
801058fb:	ff 75 f0             	push   -0x10(%ebp)
801058fe:	e8 0a bf ff ff       	call   8010180d <iupdate>
80105903:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105906:	83 ec 0c             	sub    $0xc,%esp
80105909:	ff 75 f0             	push   -0x10(%ebp)
8010590c:	e8 0a c3 ff ff       	call   80101c1b <iunlockput>
80105911:	83 c4 10             	add    $0x10,%esp

  end_op();
80105914:	e8 93 dc ff ff       	call   801035ac <end_op>

  return 0;
80105919:	b8 00 00 00 00       	mov    $0x0,%eax
8010591e:	eb 1c                	jmp    8010593c <sys_unlink+0x1e4>
    goto bad;
80105920:	90                   	nop
80105921:	eb 01                	jmp    80105924 <sys_unlink+0x1cc>
    goto bad;
80105923:	90                   	nop

bad:
  iunlockput(dp);
80105924:	83 ec 0c             	sub    $0xc,%esp
80105927:	ff 75 f4             	push   -0xc(%ebp)
8010592a:	e8 ec c2 ff ff       	call   80101c1b <iunlockput>
8010592f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105932:	e8 75 dc ff ff       	call   801035ac <end_op>
  return -1;
80105937:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010593c:	c9                   	leave  
8010593d:	c3                   	ret    

8010593e <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010593e:	55                   	push   %ebp
8010593f:	89 e5                	mov    %esp,%ebp
80105941:	83 ec 38             	sub    $0x38,%esp
80105944:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105947:	8b 55 10             	mov    0x10(%ebp),%edx
8010594a:	8b 45 14             	mov    0x14(%ebp),%eax
8010594d:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105951:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105955:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105959:	83 ec 08             	sub    $0x8,%esp
8010595c:	8d 45 de             	lea    -0x22(%ebp),%eax
8010595f:	50                   	push   %eax
80105960:	ff 75 08             	push   0x8(%ebp)
80105963:	e8 d1 cb ff ff       	call   80102539 <nameiparent>
80105968:	83 c4 10             	add    $0x10,%esp
8010596b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010596e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105972:	75 0a                	jne    8010597e <create+0x40>
    return 0;
80105974:	b8 00 00 00 00       	mov    $0x0,%eax
80105979:	e9 90 01 00 00       	jmp    80105b0e <create+0x1d0>
  ilock(dp);
8010597e:	83 ec 0c             	sub    $0xc,%esp
80105981:	ff 75 f4             	push   -0xc(%ebp)
80105984:	e8 61 c0 ff ff       	call   801019ea <ilock>
80105989:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
8010598c:	83 ec 04             	sub    $0x4,%esp
8010598f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105992:	50                   	push   %eax
80105993:	8d 45 de             	lea    -0x22(%ebp),%eax
80105996:	50                   	push   %eax
80105997:	ff 75 f4             	push   -0xc(%ebp)
8010599a:	e8 2d c8 ff ff       	call   801021cc <dirlookup>
8010599f:	83 c4 10             	add    $0x10,%esp
801059a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059a9:	74 50                	je     801059fb <create+0xbd>
    iunlockput(dp);
801059ab:	83 ec 0c             	sub    $0xc,%esp
801059ae:	ff 75 f4             	push   -0xc(%ebp)
801059b1:	e8 65 c2 ff ff       	call   80101c1b <iunlockput>
801059b6:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801059b9:	83 ec 0c             	sub    $0xc,%esp
801059bc:	ff 75 f0             	push   -0x10(%ebp)
801059bf:	e8 26 c0 ff ff       	call   801019ea <ilock>
801059c4:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801059c7:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801059cc:	75 15                	jne    801059e3 <create+0xa5>
801059ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059d5:	66 83 f8 02          	cmp    $0x2,%ax
801059d9:	75 08                	jne    801059e3 <create+0xa5>
      return ip;
801059db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059de:	e9 2b 01 00 00       	jmp    80105b0e <create+0x1d0>
    iunlockput(ip);
801059e3:	83 ec 0c             	sub    $0xc,%esp
801059e6:	ff 75 f0             	push   -0x10(%ebp)
801059e9:	e8 2d c2 ff ff       	call   80101c1b <iunlockput>
801059ee:	83 c4 10             	add    $0x10,%esp
    return 0;
801059f1:	b8 00 00 00 00       	mov    $0x0,%eax
801059f6:	e9 13 01 00 00       	jmp    80105b0e <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801059fb:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801059ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a02:	8b 00                	mov    (%eax),%eax
80105a04:	83 ec 08             	sub    $0x8,%esp
80105a07:	52                   	push   %edx
80105a08:	50                   	push   %eax
80105a09:	e8 28 bd ff ff       	call   80101736 <ialloc>
80105a0e:	83 c4 10             	add    $0x10,%esp
80105a11:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a14:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a18:	75 0d                	jne    80105a27 <create+0xe9>
    panic("create: ialloc");
80105a1a:	83 ec 0c             	sub    $0xc,%esp
80105a1d:	68 10 a8 10 80       	push   $0x8010a810
80105a22:	e8 82 ab ff ff       	call   801005a9 <panic>

  ilock(ip);
80105a27:	83 ec 0c             	sub    $0xc,%esp
80105a2a:	ff 75 f0             	push   -0x10(%ebp)
80105a2d:	e8 b8 bf ff ff       	call   801019ea <ilock>
80105a32:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a38:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105a3c:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a43:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105a47:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4e:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105a54:	83 ec 0c             	sub    $0xc,%esp
80105a57:	ff 75 f0             	push   -0x10(%ebp)
80105a5a:	e8 ae bd ff ff       	call   8010180d <iupdate>
80105a5f:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105a62:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a67:	75 6a                	jne    80105ad3 <create+0x195>
    dp->nlink++;  // for ".."
80105a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a70:	83 c0 01             	add    $0x1,%eax
80105a73:	89 c2                	mov    %eax,%edx
80105a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a78:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a7c:	83 ec 0c             	sub    $0xc,%esp
80105a7f:	ff 75 f4             	push   -0xc(%ebp)
80105a82:	e8 86 bd ff ff       	call   8010180d <iupdate>
80105a87:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a8d:	8b 40 04             	mov    0x4(%eax),%eax
80105a90:	83 ec 04             	sub    $0x4,%esp
80105a93:	50                   	push   %eax
80105a94:	68 ea a7 10 80       	push   $0x8010a7ea
80105a99:	ff 75 f0             	push   -0x10(%ebp)
80105a9c:	e8 e5 c7 ff ff       	call   80102286 <dirlink>
80105aa1:	83 c4 10             	add    $0x10,%esp
80105aa4:	85 c0                	test   %eax,%eax
80105aa6:	78 1e                	js     80105ac6 <create+0x188>
80105aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aab:	8b 40 04             	mov    0x4(%eax),%eax
80105aae:	83 ec 04             	sub    $0x4,%esp
80105ab1:	50                   	push   %eax
80105ab2:	68 ec a7 10 80       	push   $0x8010a7ec
80105ab7:	ff 75 f0             	push   -0x10(%ebp)
80105aba:	e8 c7 c7 ff ff       	call   80102286 <dirlink>
80105abf:	83 c4 10             	add    $0x10,%esp
80105ac2:	85 c0                	test   %eax,%eax
80105ac4:	79 0d                	jns    80105ad3 <create+0x195>
      panic("create dots");
80105ac6:	83 ec 0c             	sub    $0xc,%esp
80105ac9:	68 1f a8 10 80       	push   $0x8010a81f
80105ace:	e8 d6 aa ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad6:	8b 40 04             	mov    0x4(%eax),%eax
80105ad9:	83 ec 04             	sub    $0x4,%esp
80105adc:	50                   	push   %eax
80105add:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ae0:	50                   	push   %eax
80105ae1:	ff 75 f4             	push   -0xc(%ebp)
80105ae4:	e8 9d c7 ff ff       	call   80102286 <dirlink>
80105ae9:	83 c4 10             	add    $0x10,%esp
80105aec:	85 c0                	test   %eax,%eax
80105aee:	79 0d                	jns    80105afd <create+0x1bf>
    panic("create: dirlink");
80105af0:	83 ec 0c             	sub    $0xc,%esp
80105af3:	68 2b a8 10 80       	push   $0x8010a82b
80105af8:	e8 ac aa ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105afd:	83 ec 0c             	sub    $0xc,%esp
80105b00:	ff 75 f4             	push   -0xc(%ebp)
80105b03:	e8 13 c1 ff ff       	call   80101c1b <iunlockput>
80105b08:	83 c4 10             	add    $0x10,%esp

  return ip;
80105b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105b0e:	c9                   	leave  
80105b0f:	c3                   	ret    

80105b10 <sys_open>:

int
sys_open(void)
{
80105b10:	55                   	push   %ebp
80105b11:	89 e5                	mov    %esp,%ebp
80105b13:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105b16:	83 ec 08             	sub    $0x8,%esp
80105b19:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b1c:	50                   	push   %eax
80105b1d:	6a 00                	push   $0x0
80105b1f:	e8 ea f6 ff ff       	call   8010520e <argstr>
80105b24:	83 c4 10             	add    $0x10,%esp
80105b27:	85 c0                	test   %eax,%eax
80105b29:	78 15                	js     80105b40 <sys_open+0x30>
80105b2b:	83 ec 08             	sub    $0x8,%esp
80105b2e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b31:	50                   	push   %eax
80105b32:	6a 01                	push   $0x1
80105b34:	e8 40 f6 ff ff       	call   80105179 <argint>
80105b39:	83 c4 10             	add    $0x10,%esp
80105b3c:	85 c0                	test   %eax,%eax
80105b3e:	79 0a                	jns    80105b4a <sys_open+0x3a>
    return -1;
80105b40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b45:	e9 61 01 00 00       	jmp    80105cab <sys_open+0x19b>

  begin_op();
80105b4a:	e8 d1 d9 ff ff       	call   80103520 <begin_op>

  if(omode & O_CREATE){
80105b4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b52:	25 00 02 00 00       	and    $0x200,%eax
80105b57:	85 c0                	test   %eax,%eax
80105b59:	74 2a                	je     80105b85 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105b5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b5e:	6a 00                	push   $0x0
80105b60:	6a 00                	push   $0x0
80105b62:	6a 02                	push   $0x2
80105b64:	50                   	push   %eax
80105b65:	e8 d4 fd ff ff       	call   8010593e <create>
80105b6a:	83 c4 10             	add    $0x10,%esp
80105b6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105b70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b74:	75 75                	jne    80105beb <sys_open+0xdb>
      end_op();
80105b76:	e8 31 da ff ff       	call   801035ac <end_op>
      return -1;
80105b7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b80:	e9 26 01 00 00       	jmp    80105cab <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105b85:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b88:	83 ec 0c             	sub    $0xc,%esp
80105b8b:	50                   	push   %eax
80105b8c:	e8 8c c9 ff ff       	call   8010251d <namei>
80105b91:	83 c4 10             	add    $0x10,%esp
80105b94:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b97:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b9b:	75 0f                	jne    80105bac <sys_open+0x9c>
      end_op();
80105b9d:	e8 0a da ff ff       	call   801035ac <end_op>
      return -1;
80105ba2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ba7:	e9 ff 00 00 00       	jmp    80105cab <sys_open+0x19b>
    }
    ilock(ip);
80105bac:	83 ec 0c             	sub    $0xc,%esp
80105baf:	ff 75 f4             	push   -0xc(%ebp)
80105bb2:	e8 33 be ff ff       	call   801019ea <ilock>
80105bb7:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105bc1:	66 83 f8 01          	cmp    $0x1,%ax
80105bc5:	75 24                	jne    80105beb <sys_open+0xdb>
80105bc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bca:	85 c0                	test   %eax,%eax
80105bcc:	74 1d                	je     80105beb <sys_open+0xdb>
      iunlockput(ip);
80105bce:	83 ec 0c             	sub    $0xc,%esp
80105bd1:	ff 75 f4             	push   -0xc(%ebp)
80105bd4:	e8 42 c0 ff ff       	call   80101c1b <iunlockput>
80105bd9:	83 c4 10             	add    $0x10,%esp
      end_op();
80105bdc:	e8 cb d9 ff ff       	call   801035ac <end_op>
      return -1;
80105be1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be6:	e9 c0 00 00 00       	jmp    80105cab <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105beb:	e8 ed b3 ff ff       	call   80100fdd <filealloc>
80105bf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bf3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bf7:	74 17                	je     80105c10 <sys_open+0x100>
80105bf9:	83 ec 0c             	sub    $0xc,%esp
80105bfc:	ff 75 f0             	push   -0x10(%ebp)
80105bff:	e8 33 f7 ff ff       	call   80105337 <fdalloc>
80105c04:	83 c4 10             	add    $0x10,%esp
80105c07:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105c0a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105c0e:	79 2e                	jns    80105c3e <sys_open+0x12e>
    if(f)
80105c10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c14:	74 0e                	je     80105c24 <sys_open+0x114>
      fileclose(f);
80105c16:	83 ec 0c             	sub    $0xc,%esp
80105c19:	ff 75 f0             	push   -0x10(%ebp)
80105c1c:	e8 7a b4 ff ff       	call   8010109b <fileclose>
80105c21:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105c24:	83 ec 0c             	sub    $0xc,%esp
80105c27:	ff 75 f4             	push   -0xc(%ebp)
80105c2a:	e8 ec bf ff ff       	call   80101c1b <iunlockput>
80105c2f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105c32:	e8 75 d9 ff ff       	call   801035ac <end_op>
    return -1;
80105c37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c3c:	eb 6d                	jmp    80105cab <sys_open+0x19b>
  }
  iunlock(ip);
80105c3e:	83 ec 0c             	sub    $0xc,%esp
80105c41:	ff 75 f4             	push   -0xc(%ebp)
80105c44:	e8 b4 be ff ff       	call   80101afd <iunlock>
80105c49:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c4c:	e8 5b d9 ff ff       	call   801035ac <end_op>

  f->type = FD_INODE;
80105c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c54:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c60:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c66:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105c6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c70:	83 e0 01             	and    $0x1,%eax
80105c73:	85 c0                	test   %eax,%eax
80105c75:	0f 94 c0             	sete   %al
80105c78:	89 c2                	mov    %eax,%edx
80105c7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7d:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105c80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c83:	83 e0 01             	and    $0x1,%eax
80105c86:	85 c0                	test   %eax,%eax
80105c88:	75 0a                	jne    80105c94 <sys_open+0x184>
80105c8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c8d:	83 e0 02             	and    $0x2,%eax
80105c90:	85 c0                	test   %eax,%eax
80105c92:	74 07                	je     80105c9b <sys_open+0x18b>
80105c94:	b8 01 00 00 00       	mov    $0x1,%eax
80105c99:	eb 05                	jmp    80105ca0 <sys_open+0x190>
80105c9b:	b8 00 00 00 00       	mov    $0x0,%eax
80105ca0:	89 c2                	mov    %eax,%edx
80105ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca5:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105ca8:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105cab:	c9                   	leave  
80105cac:	c3                   	ret    

80105cad <sys_mkdir>:

int
sys_mkdir(void)
{
80105cad:	55                   	push   %ebp
80105cae:	89 e5                	mov    %esp,%ebp
80105cb0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105cb3:	e8 68 d8 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105cb8:	83 ec 08             	sub    $0x8,%esp
80105cbb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cbe:	50                   	push   %eax
80105cbf:	6a 00                	push   $0x0
80105cc1:	e8 48 f5 ff ff       	call   8010520e <argstr>
80105cc6:	83 c4 10             	add    $0x10,%esp
80105cc9:	85 c0                	test   %eax,%eax
80105ccb:	78 1b                	js     80105ce8 <sys_mkdir+0x3b>
80105ccd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd0:	6a 00                	push   $0x0
80105cd2:	6a 00                	push   $0x0
80105cd4:	6a 01                	push   $0x1
80105cd6:	50                   	push   %eax
80105cd7:	e8 62 fc ff ff       	call   8010593e <create>
80105cdc:	83 c4 10             	add    $0x10,%esp
80105cdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ce2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ce6:	75 0c                	jne    80105cf4 <sys_mkdir+0x47>
    end_op();
80105ce8:	e8 bf d8 ff ff       	call   801035ac <end_op>
    return -1;
80105ced:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf2:	eb 18                	jmp    80105d0c <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105cf4:	83 ec 0c             	sub    $0xc,%esp
80105cf7:	ff 75 f4             	push   -0xc(%ebp)
80105cfa:	e8 1c bf ff ff       	call   80101c1b <iunlockput>
80105cff:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d02:	e8 a5 d8 ff ff       	call   801035ac <end_op>
  return 0;
80105d07:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d0c:	c9                   	leave  
80105d0d:	c3                   	ret    

80105d0e <sys_mknod>:

int
sys_mknod(void)
{
80105d0e:	55                   	push   %ebp
80105d0f:	89 e5                	mov    %esp,%ebp
80105d11:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105d14:	e8 07 d8 ff ff       	call   80103520 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105d19:	83 ec 08             	sub    $0x8,%esp
80105d1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d1f:	50                   	push   %eax
80105d20:	6a 00                	push   $0x0
80105d22:	e8 e7 f4 ff ff       	call   8010520e <argstr>
80105d27:	83 c4 10             	add    $0x10,%esp
80105d2a:	85 c0                	test   %eax,%eax
80105d2c:	78 4f                	js     80105d7d <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105d2e:	83 ec 08             	sub    $0x8,%esp
80105d31:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d34:	50                   	push   %eax
80105d35:	6a 01                	push   $0x1
80105d37:	e8 3d f4 ff ff       	call   80105179 <argint>
80105d3c:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105d3f:	85 c0                	test   %eax,%eax
80105d41:	78 3a                	js     80105d7d <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105d43:	83 ec 08             	sub    $0x8,%esp
80105d46:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d49:	50                   	push   %eax
80105d4a:	6a 02                	push   $0x2
80105d4c:	e8 28 f4 ff ff       	call   80105179 <argint>
80105d51:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105d54:	85 c0                	test   %eax,%eax
80105d56:	78 25                	js     80105d7d <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d58:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d5b:	0f bf c8             	movswl %ax,%ecx
80105d5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d61:	0f bf d0             	movswl %ax,%edx
80105d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d67:	51                   	push   %ecx
80105d68:	52                   	push   %edx
80105d69:	6a 03                	push   $0x3
80105d6b:	50                   	push   %eax
80105d6c:	e8 cd fb ff ff       	call   8010593e <create>
80105d71:	83 c4 10             	add    $0x10,%esp
80105d74:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105d77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d7b:	75 0c                	jne    80105d89 <sys_mknod+0x7b>
    end_op();
80105d7d:	e8 2a d8 ff ff       	call   801035ac <end_op>
    return -1;
80105d82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d87:	eb 18                	jmp    80105da1 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105d89:	83 ec 0c             	sub    $0xc,%esp
80105d8c:	ff 75 f4             	push   -0xc(%ebp)
80105d8f:	e8 87 be ff ff       	call   80101c1b <iunlockput>
80105d94:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d97:	e8 10 d8 ff ff       	call   801035ac <end_op>
  return 0;
80105d9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105da1:	c9                   	leave  
80105da2:	c3                   	ret    

80105da3 <sys_chdir>:

int
sys_chdir(void)
{
80105da3:	55                   	push   %ebp
80105da4:	89 e5                	mov    %esp,%ebp
80105da6:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105da9:	e8 66 e1 ff ff       	call   80103f14 <myproc>
80105dae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105db1:	e8 6a d7 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105db6:	83 ec 08             	sub    $0x8,%esp
80105db9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105dbc:	50                   	push   %eax
80105dbd:	6a 00                	push   $0x0
80105dbf:	e8 4a f4 ff ff       	call   8010520e <argstr>
80105dc4:	83 c4 10             	add    $0x10,%esp
80105dc7:	85 c0                	test   %eax,%eax
80105dc9:	78 18                	js     80105de3 <sys_chdir+0x40>
80105dcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105dce:	83 ec 0c             	sub    $0xc,%esp
80105dd1:	50                   	push   %eax
80105dd2:	e8 46 c7 ff ff       	call   8010251d <namei>
80105dd7:	83 c4 10             	add    $0x10,%esp
80105dda:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ddd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105de1:	75 0c                	jne    80105def <sys_chdir+0x4c>
    end_op();
80105de3:	e8 c4 d7 ff ff       	call   801035ac <end_op>
    return -1;
80105de8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ded:	eb 68                	jmp    80105e57 <sys_chdir+0xb4>
  }
  ilock(ip);
80105def:	83 ec 0c             	sub    $0xc,%esp
80105df2:	ff 75 f0             	push   -0x10(%ebp)
80105df5:	e8 f0 bb ff ff       	call   801019ea <ilock>
80105dfa:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e00:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e04:	66 83 f8 01          	cmp    $0x1,%ax
80105e08:	74 1a                	je     80105e24 <sys_chdir+0x81>
    iunlockput(ip);
80105e0a:	83 ec 0c             	sub    $0xc,%esp
80105e0d:	ff 75 f0             	push   -0x10(%ebp)
80105e10:	e8 06 be ff ff       	call   80101c1b <iunlockput>
80105e15:	83 c4 10             	add    $0x10,%esp
    end_op();
80105e18:	e8 8f d7 ff ff       	call   801035ac <end_op>
    return -1;
80105e1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e22:	eb 33                	jmp    80105e57 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105e24:	83 ec 0c             	sub    $0xc,%esp
80105e27:	ff 75 f0             	push   -0x10(%ebp)
80105e2a:	e8 ce bc ff ff       	call   80101afd <iunlock>
80105e2f:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e35:	8b 40 68             	mov    0x68(%eax),%eax
80105e38:	83 ec 0c             	sub    $0xc,%esp
80105e3b:	50                   	push   %eax
80105e3c:	e8 0a bd ff ff       	call   80101b4b <iput>
80105e41:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e44:	e8 63 d7 ff ff       	call   801035ac <end_op>
  curproc->cwd = ip;
80105e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e4f:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105e52:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e57:	c9                   	leave  
80105e58:	c3                   	ret    

80105e59 <sys_exec>:

int
sys_exec(void)
{
80105e59:	55                   	push   %ebp
80105e5a:	89 e5                	mov    %esp,%ebp
80105e5c:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105e62:	83 ec 08             	sub    $0x8,%esp
80105e65:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e68:	50                   	push   %eax
80105e69:	6a 00                	push   $0x0
80105e6b:	e8 9e f3 ff ff       	call   8010520e <argstr>
80105e70:	83 c4 10             	add    $0x10,%esp
80105e73:	85 c0                	test   %eax,%eax
80105e75:	78 18                	js     80105e8f <sys_exec+0x36>
80105e77:	83 ec 08             	sub    $0x8,%esp
80105e7a:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105e80:	50                   	push   %eax
80105e81:	6a 01                	push   $0x1
80105e83:	e8 f1 f2 ff ff       	call   80105179 <argint>
80105e88:	83 c4 10             	add    $0x10,%esp
80105e8b:	85 c0                	test   %eax,%eax
80105e8d:	79 0a                	jns    80105e99 <sys_exec+0x40>
    return -1;
80105e8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e94:	e9 c6 00 00 00       	jmp    80105f5f <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105e99:	83 ec 04             	sub    $0x4,%esp
80105e9c:	68 80 00 00 00       	push   $0x80
80105ea1:	6a 00                	push   $0x0
80105ea3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105ea9:	50                   	push   %eax
80105eaa:	e8 9f ef ff ff       	call   80104e4e <memset>
80105eaf:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105eb2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebc:	83 f8 1f             	cmp    $0x1f,%eax
80105ebf:	76 0a                	jbe    80105ecb <sys_exec+0x72>
      return -1;
80105ec1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec6:	e9 94 00 00 00       	jmp    80105f5f <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ece:	c1 e0 02             	shl    $0x2,%eax
80105ed1:	89 c2                	mov    %eax,%edx
80105ed3:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105ed9:	01 c2                	add    %eax,%edx
80105edb:	83 ec 08             	sub    $0x8,%esp
80105ede:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105ee4:	50                   	push   %eax
80105ee5:	52                   	push   %edx
80105ee6:	e8 ed f1 ff ff       	call   801050d8 <fetchint>
80105eeb:	83 c4 10             	add    $0x10,%esp
80105eee:	85 c0                	test   %eax,%eax
80105ef0:	79 07                	jns    80105ef9 <sys_exec+0xa0>
      return -1;
80105ef2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef7:	eb 66                	jmp    80105f5f <sys_exec+0x106>
    if(uarg == 0){
80105ef9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105eff:	85 c0                	test   %eax,%eax
80105f01:	75 27                	jne    80105f2a <sys_exec+0xd1>
      argv[i] = 0;
80105f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f06:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105f0d:	00 00 00 00 
      break;
80105f11:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f15:	83 ec 08             	sub    $0x8,%esp
80105f18:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f1e:	52                   	push   %edx
80105f1f:	50                   	push   %eax
80105f20:	e8 5b ac ff ff       	call   80100b80 <exec>
80105f25:	83 c4 10             	add    $0x10,%esp
80105f28:	eb 35                	jmp    80105f5f <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105f2a:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f33:	c1 e0 02             	shl    $0x2,%eax
80105f36:	01 c2                	add    %eax,%edx
80105f38:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f3e:	83 ec 08             	sub    $0x8,%esp
80105f41:	52                   	push   %edx
80105f42:	50                   	push   %eax
80105f43:	e8 cf f1 ff ff       	call   80105117 <fetchstr>
80105f48:	83 c4 10             	add    $0x10,%esp
80105f4b:	85 c0                	test   %eax,%eax
80105f4d:	79 07                	jns    80105f56 <sys_exec+0xfd>
      return -1;
80105f4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f54:	eb 09                	jmp    80105f5f <sys_exec+0x106>
  for(i=0;; i++){
80105f56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105f5a:	e9 5a ff ff ff       	jmp    80105eb9 <sys_exec+0x60>
}
80105f5f:	c9                   	leave  
80105f60:	c3                   	ret    

80105f61 <sys_pipe>:

int
sys_pipe(void)
{
80105f61:	55                   	push   %ebp
80105f62:	89 e5                	mov    %esp,%ebp
80105f64:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105f67:	83 ec 04             	sub    $0x4,%esp
80105f6a:	6a 08                	push   $0x8
80105f6c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f6f:	50                   	push   %eax
80105f70:	6a 00                	push   $0x0
80105f72:	e8 2f f2 ff ff       	call   801051a6 <argptr>
80105f77:	83 c4 10             	add    $0x10,%esp
80105f7a:	85 c0                	test   %eax,%eax
80105f7c:	79 0a                	jns    80105f88 <sys_pipe+0x27>
    return -1;
80105f7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f83:	e9 ae 00 00 00       	jmp    80106036 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105f88:	83 ec 08             	sub    $0x8,%esp
80105f8b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f8e:	50                   	push   %eax
80105f8f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f92:	50                   	push   %eax
80105f93:	e8 b9 da ff ff       	call   80103a51 <pipealloc>
80105f98:	83 c4 10             	add    $0x10,%esp
80105f9b:	85 c0                	test   %eax,%eax
80105f9d:	79 0a                	jns    80105fa9 <sys_pipe+0x48>
    return -1;
80105f9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa4:	e9 8d 00 00 00       	jmp    80106036 <sys_pipe+0xd5>
  fd0 = -1;
80105fa9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105fb0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fb3:	83 ec 0c             	sub    $0xc,%esp
80105fb6:	50                   	push   %eax
80105fb7:	e8 7b f3 ff ff       	call   80105337 <fdalloc>
80105fbc:	83 c4 10             	add    $0x10,%esp
80105fbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fc6:	78 18                	js     80105fe0 <sys_pipe+0x7f>
80105fc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fcb:	83 ec 0c             	sub    $0xc,%esp
80105fce:	50                   	push   %eax
80105fcf:	e8 63 f3 ff ff       	call   80105337 <fdalloc>
80105fd4:	83 c4 10             	add    $0x10,%esp
80105fd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fda:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fde:	79 3e                	jns    8010601e <sys_pipe+0xbd>
    if(fd0 >= 0)
80105fe0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fe4:	78 13                	js     80105ff9 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105fe6:	e8 29 df ff ff       	call   80103f14 <myproc>
80105feb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fee:	83 c2 08             	add    $0x8,%edx
80105ff1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105ff8:	00 
    fileclose(rf);
80105ff9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ffc:	83 ec 0c             	sub    $0xc,%esp
80105fff:	50                   	push   %eax
80106000:	e8 96 b0 ff ff       	call   8010109b <fileclose>
80106005:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106008:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010600b:	83 ec 0c             	sub    $0xc,%esp
8010600e:	50                   	push   %eax
8010600f:	e8 87 b0 ff ff       	call   8010109b <fileclose>
80106014:	83 c4 10             	add    $0x10,%esp
    return -1;
80106017:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010601c:	eb 18                	jmp    80106036 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
8010601e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106021:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106024:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106026:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106029:	8d 50 04             	lea    0x4(%eax),%edx
8010602c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010602f:	89 02                	mov    %eax,(%edx)
  return 0;
80106031:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106036:	c9                   	leave  
80106037:	c3                   	ret    

80106038 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106038:	55                   	push   %ebp
80106039:	89 e5                	mov    %esp,%ebp
8010603b:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010603e:	e8 d0 e1 ff ff       	call   80104213 <fork>
}
80106043:	c9                   	leave  
80106044:	c3                   	ret    

80106045 <sys_exit>:

int
sys_exit(void)
{
80106045:	55                   	push   %ebp
80106046:	89 e5                	mov    %esp,%ebp
80106048:	83 ec 08             	sub    $0x8,%esp
  exit();
8010604b:	e8 3c e3 ff ff       	call   8010438c <exit>
  return 0;  // not reached
80106050:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106055:	c9                   	leave  
80106056:	c3                   	ret    

80106057 <sys_wait>:

int
sys_wait(void)
{
80106057:	55                   	push   %ebp
80106058:	89 e5                	mov    %esp,%ebp
8010605a:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010605d:	e8 4a e4 ff ff       	call   801044ac <wait>
}
80106062:	c9                   	leave  
80106063:	c3                   	ret    

80106064 <sys_kill>:

int
sys_kill(void)
{
80106064:	55                   	push   %ebp
80106065:	89 e5                	mov    %esp,%ebp
80106067:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010606a:	83 ec 08             	sub    $0x8,%esp
8010606d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106070:	50                   	push   %eax
80106071:	6a 00                	push   $0x0
80106073:	e8 01 f1 ff ff       	call   80105179 <argint>
80106078:	83 c4 10             	add    $0x10,%esp
8010607b:	85 c0                	test   %eax,%eax
8010607d:	79 07                	jns    80106086 <sys_kill+0x22>
    return -1;
8010607f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106084:	eb 0f                	jmp    80106095 <sys_kill+0x31>
  return kill(pid);
80106086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106089:	83 ec 0c             	sub    $0xc,%esp
8010608c:	50                   	push   %eax
8010608d:	e8 49 e8 ff ff       	call   801048db <kill>
80106092:	83 c4 10             	add    $0x10,%esp
}
80106095:	c9                   	leave  
80106096:	c3                   	ret    

80106097 <sys_getpid>:

int
sys_getpid(void)
{
80106097:	55                   	push   %ebp
80106098:	89 e5                	mov    %esp,%ebp
8010609a:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010609d:	e8 72 de ff ff       	call   80103f14 <myproc>
801060a2:	8b 40 10             	mov    0x10(%eax),%eax
}
801060a5:	c9                   	leave  
801060a6:	c3                   	ret    

801060a7 <sys_sbrk>:

int
sys_sbrk(void)
{
801060a7:	55                   	push   %ebp
801060a8:	89 e5                	mov    %esp,%ebp
801060aa:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801060ad:	83 ec 08             	sub    $0x8,%esp
801060b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060b3:	50                   	push   %eax
801060b4:	6a 00                	push   $0x0
801060b6:	e8 be f0 ff ff       	call   80105179 <argint>
801060bb:	83 c4 10             	add    $0x10,%esp
801060be:	85 c0                	test   %eax,%eax
801060c0:	79 07                	jns    801060c9 <sys_sbrk+0x22>
    return -1;
801060c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c7:	eb 27                	jmp    801060f0 <sys_sbrk+0x49>
  addr = myproc()->sz;
801060c9:	e8 46 de ff ff       	call   80103f14 <myproc>
801060ce:	8b 00                	mov    (%eax),%eax
801060d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801060d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d6:	83 ec 0c             	sub    $0xc,%esp
801060d9:	50                   	push   %eax
801060da:	e8 99 e0 ff ff       	call   80104178 <growproc>
801060df:	83 c4 10             	add    $0x10,%esp
801060e2:	85 c0                	test   %eax,%eax
801060e4:	79 07                	jns    801060ed <sys_sbrk+0x46>
    return -1;
801060e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060eb:	eb 03                	jmp    801060f0 <sys_sbrk+0x49>
  return addr;
801060ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801060f0:	c9                   	leave  
801060f1:	c3                   	ret    

801060f2 <sys_sleep>:

int
sys_sleep(void)
{
801060f2:	55                   	push   %ebp
801060f3:	89 e5                	mov    %esp,%ebp
801060f5:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801060f8:	83 ec 08             	sub    $0x8,%esp
801060fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060fe:	50                   	push   %eax
801060ff:	6a 00                	push   $0x0
80106101:	e8 73 f0 ff ff       	call   80105179 <argint>
80106106:	83 c4 10             	add    $0x10,%esp
80106109:	85 c0                	test   %eax,%eax
8010610b:	79 07                	jns    80106114 <sys_sleep+0x22>
    return -1;
8010610d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106112:	eb 76                	jmp    8010618a <sys_sleep+0x98>
  acquire(&tickslock);
80106114:	83 ec 0c             	sub    $0xc,%esp
80106117:	68 80 9a 11 80       	push   $0x80119a80
8010611c:	e8 b7 ea ff ff       	call   80104bd8 <acquire>
80106121:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106124:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
80106129:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010612c:	eb 38                	jmp    80106166 <sys_sleep+0x74>
    if(myproc()->killed){
8010612e:	e8 e1 dd ff ff       	call   80103f14 <myproc>
80106133:	8b 40 24             	mov    0x24(%eax),%eax
80106136:	85 c0                	test   %eax,%eax
80106138:	74 17                	je     80106151 <sys_sleep+0x5f>
      release(&tickslock);
8010613a:	83 ec 0c             	sub    $0xc,%esp
8010613d:	68 80 9a 11 80       	push   $0x80119a80
80106142:	e8 ff ea ff ff       	call   80104c46 <release>
80106147:	83 c4 10             	add    $0x10,%esp
      return -1;
8010614a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614f:	eb 39                	jmp    8010618a <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106151:	83 ec 08             	sub    $0x8,%esp
80106154:	68 80 9a 11 80       	push   $0x80119a80
80106159:	68 b4 9a 11 80       	push   $0x80119ab4
8010615e:	e8 5a e6 ff ff       	call   801047bd <sleep>
80106163:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106166:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
8010616b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010616e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106171:	39 d0                	cmp    %edx,%eax
80106173:	72 b9                	jb     8010612e <sys_sleep+0x3c>
  }
  release(&tickslock);
80106175:	83 ec 0c             	sub    $0xc,%esp
80106178:	68 80 9a 11 80       	push   $0x80119a80
8010617d:	e8 c4 ea ff ff       	call   80104c46 <release>
80106182:	83 c4 10             	add    $0x10,%esp
  return 0;
80106185:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010618a:	c9                   	leave  
8010618b:	c3                   	ret    

8010618c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010618c:	55                   	push   %ebp
8010618d:	89 e5                	mov    %esp,%ebp
8010618f:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106192:	83 ec 0c             	sub    $0xc,%esp
80106195:	68 80 9a 11 80       	push   $0x80119a80
8010619a:	e8 39 ea ff ff       	call   80104bd8 <acquire>
8010619f:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801061a2:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
801061a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801061aa:	83 ec 0c             	sub    $0xc,%esp
801061ad:	68 80 9a 11 80       	push   $0x80119a80
801061b2:	e8 8f ea ff ff       	call   80104c46 <release>
801061b7:	83 c4 10             	add    $0x10,%esp
  return xticks;
801061ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801061bd:	c9                   	leave  
801061be:	c3                   	ret    

801061bf <sys_uthread_init>:

int
sys_uthread_init(void)
{
801061bf:	55                   	push   %ebp
801061c0:	89 e5                	mov    %esp,%ebp
801061c2:	53                   	push   %ebx
801061c3:	83 ec 14             	sub    $0x14,%esp
  void (*sched)();  // ✅ 함수 포인터
  if (argptr(0, (void *)&sched, sizeof(void (*)(void))) < 0)
801061c6:	83 ec 04             	sub    $0x4,%esp
801061c9:	6a 04                	push   $0x4
801061cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061ce:	50                   	push   %eax
801061cf:	6a 00                	push   $0x0
801061d1:	e8 d0 ef ff ff       	call   801051a6 <argptr>
801061d6:	83 c4 10             	add    $0x10,%esp
801061d9:	85 c0                	test   %eax,%eax
801061db:	79 07                	jns    801061e4 <sys_uthread_init+0x25>
    return -1;
801061dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e2:	eb 12                	jmp    801061f6 <sys_uthread_init+0x37>
  myproc()->scheduler = (uint)sched;
801061e4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801061e7:	e8 28 dd ff ff       	call   80103f14 <myproc>
801061ec:	89 da                	mov    %ebx,%edx
801061ee:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
801061f1:	b8 00 00 00 00       	mov    $0x0,%eax
801061f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801061f9:	c9                   	leave  
801061fa:	c3                   	ret    

801061fb <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801061fb:	1e                   	push   %ds
  pushl %es
801061fc:	06                   	push   %es
  pushl %fs
801061fd:	0f a0                	push   %fs
  pushl %gs
801061ff:	0f a8                	push   %gs
  pushal
80106201:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106202:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106206:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106208:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010620a:	54                   	push   %esp
  call trap
8010620b:	e8 d7 01 00 00       	call   801063e7 <trap>
  addl $4, %esp
80106210:	83 c4 04             	add    $0x4,%esp

80106213 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106213:	61                   	popa   
  popl %gs
80106214:	0f a9                	pop    %gs
  popl %fs
80106216:	0f a1                	pop    %fs
  popl %es
80106218:	07                   	pop    %es
  popl %ds
80106219:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010621a:	83 c4 08             	add    $0x8,%esp
  iret
8010621d:	cf                   	iret   

8010621e <lidt>:
{
8010621e:	55                   	push   %ebp
8010621f:	89 e5                	mov    %esp,%ebp
80106221:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106224:	8b 45 0c             	mov    0xc(%ebp),%eax
80106227:	83 e8 01             	sub    $0x1,%eax
8010622a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010622e:	8b 45 08             	mov    0x8(%ebp),%eax
80106231:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106235:	8b 45 08             	mov    0x8(%ebp),%eax
80106238:	c1 e8 10             	shr    $0x10,%eax
8010623b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010623f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106242:	0f 01 18             	lidtl  (%eax)
}
80106245:	90                   	nop
80106246:	c9                   	leave  
80106247:	c3                   	ret    

80106248 <rcr2>:

static inline uint
rcr2(void)
{
80106248:	55                   	push   %ebp
80106249:	89 e5                	mov    %esp,%ebp
8010624b:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010624e:	0f 20 d0             	mov    %cr2,%eax
80106251:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106254:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106257:	c9                   	leave  
80106258:	c3                   	ret    

80106259 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106259:	55                   	push   %ebp
8010625a:	89 e5                	mov    %esp,%ebp
8010625c:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010625f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106266:	e9 c3 00 00 00       	jmp    8010632e <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010626b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626e:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80106275:	89 c2                	mov    %eax,%edx
80106277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627a:	66 89 14 c5 80 92 11 	mov    %dx,-0x7fee6d80(,%eax,8)
80106281:	80 
80106282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106285:	66 c7 04 c5 82 92 11 	movw   $0x8,-0x7fee6d7e(,%eax,8)
8010628c:	80 08 00 
8010628f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106292:	0f b6 14 c5 84 92 11 	movzbl -0x7fee6d7c(,%eax,8),%edx
80106299:	80 
8010629a:	83 e2 e0             	and    $0xffffffe0,%edx
8010629d:	88 14 c5 84 92 11 80 	mov    %dl,-0x7fee6d7c(,%eax,8)
801062a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a7:	0f b6 14 c5 84 92 11 	movzbl -0x7fee6d7c(,%eax,8),%edx
801062ae:	80 
801062af:	83 e2 1f             	and    $0x1f,%edx
801062b2:	88 14 c5 84 92 11 80 	mov    %dl,-0x7fee6d7c(,%eax,8)
801062b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062bc:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
801062c3:	80 
801062c4:	83 e2 f0             	and    $0xfffffff0,%edx
801062c7:	83 ca 0e             	or     $0xe,%edx
801062ca:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
801062d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d4:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
801062db:	80 
801062dc:	83 e2 ef             	and    $0xffffffef,%edx
801062df:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
801062e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e9:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
801062f0:	80 
801062f1:	83 e2 9f             	and    $0xffffff9f,%edx
801062f4:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
801062fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062fe:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
80106305:	80 
80106306:	83 ca 80             	or     $0xffffff80,%edx
80106309:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
80106310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106313:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
8010631a:	c1 e8 10             	shr    $0x10,%eax
8010631d:	89 c2                	mov    %eax,%edx
8010631f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106322:	66 89 14 c5 86 92 11 	mov    %dx,-0x7fee6d7a(,%eax,8)
80106329:	80 
  for(i = 0; i < 256; i++)
8010632a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010632e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106335:	0f 8e 30 ff ff ff    	jle    8010626b <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010633b:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80106340:	66 a3 80 94 11 80    	mov    %ax,0x80119480
80106346:	66 c7 05 82 94 11 80 	movw   $0x8,0x80119482
8010634d:	08 00 
8010634f:	0f b6 05 84 94 11 80 	movzbl 0x80119484,%eax
80106356:	83 e0 e0             	and    $0xffffffe0,%eax
80106359:	a2 84 94 11 80       	mov    %al,0x80119484
8010635e:	0f b6 05 84 94 11 80 	movzbl 0x80119484,%eax
80106365:	83 e0 1f             	and    $0x1f,%eax
80106368:	a2 84 94 11 80       	mov    %al,0x80119484
8010636d:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
80106374:	83 c8 0f             	or     $0xf,%eax
80106377:	a2 85 94 11 80       	mov    %al,0x80119485
8010637c:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
80106383:	83 e0 ef             	and    $0xffffffef,%eax
80106386:	a2 85 94 11 80       	mov    %al,0x80119485
8010638b:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
80106392:	83 c8 60             	or     $0x60,%eax
80106395:	a2 85 94 11 80       	mov    %al,0x80119485
8010639a:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
801063a1:	83 c8 80             	or     $0xffffff80,%eax
801063a4:	a2 85 94 11 80       	mov    %al,0x80119485
801063a9:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
801063ae:	c1 e8 10             	shr    $0x10,%eax
801063b1:	66 a3 86 94 11 80    	mov    %ax,0x80119486

  initlock(&tickslock, "time");
801063b7:	83 ec 08             	sub    $0x8,%esp
801063ba:	68 3c a8 10 80       	push   $0x8010a83c
801063bf:	68 80 9a 11 80       	push   $0x80119a80
801063c4:	e8 ed e7 ff ff       	call   80104bb6 <initlock>
801063c9:	83 c4 10             	add    $0x10,%esp
}
801063cc:	90                   	nop
801063cd:	c9                   	leave  
801063ce:	c3                   	ret    

801063cf <idtinit>:

void
idtinit(void)
{
801063cf:	55                   	push   %ebp
801063d0:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801063d2:	68 00 08 00 00       	push   $0x800
801063d7:	68 80 92 11 80       	push   $0x80119280
801063dc:	e8 3d fe ff ff       	call   8010621e <lidt>
801063e1:	83 c4 08             	add    $0x8,%esp
}
801063e4:	90                   	nop
801063e5:	c9                   	leave  
801063e6:	c3                   	ret    

801063e7 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801063e7:	55                   	push   %ebp
801063e8:	89 e5                	mov    %esp,%ebp
801063ea:	57                   	push   %edi
801063eb:	56                   	push   %esi
801063ec:	53                   	push   %ebx
801063ed:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801063f0:	8b 45 08             	mov    0x8(%ebp),%eax
801063f3:	8b 40 30             	mov    0x30(%eax),%eax
801063f6:	83 f8 40             	cmp    $0x40,%eax
801063f9:	75 3b                	jne    80106436 <trap+0x4f>
    if(myproc()->killed)
801063fb:	e8 14 db ff ff       	call   80103f14 <myproc>
80106400:	8b 40 24             	mov    0x24(%eax),%eax
80106403:	85 c0                	test   %eax,%eax
80106405:	74 05                	je     8010640c <trap+0x25>
      exit();
80106407:	e8 80 df ff ff       	call   8010438c <exit>
    myproc()->tf = tf;
8010640c:	e8 03 db ff ff       	call   80103f14 <myproc>
80106411:	8b 55 08             	mov    0x8(%ebp),%edx
80106414:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106417:	e8 29 ee ff ff       	call   80105245 <syscall>
    if(myproc()->killed)
8010641c:	e8 f3 da ff ff       	call   80103f14 <myproc>
80106421:	8b 40 24             	mov    0x24(%eax),%eax
80106424:	85 c0                	test   %eax,%eax
80106426:	0f 84 15 02 00 00    	je     80106641 <trap+0x25a>
      exit();
8010642c:	e8 5b df ff ff       	call   8010438c <exit>
    return;
80106431:	e9 0b 02 00 00       	jmp    80106641 <trap+0x25a>
  }

  switch(tf->trapno){
80106436:	8b 45 08             	mov    0x8(%ebp),%eax
80106439:	8b 40 30             	mov    0x30(%eax),%eax
8010643c:	83 e8 20             	sub    $0x20,%eax
8010643f:	83 f8 1f             	cmp    $0x1f,%eax
80106442:	0f 87 c4 00 00 00    	ja     8010650c <trap+0x125>
80106448:	8b 04 85 e4 a8 10 80 	mov    -0x7fef571c(,%eax,4),%eax
8010644f:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106451:	e8 2b da ff ff       	call   80103e81 <cpuid>
80106456:	85 c0                	test   %eax,%eax
80106458:	75 3d                	jne    80106497 <trap+0xb0>
      acquire(&tickslock);
8010645a:	83 ec 0c             	sub    $0xc,%esp
8010645d:	68 80 9a 11 80       	push   $0x80119a80
80106462:	e8 71 e7 ff ff       	call   80104bd8 <acquire>
80106467:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010646a:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
8010646f:	83 c0 01             	add    $0x1,%eax
80106472:	a3 b4 9a 11 80       	mov    %eax,0x80119ab4
      wakeup(&ticks);
80106477:	83 ec 0c             	sub    $0xc,%esp
8010647a:	68 b4 9a 11 80       	push   $0x80119ab4
8010647f:	e8 20 e4 ff ff       	call   801048a4 <wakeup>
80106484:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106487:	83 ec 0c             	sub    $0xc,%esp
8010648a:	68 80 9a 11 80       	push   $0x80119a80
8010648f:	e8 b2 e7 ff ff       	call   80104c46 <release>
80106494:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106497:	e8 64 cb ff ff       	call   80103000 <lapiceoi>
    //현재 진행 중인 프로세스의 스케쥴 주소 넣어야 함
    break;
8010649c:	e9 20 01 00 00       	jmp    801065c1 <trap+0x1da>
  //   }
  // }
  // lapiceoi();
  // return;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801064a1:	e8 b0 c3 ff ff       	call   80102856 <ideintr>
    lapiceoi();
801064a6:	e8 55 cb ff ff       	call   80103000 <lapiceoi>
    break;
801064ab:	e9 11 01 00 00       	jmp    801065c1 <trap+0x1da>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801064b0:	e8 90 c9 ff ff       	call   80102e45 <kbdintr>
    lapiceoi();
801064b5:	e8 46 cb ff ff       	call   80103000 <lapiceoi>
    break;
801064ba:	e9 02 01 00 00       	jmp    801065c1 <trap+0x1da>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801064bf:	e8 53 03 00 00       	call   80106817 <uartintr>
    lapiceoi();
801064c4:	e8 37 cb ff ff       	call   80103000 <lapiceoi>
    break;
801064c9:	e9 f3 00 00 00       	jmp    801065c1 <trap+0x1da>
  case T_IRQ0 + 0xB:
    i8254_intr();
801064ce:	e8 7b 2b 00 00       	call   8010904e <i8254_intr>
    lapiceoi();
801064d3:	e8 28 cb ff ff       	call   80103000 <lapiceoi>
    break;
801064d8:	e9 e4 00 00 00       	jmp    801065c1 <trap+0x1da>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801064dd:	8b 45 08             	mov    0x8(%ebp),%eax
801064e0:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801064e3:	8b 45 08             	mov    0x8(%ebp),%eax
801064e6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801064ea:	0f b7 d8             	movzwl %ax,%ebx
801064ed:	e8 8f d9 ff ff       	call   80103e81 <cpuid>
801064f2:	56                   	push   %esi
801064f3:	53                   	push   %ebx
801064f4:	50                   	push   %eax
801064f5:	68 44 a8 10 80       	push   $0x8010a844
801064fa:	e8 f5 9e ff ff       	call   801003f4 <cprintf>
801064ff:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106502:	e8 f9 ca ff ff       	call   80103000 <lapiceoi>
    break;
80106507:	e9 b5 00 00 00       	jmp    801065c1 <trap+0x1da>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010650c:	e8 03 da ff ff       	call   80103f14 <myproc>
80106511:	85 c0                	test   %eax,%eax
80106513:	74 11                	je     80106526 <trap+0x13f>
80106515:	8b 45 08             	mov    0x8(%ebp),%eax
80106518:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010651c:	0f b7 c0             	movzwl %ax,%eax
8010651f:	83 e0 03             	and    $0x3,%eax
80106522:	85 c0                	test   %eax,%eax
80106524:	75 39                	jne    8010655f <trap+0x178>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106526:	e8 1d fd ff ff       	call   80106248 <rcr2>
8010652b:	89 c3                	mov    %eax,%ebx
8010652d:	8b 45 08             	mov    0x8(%ebp),%eax
80106530:	8b 70 38             	mov    0x38(%eax),%esi
80106533:	e8 49 d9 ff ff       	call   80103e81 <cpuid>
80106538:	8b 55 08             	mov    0x8(%ebp),%edx
8010653b:	8b 52 30             	mov    0x30(%edx),%edx
8010653e:	83 ec 0c             	sub    $0xc,%esp
80106541:	53                   	push   %ebx
80106542:	56                   	push   %esi
80106543:	50                   	push   %eax
80106544:	52                   	push   %edx
80106545:	68 68 a8 10 80       	push   $0x8010a868
8010654a:	e8 a5 9e ff ff       	call   801003f4 <cprintf>
8010654f:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106552:	83 ec 0c             	sub    $0xc,%esp
80106555:	68 9a a8 10 80       	push   $0x8010a89a
8010655a:	e8 4a a0 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010655f:	e8 e4 fc ff ff       	call   80106248 <rcr2>
80106564:	89 c6                	mov    %eax,%esi
80106566:	8b 45 08             	mov    0x8(%ebp),%eax
80106569:	8b 40 38             	mov    0x38(%eax),%eax
8010656c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010656f:	e8 0d d9 ff ff       	call   80103e81 <cpuid>
80106574:	89 c3                	mov    %eax,%ebx
80106576:	8b 45 08             	mov    0x8(%ebp),%eax
80106579:	8b 48 34             	mov    0x34(%eax),%ecx
8010657c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
8010657f:	8b 45 08             	mov    0x8(%ebp),%eax
80106582:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106585:	e8 8a d9 ff ff       	call   80103f14 <myproc>
8010658a:	8d 50 6c             	lea    0x6c(%eax),%edx
8010658d:	89 55 dc             	mov    %edx,-0x24(%ebp)
80106590:	e8 7f d9 ff ff       	call   80103f14 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106595:	8b 40 10             	mov    0x10(%eax),%eax
80106598:	56                   	push   %esi
80106599:	ff 75 e4             	push   -0x1c(%ebp)
8010659c:	53                   	push   %ebx
8010659d:	ff 75 e0             	push   -0x20(%ebp)
801065a0:	57                   	push   %edi
801065a1:	ff 75 dc             	push   -0x24(%ebp)
801065a4:	50                   	push   %eax
801065a5:	68 a0 a8 10 80       	push   $0x8010a8a0
801065aa:	e8 45 9e ff ff       	call   801003f4 <cprintf>
801065af:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801065b2:	e8 5d d9 ff ff       	call   80103f14 <myproc>
801065b7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801065be:	eb 01                	jmp    801065c1 <trap+0x1da>
    break;
801065c0:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801065c1:	e8 4e d9 ff ff       	call   80103f14 <myproc>
801065c6:	85 c0                	test   %eax,%eax
801065c8:	74 23                	je     801065ed <trap+0x206>
801065ca:	e8 45 d9 ff ff       	call   80103f14 <myproc>
801065cf:	8b 40 24             	mov    0x24(%eax),%eax
801065d2:	85 c0                	test   %eax,%eax
801065d4:	74 17                	je     801065ed <trap+0x206>
801065d6:	8b 45 08             	mov    0x8(%ebp),%eax
801065d9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801065dd:	0f b7 c0             	movzwl %ax,%eax
801065e0:	83 e0 03             	and    $0x3,%eax
801065e3:	83 f8 03             	cmp    $0x3,%eax
801065e6:	75 05                	jne    801065ed <trap+0x206>
    exit();
801065e8:	e8 9f dd ff ff       	call   8010438c <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801065ed:	e8 22 d9 ff ff       	call   80103f14 <myproc>
801065f2:	85 c0                	test   %eax,%eax
801065f4:	74 1d                	je     80106613 <trap+0x22c>
801065f6:	e8 19 d9 ff ff       	call   80103f14 <myproc>
801065fb:	8b 40 0c             	mov    0xc(%eax),%eax
801065fe:	83 f8 04             	cmp    $0x4,%eax
80106601:	75 10                	jne    80106613 <trap+0x22c>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106603:	8b 45 08             	mov    0x8(%ebp),%eax
80106606:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106609:	83 f8 20             	cmp    $0x20,%eax
8010660c:	75 05                	jne    80106613 <trap+0x22c>
    yield();
8010660e:	e8 2a e1 ff ff       	call   8010473d <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106613:	e8 fc d8 ff ff       	call   80103f14 <myproc>
80106618:	85 c0                	test   %eax,%eax
8010661a:	74 26                	je     80106642 <trap+0x25b>
8010661c:	e8 f3 d8 ff ff       	call   80103f14 <myproc>
80106621:	8b 40 24             	mov    0x24(%eax),%eax
80106624:	85 c0                	test   %eax,%eax
80106626:	74 1a                	je     80106642 <trap+0x25b>
80106628:	8b 45 08             	mov    0x8(%ebp),%eax
8010662b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010662f:	0f b7 c0             	movzwl %ax,%eax
80106632:	83 e0 03             	and    $0x3,%eax
80106635:	83 f8 03             	cmp    $0x3,%eax
80106638:	75 08                	jne    80106642 <trap+0x25b>
    exit();
8010663a:	e8 4d dd ff ff       	call   8010438c <exit>
8010663f:	eb 01                	jmp    80106642 <trap+0x25b>
    return;
80106641:	90                   	nop
}
80106642:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106645:	5b                   	pop    %ebx
80106646:	5e                   	pop    %esi
80106647:	5f                   	pop    %edi
80106648:	5d                   	pop    %ebp
80106649:	c3                   	ret    

8010664a <inb>:
{
8010664a:	55                   	push   %ebp
8010664b:	89 e5                	mov    %esp,%ebp
8010664d:	83 ec 14             	sub    $0x14,%esp
80106650:	8b 45 08             	mov    0x8(%ebp),%eax
80106653:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106657:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010665b:	89 c2                	mov    %eax,%edx
8010665d:	ec                   	in     (%dx),%al
8010665e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106661:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106665:	c9                   	leave  
80106666:	c3                   	ret    

80106667 <outb>:
{
80106667:	55                   	push   %ebp
80106668:	89 e5                	mov    %esp,%ebp
8010666a:	83 ec 08             	sub    $0x8,%esp
8010666d:	8b 45 08             	mov    0x8(%ebp),%eax
80106670:	8b 55 0c             	mov    0xc(%ebp),%edx
80106673:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106677:	89 d0                	mov    %edx,%eax
80106679:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010667c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106680:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106684:	ee                   	out    %al,(%dx)
}
80106685:	90                   	nop
80106686:	c9                   	leave  
80106687:	c3                   	ret    

80106688 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106688:	55                   	push   %ebp
80106689:	89 e5                	mov    %esp,%ebp
8010668b:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010668e:	6a 00                	push   $0x0
80106690:	68 fa 03 00 00       	push   $0x3fa
80106695:	e8 cd ff ff ff       	call   80106667 <outb>
8010669a:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010669d:	68 80 00 00 00       	push   $0x80
801066a2:	68 fb 03 00 00       	push   $0x3fb
801066a7:	e8 bb ff ff ff       	call   80106667 <outb>
801066ac:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801066af:	6a 0c                	push   $0xc
801066b1:	68 f8 03 00 00       	push   $0x3f8
801066b6:	e8 ac ff ff ff       	call   80106667 <outb>
801066bb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801066be:	6a 00                	push   $0x0
801066c0:	68 f9 03 00 00       	push   $0x3f9
801066c5:	e8 9d ff ff ff       	call   80106667 <outb>
801066ca:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801066cd:	6a 03                	push   $0x3
801066cf:	68 fb 03 00 00       	push   $0x3fb
801066d4:	e8 8e ff ff ff       	call   80106667 <outb>
801066d9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801066dc:	6a 00                	push   $0x0
801066de:	68 fc 03 00 00       	push   $0x3fc
801066e3:	e8 7f ff ff ff       	call   80106667 <outb>
801066e8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801066eb:	6a 01                	push   $0x1
801066ed:	68 f9 03 00 00       	push   $0x3f9
801066f2:	e8 70 ff ff ff       	call   80106667 <outb>
801066f7:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801066fa:	68 fd 03 00 00       	push   $0x3fd
801066ff:	e8 46 ff ff ff       	call   8010664a <inb>
80106704:	83 c4 04             	add    $0x4,%esp
80106707:	3c ff                	cmp    $0xff,%al
80106709:	74 61                	je     8010676c <uartinit+0xe4>
    return;
  uart = 1;
8010670b:	c7 05 b8 9a 11 80 01 	movl   $0x1,0x80119ab8
80106712:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106715:	68 fa 03 00 00       	push   $0x3fa
8010671a:	e8 2b ff ff ff       	call   8010664a <inb>
8010671f:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106722:	68 f8 03 00 00       	push   $0x3f8
80106727:	e8 1e ff ff ff       	call   8010664a <inb>
8010672c:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010672f:	83 ec 08             	sub    $0x8,%esp
80106732:	6a 00                	push   $0x0
80106734:	6a 04                	push   $0x4
80106736:	e8 d7 c3 ff ff       	call   80102b12 <ioapicenable>
8010673b:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010673e:	c7 45 f4 64 a9 10 80 	movl   $0x8010a964,-0xc(%ebp)
80106745:	eb 19                	jmp    80106760 <uartinit+0xd8>
    uartputc(*p);
80106747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674a:	0f b6 00             	movzbl (%eax),%eax
8010674d:	0f be c0             	movsbl %al,%eax
80106750:	83 ec 0c             	sub    $0xc,%esp
80106753:	50                   	push   %eax
80106754:	e8 16 00 00 00       	call   8010676f <uartputc>
80106759:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010675c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106763:	0f b6 00             	movzbl (%eax),%eax
80106766:	84 c0                	test   %al,%al
80106768:	75 dd                	jne    80106747 <uartinit+0xbf>
8010676a:	eb 01                	jmp    8010676d <uartinit+0xe5>
    return;
8010676c:	90                   	nop
}
8010676d:	c9                   	leave  
8010676e:	c3                   	ret    

8010676f <uartputc>:

void
uartputc(int c)
{
8010676f:	55                   	push   %ebp
80106770:	89 e5                	mov    %esp,%ebp
80106772:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106775:	a1 b8 9a 11 80       	mov    0x80119ab8,%eax
8010677a:	85 c0                	test   %eax,%eax
8010677c:	74 53                	je     801067d1 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010677e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106785:	eb 11                	jmp    80106798 <uartputc+0x29>
    microdelay(10);
80106787:	83 ec 0c             	sub    $0xc,%esp
8010678a:	6a 0a                	push   $0xa
8010678c:	e8 8a c8 ff ff       	call   8010301b <microdelay>
80106791:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106794:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106798:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010679c:	7f 1a                	jg     801067b8 <uartputc+0x49>
8010679e:	83 ec 0c             	sub    $0xc,%esp
801067a1:	68 fd 03 00 00       	push   $0x3fd
801067a6:	e8 9f fe ff ff       	call   8010664a <inb>
801067ab:	83 c4 10             	add    $0x10,%esp
801067ae:	0f b6 c0             	movzbl %al,%eax
801067b1:	83 e0 20             	and    $0x20,%eax
801067b4:	85 c0                	test   %eax,%eax
801067b6:	74 cf                	je     80106787 <uartputc+0x18>
  outb(COM1+0, c);
801067b8:	8b 45 08             	mov    0x8(%ebp),%eax
801067bb:	0f b6 c0             	movzbl %al,%eax
801067be:	83 ec 08             	sub    $0x8,%esp
801067c1:	50                   	push   %eax
801067c2:	68 f8 03 00 00       	push   $0x3f8
801067c7:	e8 9b fe ff ff       	call   80106667 <outb>
801067cc:	83 c4 10             	add    $0x10,%esp
801067cf:	eb 01                	jmp    801067d2 <uartputc+0x63>
    return;
801067d1:	90                   	nop
}
801067d2:	c9                   	leave  
801067d3:	c3                   	ret    

801067d4 <uartgetc>:

static int
uartgetc(void)
{
801067d4:	55                   	push   %ebp
801067d5:	89 e5                	mov    %esp,%ebp
  if(!uart)
801067d7:	a1 b8 9a 11 80       	mov    0x80119ab8,%eax
801067dc:	85 c0                	test   %eax,%eax
801067de:	75 07                	jne    801067e7 <uartgetc+0x13>
    return -1;
801067e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067e5:	eb 2e                	jmp    80106815 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801067e7:	68 fd 03 00 00       	push   $0x3fd
801067ec:	e8 59 fe ff ff       	call   8010664a <inb>
801067f1:	83 c4 04             	add    $0x4,%esp
801067f4:	0f b6 c0             	movzbl %al,%eax
801067f7:	83 e0 01             	and    $0x1,%eax
801067fa:	85 c0                	test   %eax,%eax
801067fc:	75 07                	jne    80106805 <uartgetc+0x31>
    return -1;
801067fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106803:	eb 10                	jmp    80106815 <uartgetc+0x41>
  return inb(COM1+0);
80106805:	68 f8 03 00 00       	push   $0x3f8
8010680a:	e8 3b fe ff ff       	call   8010664a <inb>
8010680f:	83 c4 04             	add    $0x4,%esp
80106812:	0f b6 c0             	movzbl %al,%eax
}
80106815:	c9                   	leave  
80106816:	c3                   	ret    

80106817 <uartintr>:

void
uartintr(void)
{
80106817:	55                   	push   %ebp
80106818:	89 e5                	mov    %esp,%ebp
8010681a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010681d:	83 ec 0c             	sub    $0xc,%esp
80106820:	68 d4 67 10 80       	push   $0x801067d4
80106825:	e8 ac 9f ff ff       	call   801007d6 <consoleintr>
8010682a:	83 c4 10             	add    $0x10,%esp
}
8010682d:	90                   	nop
8010682e:	c9                   	leave  
8010682f:	c3                   	ret    

80106830 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106830:	6a 00                	push   $0x0
  pushl $0
80106832:	6a 00                	push   $0x0
  jmp alltraps
80106834:	e9 c2 f9 ff ff       	jmp    801061fb <alltraps>

80106839 <vector1>:
.globl vector1
vector1:
  pushl $0
80106839:	6a 00                	push   $0x0
  pushl $1
8010683b:	6a 01                	push   $0x1
  jmp alltraps
8010683d:	e9 b9 f9 ff ff       	jmp    801061fb <alltraps>

80106842 <vector2>:
.globl vector2
vector2:
  pushl $0
80106842:	6a 00                	push   $0x0
  pushl $2
80106844:	6a 02                	push   $0x2
  jmp alltraps
80106846:	e9 b0 f9 ff ff       	jmp    801061fb <alltraps>

8010684b <vector3>:
.globl vector3
vector3:
  pushl $0
8010684b:	6a 00                	push   $0x0
  pushl $3
8010684d:	6a 03                	push   $0x3
  jmp alltraps
8010684f:	e9 a7 f9 ff ff       	jmp    801061fb <alltraps>

80106854 <vector4>:
.globl vector4
vector4:
  pushl $0
80106854:	6a 00                	push   $0x0
  pushl $4
80106856:	6a 04                	push   $0x4
  jmp alltraps
80106858:	e9 9e f9 ff ff       	jmp    801061fb <alltraps>

8010685d <vector5>:
.globl vector5
vector5:
  pushl $0
8010685d:	6a 00                	push   $0x0
  pushl $5
8010685f:	6a 05                	push   $0x5
  jmp alltraps
80106861:	e9 95 f9 ff ff       	jmp    801061fb <alltraps>

80106866 <vector6>:
.globl vector6
vector6:
  pushl $0
80106866:	6a 00                	push   $0x0
  pushl $6
80106868:	6a 06                	push   $0x6
  jmp alltraps
8010686a:	e9 8c f9 ff ff       	jmp    801061fb <alltraps>

8010686f <vector7>:
.globl vector7
vector7:
  pushl $0
8010686f:	6a 00                	push   $0x0
  pushl $7
80106871:	6a 07                	push   $0x7
  jmp alltraps
80106873:	e9 83 f9 ff ff       	jmp    801061fb <alltraps>

80106878 <vector8>:
.globl vector8
vector8:
  pushl $8
80106878:	6a 08                	push   $0x8
  jmp alltraps
8010687a:	e9 7c f9 ff ff       	jmp    801061fb <alltraps>

8010687f <vector9>:
.globl vector9
vector9:
  pushl $0
8010687f:	6a 00                	push   $0x0
  pushl $9
80106881:	6a 09                	push   $0x9
  jmp alltraps
80106883:	e9 73 f9 ff ff       	jmp    801061fb <alltraps>

80106888 <vector10>:
.globl vector10
vector10:
  pushl $10
80106888:	6a 0a                	push   $0xa
  jmp alltraps
8010688a:	e9 6c f9 ff ff       	jmp    801061fb <alltraps>

8010688f <vector11>:
.globl vector11
vector11:
  pushl $11
8010688f:	6a 0b                	push   $0xb
  jmp alltraps
80106891:	e9 65 f9 ff ff       	jmp    801061fb <alltraps>

80106896 <vector12>:
.globl vector12
vector12:
  pushl $12
80106896:	6a 0c                	push   $0xc
  jmp alltraps
80106898:	e9 5e f9 ff ff       	jmp    801061fb <alltraps>

8010689d <vector13>:
.globl vector13
vector13:
  pushl $13
8010689d:	6a 0d                	push   $0xd
  jmp alltraps
8010689f:	e9 57 f9 ff ff       	jmp    801061fb <alltraps>

801068a4 <vector14>:
.globl vector14
vector14:
  pushl $14
801068a4:	6a 0e                	push   $0xe
  jmp alltraps
801068a6:	e9 50 f9 ff ff       	jmp    801061fb <alltraps>

801068ab <vector15>:
.globl vector15
vector15:
  pushl $0
801068ab:	6a 00                	push   $0x0
  pushl $15
801068ad:	6a 0f                	push   $0xf
  jmp alltraps
801068af:	e9 47 f9 ff ff       	jmp    801061fb <alltraps>

801068b4 <vector16>:
.globl vector16
vector16:
  pushl $0
801068b4:	6a 00                	push   $0x0
  pushl $16
801068b6:	6a 10                	push   $0x10
  jmp alltraps
801068b8:	e9 3e f9 ff ff       	jmp    801061fb <alltraps>

801068bd <vector17>:
.globl vector17
vector17:
  pushl $17
801068bd:	6a 11                	push   $0x11
  jmp alltraps
801068bf:	e9 37 f9 ff ff       	jmp    801061fb <alltraps>

801068c4 <vector18>:
.globl vector18
vector18:
  pushl $0
801068c4:	6a 00                	push   $0x0
  pushl $18
801068c6:	6a 12                	push   $0x12
  jmp alltraps
801068c8:	e9 2e f9 ff ff       	jmp    801061fb <alltraps>

801068cd <vector19>:
.globl vector19
vector19:
  pushl $0
801068cd:	6a 00                	push   $0x0
  pushl $19
801068cf:	6a 13                	push   $0x13
  jmp alltraps
801068d1:	e9 25 f9 ff ff       	jmp    801061fb <alltraps>

801068d6 <vector20>:
.globl vector20
vector20:
  pushl $0
801068d6:	6a 00                	push   $0x0
  pushl $20
801068d8:	6a 14                	push   $0x14
  jmp alltraps
801068da:	e9 1c f9 ff ff       	jmp    801061fb <alltraps>

801068df <vector21>:
.globl vector21
vector21:
  pushl $0
801068df:	6a 00                	push   $0x0
  pushl $21
801068e1:	6a 15                	push   $0x15
  jmp alltraps
801068e3:	e9 13 f9 ff ff       	jmp    801061fb <alltraps>

801068e8 <vector22>:
.globl vector22
vector22:
  pushl $0
801068e8:	6a 00                	push   $0x0
  pushl $22
801068ea:	6a 16                	push   $0x16
  jmp alltraps
801068ec:	e9 0a f9 ff ff       	jmp    801061fb <alltraps>

801068f1 <vector23>:
.globl vector23
vector23:
  pushl $0
801068f1:	6a 00                	push   $0x0
  pushl $23
801068f3:	6a 17                	push   $0x17
  jmp alltraps
801068f5:	e9 01 f9 ff ff       	jmp    801061fb <alltraps>

801068fa <vector24>:
.globl vector24
vector24:
  pushl $0
801068fa:	6a 00                	push   $0x0
  pushl $24
801068fc:	6a 18                	push   $0x18
  jmp alltraps
801068fe:	e9 f8 f8 ff ff       	jmp    801061fb <alltraps>

80106903 <vector25>:
.globl vector25
vector25:
  pushl $0
80106903:	6a 00                	push   $0x0
  pushl $25
80106905:	6a 19                	push   $0x19
  jmp alltraps
80106907:	e9 ef f8 ff ff       	jmp    801061fb <alltraps>

8010690c <vector26>:
.globl vector26
vector26:
  pushl $0
8010690c:	6a 00                	push   $0x0
  pushl $26
8010690e:	6a 1a                	push   $0x1a
  jmp alltraps
80106910:	e9 e6 f8 ff ff       	jmp    801061fb <alltraps>

80106915 <vector27>:
.globl vector27
vector27:
  pushl $0
80106915:	6a 00                	push   $0x0
  pushl $27
80106917:	6a 1b                	push   $0x1b
  jmp alltraps
80106919:	e9 dd f8 ff ff       	jmp    801061fb <alltraps>

8010691e <vector28>:
.globl vector28
vector28:
  pushl $0
8010691e:	6a 00                	push   $0x0
  pushl $28
80106920:	6a 1c                	push   $0x1c
  jmp alltraps
80106922:	e9 d4 f8 ff ff       	jmp    801061fb <alltraps>

80106927 <vector29>:
.globl vector29
vector29:
  pushl $0
80106927:	6a 00                	push   $0x0
  pushl $29
80106929:	6a 1d                	push   $0x1d
  jmp alltraps
8010692b:	e9 cb f8 ff ff       	jmp    801061fb <alltraps>

80106930 <vector30>:
.globl vector30
vector30:
  pushl $0
80106930:	6a 00                	push   $0x0
  pushl $30
80106932:	6a 1e                	push   $0x1e
  jmp alltraps
80106934:	e9 c2 f8 ff ff       	jmp    801061fb <alltraps>

80106939 <vector31>:
.globl vector31
vector31:
  pushl $0
80106939:	6a 00                	push   $0x0
  pushl $31
8010693b:	6a 1f                	push   $0x1f
  jmp alltraps
8010693d:	e9 b9 f8 ff ff       	jmp    801061fb <alltraps>

80106942 <vector32>:
.globl vector32
vector32:
  pushl $0
80106942:	6a 00                	push   $0x0
  pushl $32
80106944:	6a 20                	push   $0x20
  jmp alltraps
80106946:	e9 b0 f8 ff ff       	jmp    801061fb <alltraps>

8010694b <vector33>:
.globl vector33
vector33:
  pushl $0
8010694b:	6a 00                	push   $0x0
  pushl $33
8010694d:	6a 21                	push   $0x21
  jmp alltraps
8010694f:	e9 a7 f8 ff ff       	jmp    801061fb <alltraps>

80106954 <vector34>:
.globl vector34
vector34:
  pushl $0
80106954:	6a 00                	push   $0x0
  pushl $34
80106956:	6a 22                	push   $0x22
  jmp alltraps
80106958:	e9 9e f8 ff ff       	jmp    801061fb <alltraps>

8010695d <vector35>:
.globl vector35
vector35:
  pushl $0
8010695d:	6a 00                	push   $0x0
  pushl $35
8010695f:	6a 23                	push   $0x23
  jmp alltraps
80106961:	e9 95 f8 ff ff       	jmp    801061fb <alltraps>

80106966 <vector36>:
.globl vector36
vector36:
  pushl $0
80106966:	6a 00                	push   $0x0
  pushl $36
80106968:	6a 24                	push   $0x24
  jmp alltraps
8010696a:	e9 8c f8 ff ff       	jmp    801061fb <alltraps>

8010696f <vector37>:
.globl vector37
vector37:
  pushl $0
8010696f:	6a 00                	push   $0x0
  pushl $37
80106971:	6a 25                	push   $0x25
  jmp alltraps
80106973:	e9 83 f8 ff ff       	jmp    801061fb <alltraps>

80106978 <vector38>:
.globl vector38
vector38:
  pushl $0
80106978:	6a 00                	push   $0x0
  pushl $38
8010697a:	6a 26                	push   $0x26
  jmp alltraps
8010697c:	e9 7a f8 ff ff       	jmp    801061fb <alltraps>

80106981 <vector39>:
.globl vector39
vector39:
  pushl $0
80106981:	6a 00                	push   $0x0
  pushl $39
80106983:	6a 27                	push   $0x27
  jmp alltraps
80106985:	e9 71 f8 ff ff       	jmp    801061fb <alltraps>

8010698a <vector40>:
.globl vector40
vector40:
  pushl $0
8010698a:	6a 00                	push   $0x0
  pushl $40
8010698c:	6a 28                	push   $0x28
  jmp alltraps
8010698e:	e9 68 f8 ff ff       	jmp    801061fb <alltraps>

80106993 <vector41>:
.globl vector41
vector41:
  pushl $0
80106993:	6a 00                	push   $0x0
  pushl $41
80106995:	6a 29                	push   $0x29
  jmp alltraps
80106997:	e9 5f f8 ff ff       	jmp    801061fb <alltraps>

8010699c <vector42>:
.globl vector42
vector42:
  pushl $0
8010699c:	6a 00                	push   $0x0
  pushl $42
8010699e:	6a 2a                	push   $0x2a
  jmp alltraps
801069a0:	e9 56 f8 ff ff       	jmp    801061fb <alltraps>

801069a5 <vector43>:
.globl vector43
vector43:
  pushl $0
801069a5:	6a 00                	push   $0x0
  pushl $43
801069a7:	6a 2b                	push   $0x2b
  jmp alltraps
801069a9:	e9 4d f8 ff ff       	jmp    801061fb <alltraps>

801069ae <vector44>:
.globl vector44
vector44:
  pushl $0
801069ae:	6a 00                	push   $0x0
  pushl $44
801069b0:	6a 2c                	push   $0x2c
  jmp alltraps
801069b2:	e9 44 f8 ff ff       	jmp    801061fb <alltraps>

801069b7 <vector45>:
.globl vector45
vector45:
  pushl $0
801069b7:	6a 00                	push   $0x0
  pushl $45
801069b9:	6a 2d                	push   $0x2d
  jmp alltraps
801069bb:	e9 3b f8 ff ff       	jmp    801061fb <alltraps>

801069c0 <vector46>:
.globl vector46
vector46:
  pushl $0
801069c0:	6a 00                	push   $0x0
  pushl $46
801069c2:	6a 2e                	push   $0x2e
  jmp alltraps
801069c4:	e9 32 f8 ff ff       	jmp    801061fb <alltraps>

801069c9 <vector47>:
.globl vector47
vector47:
  pushl $0
801069c9:	6a 00                	push   $0x0
  pushl $47
801069cb:	6a 2f                	push   $0x2f
  jmp alltraps
801069cd:	e9 29 f8 ff ff       	jmp    801061fb <alltraps>

801069d2 <vector48>:
.globl vector48
vector48:
  pushl $0
801069d2:	6a 00                	push   $0x0
  pushl $48
801069d4:	6a 30                	push   $0x30
  jmp alltraps
801069d6:	e9 20 f8 ff ff       	jmp    801061fb <alltraps>

801069db <vector49>:
.globl vector49
vector49:
  pushl $0
801069db:	6a 00                	push   $0x0
  pushl $49
801069dd:	6a 31                	push   $0x31
  jmp alltraps
801069df:	e9 17 f8 ff ff       	jmp    801061fb <alltraps>

801069e4 <vector50>:
.globl vector50
vector50:
  pushl $0
801069e4:	6a 00                	push   $0x0
  pushl $50
801069e6:	6a 32                	push   $0x32
  jmp alltraps
801069e8:	e9 0e f8 ff ff       	jmp    801061fb <alltraps>

801069ed <vector51>:
.globl vector51
vector51:
  pushl $0
801069ed:	6a 00                	push   $0x0
  pushl $51
801069ef:	6a 33                	push   $0x33
  jmp alltraps
801069f1:	e9 05 f8 ff ff       	jmp    801061fb <alltraps>

801069f6 <vector52>:
.globl vector52
vector52:
  pushl $0
801069f6:	6a 00                	push   $0x0
  pushl $52
801069f8:	6a 34                	push   $0x34
  jmp alltraps
801069fa:	e9 fc f7 ff ff       	jmp    801061fb <alltraps>

801069ff <vector53>:
.globl vector53
vector53:
  pushl $0
801069ff:	6a 00                	push   $0x0
  pushl $53
80106a01:	6a 35                	push   $0x35
  jmp alltraps
80106a03:	e9 f3 f7 ff ff       	jmp    801061fb <alltraps>

80106a08 <vector54>:
.globl vector54
vector54:
  pushl $0
80106a08:	6a 00                	push   $0x0
  pushl $54
80106a0a:	6a 36                	push   $0x36
  jmp alltraps
80106a0c:	e9 ea f7 ff ff       	jmp    801061fb <alltraps>

80106a11 <vector55>:
.globl vector55
vector55:
  pushl $0
80106a11:	6a 00                	push   $0x0
  pushl $55
80106a13:	6a 37                	push   $0x37
  jmp alltraps
80106a15:	e9 e1 f7 ff ff       	jmp    801061fb <alltraps>

80106a1a <vector56>:
.globl vector56
vector56:
  pushl $0
80106a1a:	6a 00                	push   $0x0
  pushl $56
80106a1c:	6a 38                	push   $0x38
  jmp alltraps
80106a1e:	e9 d8 f7 ff ff       	jmp    801061fb <alltraps>

80106a23 <vector57>:
.globl vector57
vector57:
  pushl $0
80106a23:	6a 00                	push   $0x0
  pushl $57
80106a25:	6a 39                	push   $0x39
  jmp alltraps
80106a27:	e9 cf f7 ff ff       	jmp    801061fb <alltraps>

80106a2c <vector58>:
.globl vector58
vector58:
  pushl $0
80106a2c:	6a 00                	push   $0x0
  pushl $58
80106a2e:	6a 3a                	push   $0x3a
  jmp alltraps
80106a30:	e9 c6 f7 ff ff       	jmp    801061fb <alltraps>

80106a35 <vector59>:
.globl vector59
vector59:
  pushl $0
80106a35:	6a 00                	push   $0x0
  pushl $59
80106a37:	6a 3b                	push   $0x3b
  jmp alltraps
80106a39:	e9 bd f7 ff ff       	jmp    801061fb <alltraps>

80106a3e <vector60>:
.globl vector60
vector60:
  pushl $0
80106a3e:	6a 00                	push   $0x0
  pushl $60
80106a40:	6a 3c                	push   $0x3c
  jmp alltraps
80106a42:	e9 b4 f7 ff ff       	jmp    801061fb <alltraps>

80106a47 <vector61>:
.globl vector61
vector61:
  pushl $0
80106a47:	6a 00                	push   $0x0
  pushl $61
80106a49:	6a 3d                	push   $0x3d
  jmp alltraps
80106a4b:	e9 ab f7 ff ff       	jmp    801061fb <alltraps>

80106a50 <vector62>:
.globl vector62
vector62:
  pushl $0
80106a50:	6a 00                	push   $0x0
  pushl $62
80106a52:	6a 3e                	push   $0x3e
  jmp alltraps
80106a54:	e9 a2 f7 ff ff       	jmp    801061fb <alltraps>

80106a59 <vector63>:
.globl vector63
vector63:
  pushl $0
80106a59:	6a 00                	push   $0x0
  pushl $63
80106a5b:	6a 3f                	push   $0x3f
  jmp alltraps
80106a5d:	e9 99 f7 ff ff       	jmp    801061fb <alltraps>

80106a62 <vector64>:
.globl vector64
vector64:
  pushl $0
80106a62:	6a 00                	push   $0x0
  pushl $64
80106a64:	6a 40                	push   $0x40
  jmp alltraps
80106a66:	e9 90 f7 ff ff       	jmp    801061fb <alltraps>

80106a6b <vector65>:
.globl vector65
vector65:
  pushl $0
80106a6b:	6a 00                	push   $0x0
  pushl $65
80106a6d:	6a 41                	push   $0x41
  jmp alltraps
80106a6f:	e9 87 f7 ff ff       	jmp    801061fb <alltraps>

80106a74 <vector66>:
.globl vector66
vector66:
  pushl $0
80106a74:	6a 00                	push   $0x0
  pushl $66
80106a76:	6a 42                	push   $0x42
  jmp alltraps
80106a78:	e9 7e f7 ff ff       	jmp    801061fb <alltraps>

80106a7d <vector67>:
.globl vector67
vector67:
  pushl $0
80106a7d:	6a 00                	push   $0x0
  pushl $67
80106a7f:	6a 43                	push   $0x43
  jmp alltraps
80106a81:	e9 75 f7 ff ff       	jmp    801061fb <alltraps>

80106a86 <vector68>:
.globl vector68
vector68:
  pushl $0
80106a86:	6a 00                	push   $0x0
  pushl $68
80106a88:	6a 44                	push   $0x44
  jmp alltraps
80106a8a:	e9 6c f7 ff ff       	jmp    801061fb <alltraps>

80106a8f <vector69>:
.globl vector69
vector69:
  pushl $0
80106a8f:	6a 00                	push   $0x0
  pushl $69
80106a91:	6a 45                	push   $0x45
  jmp alltraps
80106a93:	e9 63 f7 ff ff       	jmp    801061fb <alltraps>

80106a98 <vector70>:
.globl vector70
vector70:
  pushl $0
80106a98:	6a 00                	push   $0x0
  pushl $70
80106a9a:	6a 46                	push   $0x46
  jmp alltraps
80106a9c:	e9 5a f7 ff ff       	jmp    801061fb <alltraps>

80106aa1 <vector71>:
.globl vector71
vector71:
  pushl $0
80106aa1:	6a 00                	push   $0x0
  pushl $71
80106aa3:	6a 47                	push   $0x47
  jmp alltraps
80106aa5:	e9 51 f7 ff ff       	jmp    801061fb <alltraps>

80106aaa <vector72>:
.globl vector72
vector72:
  pushl $0
80106aaa:	6a 00                	push   $0x0
  pushl $72
80106aac:	6a 48                	push   $0x48
  jmp alltraps
80106aae:	e9 48 f7 ff ff       	jmp    801061fb <alltraps>

80106ab3 <vector73>:
.globl vector73
vector73:
  pushl $0
80106ab3:	6a 00                	push   $0x0
  pushl $73
80106ab5:	6a 49                	push   $0x49
  jmp alltraps
80106ab7:	e9 3f f7 ff ff       	jmp    801061fb <alltraps>

80106abc <vector74>:
.globl vector74
vector74:
  pushl $0
80106abc:	6a 00                	push   $0x0
  pushl $74
80106abe:	6a 4a                	push   $0x4a
  jmp alltraps
80106ac0:	e9 36 f7 ff ff       	jmp    801061fb <alltraps>

80106ac5 <vector75>:
.globl vector75
vector75:
  pushl $0
80106ac5:	6a 00                	push   $0x0
  pushl $75
80106ac7:	6a 4b                	push   $0x4b
  jmp alltraps
80106ac9:	e9 2d f7 ff ff       	jmp    801061fb <alltraps>

80106ace <vector76>:
.globl vector76
vector76:
  pushl $0
80106ace:	6a 00                	push   $0x0
  pushl $76
80106ad0:	6a 4c                	push   $0x4c
  jmp alltraps
80106ad2:	e9 24 f7 ff ff       	jmp    801061fb <alltraps>

80106ad7 <vector77>:
.globl vector77
vector77:
  pushl $0
80106ad7:	6a 00                	push   $0x0
  pushl $77
80106ad9:	6a 4d                	push   $0x4d
  jmp alltraps
80106adb:	e9 1b f7 ff ff       	jmp    801061fb <alltraps>

80106ae0 <vector78>:
.globl vector78
vector78:
  pushl $0
80106ae0:	6a 00                	push   $0x0
  pushl $78
80106ae2:	6a 4e                	push   $0x4e
  jmp alltraps
80106ae4:	e9 12 f7 ff ff       	jmp    801061fb <alltraps>

80106ae9 <vector79>:
.globl vector79
vector79:
  pushl $0
80106ae9:	6a 00                	push   $0x0
  pushl $79
80106aeb:	6a 4f                	push   $0x4f
  jmp alltraps
80106aed:	e9 09 f7 ff ff       	jmp    801061fb <alltraps>

80106af2 <vector80>:
.globl vector80
vector80:
  pushl $0
80106af2:	6a 00                	push   $0x0
  pushl $80
80106af4:	6a 50                	push   $0x50
  jmp alltraps
80106af6:	e9 00 f7 ff ff       	jmp    801061fb <alltraps>

80106afb <vector81>:
.globl vector81
vector81:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $81
80106afd:	6a 51                	push   $0x51
  jmp alltraps
80106aff:	e9 f7 f6 ff ff       	jmp    801061fb <alltraps>

80106b04 <vector82>:
.globl vector82
vector82:
  pushl $0
80106b04:	6a 00                	push   $0x0
  pushl $82
80106b06:	6a 52                	push   $0x52
  jmp alltraps
80106b08:	e9 ee f6 ff ff       	jmp    801061fb <alltraps>

80106b0d <vector83>:
.globl vector83
vector83:
  pushl $0
80106b0d:	6a 00                	push   $0x0
  pushl $83
80106b0f:	6a 53                	push   $0x53
  jmp alltraps
80106b11:	e9 e5 f6 ff ff       	jmp    801061fb <alltraps>

80106b16 <vector84>:
.globl vector84
vector84:
  pushl $0
80106b16:	6a 00                	push   $0x0
  pushl $84
80106b18:	6a 54                	push   $0x54
  jmp alltraps
80106b1a:	e9 dc f6 ff ff       	jmp    801061fb <alltraps>

80106b1f <vector85>:
.globl vector85
vector85:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $85
80106b21:	6a 55                	push   $0x55
  jmp alltraps
80106b23:	e9 d3 f6 ff ff       	jmp    801061fb <alltraps>

80106b28 <vector86>:
.globl vector86
vector86:
  pushl $0
80106b28:	6a 00                	push   $0x0
  pushl $86
80106b2a:	6a 56                	push   $0x56
  jmp alltraps
80106b2c:	e9 ca f6 ff ff       	jmp    801061fb <alltraps>

80106b31 <vector87>:
.globl vector87
vector87:
  pushl $0
80106b31:	6a 00                	push   $0x0
  pushl $87
80106b33:	6a 57                	push   $0x57
  jmp alltraps
80106b35:	e9 c1 f6 ff ff       	jmp    801061fb <alltraps>

80106b3a <vector88>:
.globl vector88
vector88:
  pushl $0
80106b3a:	6a 00                	push   $0x0
  pushl $88
80106b3c:	6a 58                	push   $0x58
  jmp alltraps
80106b3e:	e9 b8 f6 ff ff       	jmp    801061fb <alltraps>

80106b43 <vector89>:
.globl vector89
vector89:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $89
80106b45:	6a 59                	push   $0x59
  jmp alltraps
80106b47:	e9 af f6 ff ff       	jmp    801061fb <alltraps>

80106b4c <vector90>:
.globl vector90
vector90:
  pushl $0
80106b4c:	6a 00                	push   $0x0
  pushl $90
80106b4e:	6a 5a                	push   $0x5a
  jmp alltraps
80106b50:	e9 a6 f6 ff ff       	jmp    801061fb <alltraps>

80106b55 <vector91>:
.globl vector91
vector91:
  pushl $0
80106b55:	6a 00                	push   $0x0
  pushl $91
80106b57:	6a 5b                	push   $0x5b
  jmp alltraps
80106b59:	e9 9d f6 ff ff       	jmp    801061fb <alltraps>

80106b5e <vector92>:
.globl vector92
vector92:
  pushl $0
80106b5e:	6a 00                	push   $0x0
  pushl $92
80106b60:	6a 5c                	push   $0x5c
  jmp alltraps
80106b62:	e9 94 f6 ff ff       	jmp    801061fb <alltraps>

80106b67 <vector93>:
.globl vector93
vector93:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $93
80106b69:	6a 5d                	push   $0x5d
  jmp alltraps
80106b6b:	e9 8b f6 ff ff       	jmp    801061fb <alltraps>

80106b70 <vector94>:
.globl vector94
vector94:
  pushl $0
80106b70:	6a 00                	push   $0x0
  pushl $94
80106b72:	6a 5e                	push   $0x5e
  jmp alltraps
80106b74:	e9 82 f6 ff ff       	jmp    801061fb <alltraps>

80106b79 <vector95>:
.globl vector95
vector95:
  pushl $0
80106b79:	6a 00                	push   $0x0
  pushl $95
80106b7b:	6a 5f                	push   $0x5f
  jmp alltraps
80106b7d:	e9 79 f6 ff ff       	jmp    801061fb <alltraps>

80106b82 <vector96>:
.globl vector96
vector96:
  pushl $0
80106b82:	6a 00                	push   $0x0
  pushl $96
80106b84:	6a 60                	push   $0x60
  jmp alltraps
80106b86:	e9 70 f6 ff ff       	jmp    801061fb <alltraps>

80106b8b <vector97>:
.globl vector97
vector97:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $97
80106b8d:	6a 61                	push   $0x61
  jmp alltraps
80106b8f:	e9 67 f6 ff ff       	jmp    801061fb <alltraps>

80106b94 <vector98>:
.globl vector98
vector98:
  pushl $0
80106b94:	6a 00                	push   $0x0
  pushl $98
80106b96:	6a 62                	push   $0x62
  jmp alltraps
80106b98:	e9 5e f6 ff ff       	jmp    801061fb <alltraps>

80106b9d <vector99>:
.globl vector99
vector99:
  pushl $0
80106b9d:	6a 00                	push   $0x0
  pushl $99
80106b9f:	6a 63                	push   $0x63
  jmp alltraps
80106ba1:	e9 55 f6 ff ff       	jmp    801061fb <alltraps>

80106ba6 <vector100>:
.globl vector100
vector100:
  pushl $0
80106ba6:	6a 00                	push   $0x0
  pushl $100
80106ba8:	6a 64                	push   $0x64
  jmp alltraps
80106baa:	e9 4c f6 ff ff       	jmp    801061fb <alltraps>

80106baf <vector101>:
.globl vector101
vector101:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $101
80106bb1:	6a 65                	push   $0x65
  jmp alltraps
80106bb3:	e9 43 f6 ff ff       	jmp    801061fb <alltraps>

80106bb8 <vector102>:
.globl vector102
vector102:
  pushl $0
80106bb8:	6a 00                	push   $0x0
  pushl $102
80106bba:	6a 66                	push   $0x66
  jmp alltraps
80106bbc:	e9 3a f6 ff ff       	jmp    801061fb <alltraps>

80106bc1 <vector103>:
.globl vector103
vector103:
  pushl $0
80106bc1:	6a 00                	push   $0x0
  pushl $103
80106bc3:	6a 67                	push   $0x67
  jmp alltraps
80106bc5:	e9 31 f6 ff ff       	jmp    801061fb <alltraps>

80106bca <vector104>:
.globl vector104
vector104:
  pushl $0
80106bca:	6a 00                	push   $0x0
  pushl $104
80106bcc:	6a 68                	push   $0x68
  jmp alltraps
80106bce:	e9 28 f6 ff ff       	jmp    801061fb <alltraps>

80106bd3 <vector105>:
.globl vector105
vector105:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $105
80106bd5:	6a 69                	push   $0x69
  jmp alltraps
80106bd7:	e9 1f f6 ff ff       	jmp    801061fb <alltraps>

80106bdc <vector106>:
.globl vector106
vector106:
  pushl $0
80106bdc:	6a 00                	push   $0x0
  pushl $106
80106bde:	6a 6a                	push   $0x6a
  jmp alltraps
80106be0:	e9 16 f6 ff ff       	jmp    801061fb <alltraps>

80106be5 <vector107>:
.globl vector107
vector107:
  pushl $0
80106be5:	6a 00                	push   $0x0
  pushl $107
80106be7:	6a 6b                	push   $0x6b
  jmp alltraps
80106be9:	e9 0d f6 ff ff       	jmp    801061fb <alltraps>

80106bee <vector108>:
.globl vector108
vector108:
  pushl $0
80106bee:	6a 00                	push   $0x0
  pushl $108
80106bf0:	6a 6c                	push   $0x6c
  jmp alltraps
80106bf2:	e9 04 f6 ff ff       	jmp    801061fb <alltraps>

80106bf7 <vector109>:
.globl vector109
vector109:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $109
80106bf9:	6a 6d                	push   $0x6d
  jmp alltraps
80106bfb:	e9 fb f5 ff ff       	jmp    801061fb <alltraps>

80106c00 <vector110>:
.globl vector110
vector110:
  pushl $0
80106c00:	6a 00                	push   $0x0
  pushl $110
80106c02:	6a 6e                	push   $0x6e
  jmp alltraps
80106c04:	e9 f2 f5 ff ff       	jmp    801061fb <alltraps>

80106c09 <vector111>:
.globl vector111
vector111:
  pushl $0
80106c09:	6a 00                	push   $0x0
  pushl $111
80106c0b:	6a 6f                	push   $0x6f
  jmp alltraps
80106c0d:	e9 e9 f5 ff ff       	jmp    801061fb <alltraps>

80106c12 <vector112>:
.globl vector112
vector112:
  pushl $0
80106c12:	6a 00                	push   $0x0
  pushl $112
80106c14:	6a 70                	push   $0x70
  jmp alltraps
80106c16:	e9 e0 f5 ff ff       	jmp    801061fb <alltraps>

80106c1b <vector113>:
.globl vector113
vector113:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $113
80106c1d:	6a 71                	push   $0x71
  jmp alltraps
80106c1f:	e9 d7 f5 ff ff       	jmp    801061fb <alltraps>

80106c24 <vector114>:
.globl vector114
vector114:
  pushl $0
80106c24:	6a 00                	push   $0x0
  pushl $114
80106c26:	6a 72                	push   $0x72
  jmp alltraps
80106c28:	e9 ce f5 ff ff       	jmp    801061fb <alltraps>

80106c2d <vector115>:
.globl vector115
vector115:
  pushl $0
80106c2d:	6a 00                	push   $0x0
  pushl $115
80106c2f:	6a 73                	push   $0x73
  jmp alltraps
80106c31:	e9 c5 f5 ff ff       	jmp    801061fb <alltraps>

80106c36 <vector116>:
.globl vector116
vector116:
  pushl $0
80106c36:	6a 00                	push   $0x0
  pushl $116
80106c38:	6a 74                	push   $0x74
  jmp alltraps
80106c3a:	e9 bc f5 ff ff       	jmp    801061fb <alltraps>

80106c3f <vector117>:
.globl vector117
vector117:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $117
80106c41:	6a 75                	push   $0x75
  jmp alltraps
80106c43:	e9 b3 f5 ff ff       	jmp    801061fb <alltraps>

80106c48 <vector118>:
.globl vector118
vector118:
  pushl $0
80106c48:	6a 00                	push   $0x0
  pushl $118
80106c4a:	6a 76                	push   $0x76
  jmp alltraps
80106c4c:	e9 aa f5 ff ff       	jmp    801061fb <alltraps>

80106c51 <vector119>:
.globl vector119
vector119:
  pushl $0
80106c51:	6a 00                	push   $0x0
  pushl $119
80106c53:	6a 77                	push   $0x77
  jmp alltraps
80106c55:	e9 a1 f5 ff ff       	jmp    801061fb <alltraps>

80106c5a <vector120>:
.globl vector120
vector120:
  pushl $0
80106c5a:	6a 00                	push   $0x0
  pushl $120
80106c5c:	6a 78                	push   $0x78
  jmp alltraps
80106c5e:	e9 98 f5 ff ff       	jmp    801061fb <alltraps>

80106c63 <vector121>:
.globl vector121
vector121:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $121
80106c65:	6a 79                	push   $0x79
  jmp alltraps
80106c67:	e9 8f f5 ff ff       	jmp    801061fb <alltraps>

80106c6c <vector122>:
.globl vector122
vector122:
  pushl $0
80106c6c:	6a 00                	push   $0x0
  pushl $122
80106c6e:	6a 7a                	push   $0x7a
  jmp alltraps
80106c70:	e9 86 f5 ff ff       	jmp    801061fb <alltraps>

80106c75 <vector123>:
.globl vector123
vector123:
  pushl $0
80106c75:	6a 00                	push   $0x0
  pushl $123
80106c77:	6a 7b                	push   $0x7b
  jmp alltraps
80106c79:	e9 7d f5 ff ff       	jmp    801061fb <alltraps>

80106c7e <vector124>:
.globl vector124
vector124:
  pushl $0
80106c7e:	6a 00                	push   $0x0
  pushl $124
80106c80:	6a 7c                	push   $0x7c
  jmp alltraps
80106c82:	e9 74 f5 ff ff       	jmp    801061fb <alltraps>

80106c87 <vector125>:
.globl vector125
vector125:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $125
80106c89:	6a 7d                	push   $0x7d
  jmp alltraps
80106c8b:	e9 6b f5 ff ff       	jmp    801061fb <alltraps>

80106c90 <vector126>:
.globl vector126
vector126:
  pushl $0
80106c90:	6a 00                	push   $0x0
  pushl $126
80106c92:	6a 7e                	push   $0x7e
  jmp alltraps
80106c94:	e9 62 f5 ff ff       	jmp    801061fb <alltraps>

80106c99 <vector127>:
.globl vector127
vector127:
  pushl $0
80106c99:	6a 00                	push   $0x0
  pushl $127
80106c9b:	6a 7f                	push   $0x7f
  jmp alltraps
80106c9d:	e9 59 f5 ff ff       	jmp    801061fb <alltraps>

80106ca2 <vector128>:
.globl vector128
vector128:
  pushl $0
80106ca2:	6a 00                	push   $0x0
  pushl $128
80106ca4:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106ca9:	e9 4d f5 ff ff       	jmp    801061fb <alltraps>

80106cae <vector129>:
.globl vector129
vector129:
  pushl $0
80106cae:	6a 00                	push   $0x0
  pushl $129
80106cb0:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106cb5:	e9 41 f5 ff ff       	jmp    801061fb <alltraps>

80106cba <vector130>:
.globl vector130
vector130:
  pushl $0
80106cba:	6a 00                	push   $0x0
  pushl $130
80106cbc:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106cc1:	e9 35 f5 ff ff       	jmp    801061fb <alltraps>

80106cc6 <vector131>:
.globl vector131
vector131:
  pushl $0
80106cc6:	6a 00                	push   $0x0
  pushl $131
80106cc8:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106ccd:	e9 29 f5 ff ff       	jmp    801061fb <alltraps>

80106cd2 <vector132>:
.globl vector132
vector132:
  pushl $0
80106cd2:	6a 00                	push   $0x0
  pushl $132
80106cd4:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106cd9:	e9 1d f5 ff ff       	jmp    801061fb <alltraps>

80106cde <vector133>:
.globl vector133
vector133:
  pushl $0
80106cde:	6a 00                	push   $0x0
  pushl $133
80106ce0:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106ce5:	e9 11 f5 ff ff       	jmp    801061fb <alltraps>

80106cea <vector134>:
.globl vector134
vector134:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $134
80106cec:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106cf1:	e9 05 f5 ff ff       	jmp    801061fb <alltraps>

80106cf6 <vector135>:
.globl vector135
vector135:
  pushl $0
80106cf6:	6a 00                	push   $0x0
  pushl $135
80106cf8:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106cfd:	e9 f9 f4 ff ff       	jmp    801061fb <alltraps>

80106d02 <vector136>:
.globl vector136
vector136:
  pushl $0
80106d02:	6a 00                	push   $0x0
  pushl $136
80106d04:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106d09:	e9 ed f4 ff ff       	jmp    801061fb <alltraps>

80106d0e <vector137>:
.globl vector137
vector137:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $137
80106d10:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106d15:	e9 e1 f4 ff ff       	jmp    801061fb <alltraps>

80106d1a <vector138>:
.globl vector138
vector138:
  pushl $0
80106d1a:	6a 00                	push   $0x0
  pushl $138
80106d1c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106d21:	e9 d5 f4 ff ff       	jmp    801061fb <alltraps>

80106d26 <vector139>:
.globl vector139
vector139:
  pushl $0
80106d26:	6a 00                	push   $0x0
  pushl $139
80106d28:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106d2d:	e9 c9 f4 ff ff       	jmp    801061fb <alltraps>

80106d32 <vector140>:
.globl vector140
vector140:
  pushl $0
80106d32:	6a 00                	push   $0x0
  pushl $140
80106d34:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106d39:	e9 bd f4 ff ff       	jmp    801061fb <alltraps>

80106d3e <vector141>:
.globl vector141
vector141:
  pushl $0
80106d3e:	6a 00                	push   $0x0
  pushl $141
80106d40:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106d45:	e9 b1 f4 ff ff       	jmp    801061fb <alltraps>

80106d4a <vector142>:
.globl vector142
vector142:
  pushl $0
80106d4a:	6a 00                	push   $0x0
  pushl $142
80106d4c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106d51:	e9 a5 f4 ff ff       	jmp    801061fb <alltraps>

80106d56 <vector143>:
.globl vector143
vector143:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $143
80106d58:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106d5d:	e9 99 f4 ff ff       	jmp    801061fb <alltraps>

80106d62 <vector144>:
.globl vector144
vector144:
  pushl $0
80106d62:	6a 00                	push   $0x0
  pushl $144
80106d64:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106d69:	e9 8d f4 ff ff       	jmp    801061fb <alltraps>

80106d6e <vector145>:
.globl vector145
vector145:
  pushl $0
80106d6e:	6a 00                	push   $0x0
  pushl $145
80106d70:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106d75:	e9 81 f4 ff ff       	jmp    801061fb <alltraps>

80106d7a <vector146>:
.globl vector146
vector146:
  pushl $0
80106d7a:	6a 00                	push   $0x0
  pushl $146
80106d7c:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106d81:	e9 75 f4 ff ff       	jmp    801061fb <alltraps>

80106d86 <vector147>:
.globl vector147
vector147:
  pushl $0
80106d86:	6a 00                	push   $0x0
  pushl $147
80106d88:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106d8d:	e9 69 f4 ff ff       	jmp    801061fb <alltraps>

80106d92 <vector148>:
.globl vector148
vector148:
  pushl $0
80106d92:	6a 00                	push   $0x0
  pushl $148
80106d94:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106d99:	e9 5d f4 ff ff       	jmp    801061fb <alltraps>

80106d9e <vector149>:
.globl vector149
vector149:
  pushl $0
80106d9e:	6a 00                	push   $0x0
  pushl $149
80106da0:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106da5:	e9 51 f4 ff ff       	jmp    801061fb <alltraps>

80106daa <vector150>:
.globl vector150
vector150:
  pushl $0
80106daa:	6a 00                	push   $0x0
  pushl $150
80106dac:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106db1:	e9 45 f4 ff ff       	jmp    801061fb <alltraps>

80106db6 <vector151>:
.globl vector151
vector151:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $151
80106db8:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106dbd:	e9 39 f4 ff ff       	jmp    801061fb <alltraps>

80106dc2 <vector152>:
.globl vector152
vector152:
  pushl $0
80106dc2:	6a 00                	push   $0x0
  pushl $152
80106dc4:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106dc9:	e9 2d f4 ff ff       	jmp    801061fb <alltraps>

80106dce <vector153>:
.globl vector153
vector153:
  pushl $0
80106dce:	6a 00                	push   $0x0
  pushl $153
80106dd0:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106dd5:	e9 21 f4 ff ff       	jmp    801061fb <alltraps>

80106dda <vector154>:
.globl vector154
vector154:
  pushl $0
80106dda:	6a 00                	push   $0x0
  pushl $154
80106ddc:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106de1:	e9 15 f4 ff ff       	jmp    801061fb <alltraps>

80106de6 <vector155>:
.globl vector155
vector155:
  pushl $0
80106de6:	6a 00                	push   $0x0
  pushl $155
80106de8:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106ded:	e9 09 f4 ff ff       	jmp    801061fb <alltraps>

80106df2 <vector156>:
.globl vector156
vector156:
  pushl $0
80106df2:	6a 00                	push   $0x0
  pushl $156
80106df4:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106df9:	e9 fd f3 ff ff       	jmp    801061fb <alltraps>

80106dfe <vector157>:
.globl vector157
vector157:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $157
80106e00:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106e05:	e9 f1 f3 ff ff       	jmp    801061fb <alltraps>

80106e0a <vector158>:
.globl vector158
vector158:
  pushl $0
80106e0a:	6a 00                	push   $0x0
  pushl $158
80106e0c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106e11:	e9 e5 f3 ff ff       	jmp    801061fb <alltraps>

80106e16 <vector159>:
.globl vector159
vector159:
  pushl $0
80106e16:	6a 00                	push   $0x0
  pushl $159
80106e18:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106e1d:	e9 d9 f3 ff ff       	jmp    801061fb <alltraps>

80106e22 <vector160>:
.globl vector160
vector160:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $160
80106e24:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106e29:	e9 cd f3 ff ff       	jmp    801061fb <alltraps>

80106e2e <vector161>:
.globl vector161
vector161:
  pushl $0
80106e2e:	6a 00                	push   $0x0
  pushl $161
80106e30:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106e35:	e9 c1 f3 ff ff       	jmp    801061fb <alltraps>

80106e3a <vector162>:
.globl vector162
vector162:
  pushl $0
80106e3a:	6a 00                	push   $0x0
  pushl $162
80106e3c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106e41:	e9 b5 f3 ff ff       	jmp    801061fb <alltraps>

80106e46 <vector163>:
.globl vector163
vector163:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $163
80106e48:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106e4d:	e9 a9 f3 ff ff       	jmp    801061fb <alltraps>

80106e52 <vector164>:
.globl vector164
vector164:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $164
80106e54:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106e59:	e9 9d f3 ff ff       	jmp    801061fb <alltraps>

80106e5e <vector165>:
.globl vector165
vector165:
  pushl $0
80106e5e:	6a 00                	push   $0x0
  pushl $165
80106e60:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106e65:	e9 91 f3 ff ff       	jmp    801061fb <alltraps>

80106e6a <vector166>:
.globl vector166
vector166:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $166
80106e6c:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106e71:	e9 85 f3 ff ff       	jmp    801061fb <alltraps>

80106e76 <vector167>:
.globl vector167
vector167:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $167
80106e78:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106e7d:	e9 79 f3 ff ff       	jmp    801061fb <alltraps>

80106e82 <vector168>:
.globl vector168
vector168:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $168
80106e84:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106e89:	e9 6d f3 ff ff       	jmp    801061fb <alltraps>

80106e8e <vector169>:
.globl vector169
vector169:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $169
80106e90:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106e95:	e9 61 f3 ff ff       	jmp    801061fb <alltraps>

80106e9a <vector170>:
.globl vector170
vector170:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $170
80106e9c:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106ea1:	e9 55 f3 ff ff       	jmp    801061fb <alltraps>

80106ea6 <vector171>:
.globl vector171
vector171:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $171
80106ea8:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106ead:	e9 49 f3 ff ff       	jmp    801061fb <alltraps>

80106eb2 <vector172>:
.globl vector172
vector172:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $172
80106eb4:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106eb9:	e9 3d f3 ff ff       	jmp    801061fb <alltraps>

80106ebe <vector173>:
.globl vector173
vector173:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $173
80106ec0:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106ec5:	e9 31 f3 ff ff       	jmp    801061fb <alltraps>

80106eca <vector174>:
.globl vector174
vector174:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $174
80106ecc:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106ed1:	e9 25 f3 ff ff       	jmp    801061fb <alltraps>

80106ed6 <vector175>:
.globl vector175
vector175:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $175
80106ed8:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106edd:	e9 19 f3 ff ff       	jmp    801061fb <alltraps>

80106ee2 <vector176>:
.globl vector176
vector176:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $176
80106ee4:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106ee9:	e9 0d f3 ff ff       	jmp    801061fb <alltraps>

80106eee <vector177>:
.globl vector177
vector177:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $177
80106ef0:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106ef5:	e9 01 f3 ff ff       	jmp    801061fb <alltraps>

80106efa <vector178>:
.globl vector178
vector178:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $178
80106efc:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106f01:	e9 f5 f2 ff ff       	jmp    801061fb <alltraps>

80106f06 <vector179>:
.globl vector179
vector179:
  pushl $0
80106f06:	6a 00                	push   $0x0
  pushl $179
80106f08:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106f0d:	e9 e9 f2 ff ff       	jmp    801061fb <alltraps>

80106f12 <vector180>:
.globl vector180
vector180:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $180
80106f14:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106f19:	e9 dd f2 ff ff       	jmp    801061fb <alltraps>

80106f1e <vector181>:
.globl vector181
vector181:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $181
80106f20:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106f25:	e9 d1 f2 ff ff       	jmp    801061fb <alltraps>

80106f2a <vector182>:
.globl vector182
vector182:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $182
80106f2c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106f31:	e9 c5 f2 ff ff       	jmp    801061fb <alltraps>

80106f36 <vector183>:
.globl vector183
vector183:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $183
80106f38:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106f3d:	e9 b9 f2 ff ff       	jmp    801061fb <alltraps>

80106f42 <vector184>:
.globl vector184
vector184:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $184
80106f44:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106f49:	e9 ad f2 ff ff       	jmp    801061fb <alltraps>

80106f4e <vector185>:
.globl vector185
vector185:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $185
80106f50:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106f55:	e9 a1 f2 ff ff       	jmp    801061fb <alltraps>

80106f5a <vector186>:
.globl vector186
vector186:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $186
80106f5c:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106f61:	e9 95 f2 ff ff       	jmp    801061fb <alltraps>

80106f66 <vector187>:
.globl vector187
vector187:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $187
80106f68:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106f6d:	e9 89 f2 ff ff       	jmp    801061fb <alltraps>

80106f72 <vector188>:
.globl vector188
vector188:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $188
80106f74:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106f79:	e9 7d f2 ff ff       	jmp    801061fb <alltraps>

80106f7e <vector189>:
.globl vector189
vector189:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $189
80106f80:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106f85:	e9 71 f2 ff ff       	jmp    801061fb <alltraps>

80106f8a <vector190>:
.globl vector190
vector190:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $190
80106f8c:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106f91:	e9 65 f2 ff ff       	jmp    801061fb <alltraps>

80106f96 <vector191>:
.globl vector191
vector191:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $191
80106f98:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106f9d:	e9 59 f2 ff ff       	jmp    801061fb <alltraps>

80106fa2 <vector192>:
.globl vector192
vector192:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $192
80106fa4:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106fa9:	e9 4d f2 ff ff       	jmp    801061fb <alltraps>

80106fae <vector193>:
.globl vector193
vector193:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $193
80106fb0:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106fb5:	e9 41 f2 ff ff       	jmp    801061fb <alltraps>

80106fba <vector194>:
.globl vector194
vector194:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $194
80106fbc:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106fc1:	e9 35 f2 ff ff       	jmp    801061fb <alltraps>

80106fc6 <vector195>:
.globl vector195
vector195:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $195
80106fc8:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106fcd:	e9 29 f2 ff ff       	jmp    801061fb <alltraps>

80106fd2 <vector196>:
.globl vector196
vector196:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $196
80106fd4:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106fd9:	e9 1d f2 ff ff       	jmp    801061fb <alltraps>

80106fde <vector197>:
.globl vector197
vector197:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $197
80106fe0:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106fe5:	e9 11 f2 ff ff       	jmp    801061fb <alltraps>

80106fea <vector198>:
.globl vector198
vector198:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $198
80106fec:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106ff1:	e9 05 f2 ff ff       	jmp    801061fb <alltraps>

80106ff6 <vector199>:
.globl vector199
vector199:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $199
80106ff8:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106ffd:	e9 f9 f1 ff ff       	jmp    801061fb <alltraps>

80107002 <vector200>:
.globl vector200
vector200:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $200
80107004:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107009:	e9 ed f1 ff ff       	jmp    801061fb <alltraps>

8010700e <vector201>:
.globl vector201
vector201:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $201
80107010:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107015:	e9 e1 f1 ff ff       	jmp    801061fb <alltraps>

8010701a <vector202>:
.globl vector202
vector202:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $202
8010701c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107021:	e9 d5 f1 ff ff       	jmp    801061fb <alltraps>

80107026 <vector203>:
.globl vector203
vector203:
  pushl $0
80107026:	6a 00                	push   $0x0
  pushl $203
80107028:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010702d:	e9 c9 f1 ff ff       	jmp    801061fb <alltraps>

80107032 <vector204>:
.globl vector204
vector204:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $204
80107034:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107039:	e9 bd f1 ff ff       	jmp    801061fb <alltraps>

8010703e <vector205>:
.globl vector205
vector205:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $205
80107040:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107045:	e9 b1 f1 ff ff       	jmp    801061fb <alltraps>

8010704a <vector206>:
.globl vector206
vector206:
  pushl $0
8010704a:	6a 00                	push   $0x0
  pushl $206
8010704c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107051:	e9 a5 f1 ff ff       	jmp    801061fb <alltraps>

80107056 <vector207>:
.globl vector207
vector207:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $207
80107058:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010705d:	e9 99 f1 ff ff       	jmp    801061fb <alltraps>

80107062 <vector208>:
.globl vector208
vector208:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $208
80107064:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107069:	e9 8d f1 ff ff       	jmp    801061fb <alltraps>

8010706e <vector209>:
.globl vector209
vector209:
  pushl $0
8010706e:	6a 00                	push   $0x0
  pushl $209
80107070:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107075:	e9 81 f1 ff ff       	jmp    801061fb <alltraps>

8010707a <vector210>:
.globl vector210
vector210:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $210
8010707c:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107081:	e9 75 f1 ff ff       	jmp    801061fb <alltraps>

80107086 <vector211>:
.globl vector211
vector211:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $211
80107088:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010708d:	e9 69 f1 ff ff       	jmp    801061fb <alltraps>

80107092 <vector212>:
.globl vector212
vector212:
  pushl $0
80107092:	6a 00                	push   $0x0
  pushl $212
80107094:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107099:	e9 5d f1 ff ff       	jmp    801061fb <alltraps>

8010709e <vector213>:
.globl vector213
vector213:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $213
801070a0:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801070a5:	e9 51 f1 ff ff       	jmp    801061fb <alltraps>

801070aa <vector214>:
.globl vector214
vector214:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $214
801070ac:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801070b1:	e9 45 f1 ff ff       	jmp    801061fb <alltraps>

801070b6 <vector215>:
.globl vector215
vector215:
  pushl $0
801070b6:	6a 00                	push   $0x0
  pushl $215
801070b8:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801070bd:	e9 39 f1 ff ff       	jmp    801061fb <alltraps>

801070c2 <vector216>:
.globl vector216
vector216:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $216
801070c4:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801070c9:	e9 2d f1 ff ff       	jmp    801061fb <alltraps>

801070ce <vector217>:
.globl vector217
vector217:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $217
801070d0:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801070d5:	e9 21 f1 ff ff       	jmp    801061fb <alltraps>

801070da <vector218>:
.globl vector218
vector218:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $218
801070dc:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801070e1:	e9 15 f1 ff ff       	jmp    801061fb <alltraps>

801070e6 <vector219>:
.globl vector219
vector219:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $219
801070e8:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801070ed:	e9 09 f1 ff ff       	jmp    801061fb <alltraps>

801070f2 <vector220>:
.globl vector220
vector220:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $220
801070f4:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801070f9:	e9 fd f0 ff ff       	jmp    801061fb <alltraps>

801070fe <vector221>:
.globl vector221
vector221:
  pushl $0
801070fe:	6a 00                	push   $0x0
  pushl $221
80107100:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107105:	e9 f1 f0 ff ff       	jmp    801061fb <alltraps>

8010710a <vector222>:
.globl vector222
vector222:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $222
8010710c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107111:	e9 e5 f0 ff ff       	jmp    801061fb <alltraps>

80107116 <vector223>:
.globl vector223
vector223:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $223
80107118:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010711d:	e9 d9 f0 ff ff       	jmp    801061fb <alltraps>

80107122 <vector224>:
.globl vector224
vector224:
  pushl $0
80107122:	6a 00                	push   $0x0
  pushl $224
80107124:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107129:	e9 cd f0 ff ff       	jmp    801061fb <alltraps>

8010712e <vector225>:
.globl vector225
vector225:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $225
80107130:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107135:	e9 c1 f0 ff ff       	jmp    801061fb <alltraps>

8010713a <vector226>:
.globl vector226
vector226:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $226
8010713c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107141:	e9 b5 f0 ff ff       	jmp    801061fb <alltraps>

80107146 <vector227>:
.globl vector227
vector227:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $227
80107148:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010714d:	e9 a9 f0 ff ff       	jmp    801061fb <alltraps>

80107152 <vector228>:
.globl vector228
vector228:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $228
80107154:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107159:	e9 9d f0 ff ff       	jmp    801061fb <alltraps>

8010715e <vector229>:
.globl vector229
vector229:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $229
80107160:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107165:	e9 91 f0 ff ff       	jmp    801061fb <alltraps>

8010716a <vector230>:
.globl vector230
vector230:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $230
8010716c:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107171:	e9 85 f0 ff ff       	jmp    801061fb <alltraps>

80107176 <vector231>:
.globl vector231
vector231:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $231
80107178:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010717d:	e9 79 f0 ff ff       	jmp    801061fb <alltraps>

80107182 <vector232>:
.globl vector232
vector232:
  pushl $0
80107182:	6a 00                	push   $0x0
  pushl $232
80107184:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107189:	e9 6d f0 ff ff       	jmp    801061fb <alltraps>

8010718e <vector233>:
.globl vector233
vector233:
  pushl $0
8010718e:	6a 00                	push   $0x0
  pushl $233
80107190:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107195:	e9 61 f0 ff ff       	jmp    801061fb <alltraps>

8010719a <vector234>:
.globl vector234
vector234:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $234
8010719c:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801071a1:	e9 55 f0 ff ff       	jmp    801061fb <alltraps>

801071a6 <vector235>:
.globl vector235
vector235:
  pushl $0
801071a6:	6a 00                	push   $0x0
  pushl $235
801071a8:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801071ad:	e9 49 f0 ff ff       	jmp    801061fb <alltraps>

801071b2 <vector236>:
.globl vector236
vector236:
  pushl $0
801071b2:	6a 00                	push   $0x0
  pushl $236
801071b4:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801071b9:	e9 3d f0 ff ff       	jmp    801061fb <alltraps>

801071be <vector237>:
.globl vector237
vector237:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $237
801071c0:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801071c5:	e9 31 f0 ff ff       	jmp    801061fb <alltraps>

801071ca <vector238>:
.globl vector238
vector238:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $238
801071cc:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801071d1:	e9 25 f0 ff ff       	jmp    801061fb <alltraps>

801071d6 <vector239>:
.globl vector239
vector239:
  pushl $0
801071d6:	6a 00                	push   $0x0
  pushl $239
801071d8:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801071dd:	e9 19 f0 ff ff       	jmp    801061fb <alltraps>

801071e2 <vector240>:
.globl vector240
vector240:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $240
801071e4:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801071e9:	e9 0d f0 ff ff       	jmp    801061fb <alltraps>

801071ee <vector241>:
.globl vector241
vector241:
  pushl $0
801071ee:	6a 00                	push   $0x0
  pushl $241
801071f0:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801071f5:	e9 01 f0 ff ff       	jmp    801061fb <alltraps>

801071fa <vector242>:
.globl vector242
vector242:
  pushl $0
801071fa:	6a 00                	push   $0x0
  pushl $242
801071fc:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107201:	e9 f5 ef ff ff       	jmp    801061fb <alltraps>

80107206 <vector243>:
.globl vector243
vector243:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $243
80107208:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010720d:	e9 e9 ef ff ff       	jmp    801061fb <alltraps>

80107212 <vector244>:
.globl vector244
vector244:
  pushl $0
80107212:	6a 00                	push   $0x0
  pushl $244
80107214:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107219:	e9 dd ef ff ff       	jmp    801061fb <alltraps>

8010721e <vector245>:
.globl vector245
vector245:
  pushl $0
8010721e:	6a 00                	push   $0x0
  pushl $245
80107220:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107225:	e9 d1 ef ff ff       	jmp    801061fb <alltraps>

8010722a <vector246>:
.globl vector246
vector246:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $246
8010722c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107231:	e9 c5 ef ff ff       	jmp    801061fb <alltraps>

80107236 <vector247>:
.globl vector247
vector247:
  pushl $0
80107236:	6a 00                	push   $0x0
  pushl $247
80107238:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010723d:	e9 b9 ef ff ff       	jmp    801061fb <alltraps>

80107242 <vector248>:
.globl vector248
vector248:
  pushl $0
80107242:	6a 00                	push   $0x0
  pushl $248
80107244:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107249:	e9 ad ef ff ff       	jmp    801061fb <alltraps>

8010724e <vector249>:
.globl vector249
vector249:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $249
80107250:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107255:	e9 a1 ef ff ff       	jmp    801061fb <alltraps>

8010725a <vector250>:
.globl vector250
vector250:
  pushl $0
8010725a:	6a 00                	push   $0x0
  pushl $250
8010725c:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107261:	e9 95 ef ff ff       	jmp    801061fb <alltraps>

80107266 <vector251>:
.globl vector251
vector251:
  pushl $0
80107266:	6a 00                	push   $0x0
  pushl $251
80107268:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010726d:	e9 89 ef ff ff       	jmp    801061fb <alltraps>

80107272 <vector252>:
.globl vector252
vector252:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $252
80107274:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107279:	e9 7d ef ff ff       	jmp    801061fb <alltraps>

8010727e <vector253>:
.globl vector253
vector253:
  pushl $0
8010727e:	6a 00                	push   $0x0
  pushl $253
80107280:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107285:	e9 71 ef ff ff       	jmp    801061fb <alltraps>

8010728a <vector254>:
.globl vector254
vector254:
  pushl $0
8010728a:	6a 00                	push   $0x0
  pushl $254
8010728c:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107291:	e9 65 ef ff ff       	jmp    801061fb <alltraps>

80107296 <vector255>:
.globl vector255
vector255:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $255
80107298:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010729d:	e9 59 ef ff ff       	jmp    801061fb <alltraps>

801072a2 <lgdt>:
{
801072a2:	55                   	push   %ebp
801072a3:	89 e5                	mov    %esp,%ebp
801072a5:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801072a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801072ab:	83 e8 01             	sub    $0x1,%eax
801072ae:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801072b2:	8b 45 08             	mov    0x8(%ebp),%eax
801072b5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801072b9:	8b 45 08             	mov    0x8(%ebp),%eax
801072bc:	c1 e8 10             	shr    $0x10,%eax
801072bf:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801072c3:	8d 45 fa             	lea    -0x6(%ebp),%eax
801072c6:	0f 01 10             	lgdtl  (%eax)
}
801072c9:	90                   	nop
801072ca:	c9                   	leave  
801072cb:	c3                   	ret    

801072cc <ltr>:
{
801072cc:	55                   	push   %ebp
801072cd:	89 e5                	mov    %esp,%ebp
801072cf:	83 ec 04             	sub    $0x4,%esp
801072d2:	8b 45 08             	mov    0x8(%ebp),%eax
801072d5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801072d9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801072dd:	0f 00 d8             	ltr    %ax
}
801072e0:	90                   	nop
801072e1:	c9                   	leave  
801072e2:	c3                   	ret    

801072e3 <lcr3>:

static inline void
lcr3(uint val)
{
801072e3:	55                   	push   %ebp
801072e4:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801072e6:	8b 45 08             	mov    0x8(%ebp),%eax
801072e9:	0f 22 d8             	mov    %eax,%cr3
}
801072ec:	90                   	nop
801072ed:	5d                   	pop    %ebp
801072ee:	c3                   	ret    

801072ef <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801072ef:	55                   	push   %ebp
801072f0:	89 e5                	mov    %esp,%ebp
801072f2:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801072f5:	e8 87 cb ff ff       	call   80103e81 <cpuid>
801072fa:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107300:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
80107305:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010730b:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107314:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010731a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010731d:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107324:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107328:	83 e2 f0             	and    $0xfffffff0,%edx
8010732b:	83 ca 0a             	or     $0xa,%edx
8010732e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107334:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107338:	83 ca 10             	or     $0x10,%edx
8010733b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010733e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107341:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107345:	83 e2 9f             	and    $0xffffff9f,%edx
80107348:	88 50 7d             	mov    %dl,0x7d(%eax)
8010734b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107352:	83 ca 80             	or     $0xffffff80,%edx
80107355:	88 50 7d             	mov    %dl,0x7d(%eax)
80107358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010735f:	83 ca 0f             	or     $0xf,%edx
80107362:	88 50 7e             	mov    %dl,0x7e(%eax)
80107365:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107368:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010736c:	83 e2 ef             	and    $0xffffffef,%edx
8010736f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107375:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107379:	83 e2 df             	and    $0xffffffdf,%edx
8010737c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010737f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107382:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107386:	83 ca 40             	or     $0x40,%edx
80107389:	88 50 7e             	mov    %dl,0x7e(%eax)
8010738c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107393:	83 ca 80             	or     $0xffffff80,%edx
80107396:	88 50 7e             	mov    %dl,0x7e(%eax)
80107399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739c:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801073a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a3:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801073aa:	ff ff 
801073ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073af:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801073b6:	00 00 
801073b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073bb:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801073c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801073cc:	83 e2 f0             	and    $0xfffffff0,%edx
801073cf:	83 ca 02             	or     $0x2,%edx
801073d2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801073d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073db:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801073e2:	83 ca 10             	or     $0x10,%edx
801073e5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801073eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ee:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801073f5:	83 e2 9f             	and    $0xffffff9f,%edx
801073f8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801073fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107401:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107408:	83 ca 80             	or     $0xffffff80,%edx
8010740b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107414:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010741b:	83 ca 0f             	or     $0xf,%edx
8010741e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107427:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010742e:	83 e2 ef             	and    $0xffffffef,%edx
80107431:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107441:	83 e2 df             	and    $0xffffffdf,%edx
80107444:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010744a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010744d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107454:	83 ca 40             	or     $0x40,%edx
80107457:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010745d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107460:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107467:	83 ca 80             	or     $0xffffff80,%edx
8010746a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107473:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010747a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747d:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107484:	ff ff 
80107486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107489:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107490:	00 00 
80107492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107495:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010749c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801074a6:	83 e2 f0             	and    $0xfffffff0,%edx
801074a9:	83 ca 0a             	or     $0xa,%edx
801074ac:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801074b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801074bc:	83 ca 10             	or     $0x10,%edx
801074bf:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801074c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801074cf:	83 ca 60             	or     $0x60,%edx
801074d2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801074d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074db:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801074e2:	83 ca 80             	or     $0xffffff80,%edx
801074e5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801074eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ee:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801074f5:	83 ca 0f             	or     $0xf,%edx
801074f8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801074fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107501:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107508:	83 e2 ef             	and    $0xffffffef,%edx
8010750b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107514:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010751b:	83 e2 df             	and    $0xffffffdf,%edx
8010751e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107527:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010752e:	83 ca 40             	or     $0x40,%edx
80107531:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107541:	83 ca 80             	or     $0xffffff80,%edx
80107544:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010754a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754d:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107557:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010755e:	ff ff 
80107560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107563:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010756a:	00 00 
8010756c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010756f:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107579:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107580:	83 e2 f0             	and    $0xfffffff0,%edx
80107583:	83 ca 02             	or     $0x2,%edx
80107586:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010758c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107596:	83 ca 10             	or     $0x10,%edx
80107599:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010759f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075a9:	83 ca 60             	or     $0x60,%edx
801075ac:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b5:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075bc:	83 ca 80             	or     $0xffffff80,%edx
801075bf:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801075cf:	83 ca 0f             	or     $0xf,%edx
801075d2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075db:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801075e2:	83 e2 ef             	and    $0xffffffef,%edx
801075e5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ee:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801075f5:	83 e2 df             	and    $0xffffffdf,%edx
801075f8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107601:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107608:	83 ca 40             	or     $0x40,%edx
8010760b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107614:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010761b:	83 ca 80             	or     $0xffffff80,%edx
8010761e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107627:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010762e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107631:	83 c0 70             	add    $0x70,%eax
80107634:	83 ec 08             	sub    $0x8,%esp
80107637:	6a 30                	push   $0x30
80107639:	50                   	push   %eax
8010763a:	e8 63 fc ff ff       	call   801072a2 <lgdt>
8010763f:	83 c4 10             	add    $0x10,%esp
}
80107642:	90                   	nop
80107643:	c9                   	leave  
80107644:	c3                   	ret    

80107645 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107645:	55                   	push   %ebp
80107646:	89 e5                	mov    %esp,%ebp
80107648:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010764b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010764e:	c1 e8 16             	shr    $0x16,%eax
80107651:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107658:	8b 45 08             	mov    0x8(%ebp),%eax
8010765b:	01 d0                	add    %edx,%eax
8010765d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107660:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107663:	8b 00                	mov    (%eax),%eax
80107665:	83 e0 01             	and    $0x1,%eax
80107668:	85 c0                	test   %eax,%eax
8010766a:	74 14                	je     80107680 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010766c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010766f:	8b 00                	mov    (%eax),%eax
80107671:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107676:	05 00 00 00 80       	add    $0x80000000,%eax
8010767b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010767e:	eb 42                	jmp    801076c2 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107680:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107684:	74 0e                	je     80107694 <walkpgdir+0x4f>
80107686:	e8 f9 b5 ff ff       	call   80102c84 <kalloc>
8010768b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010768e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107692:	75 07                	jne    8010769b <walkpgdir+0x56>
      return 0;
80107694:	b8 00 00 00 00       	mov    $0x0,%eax
80107699:	eb 3e                	jmp    801076d9 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010769b:	83 ec 04             	sub    $0x4,%esp
8010769e:	68 00 10 00 00       	push   $0x1000
801076a3:	6a 00                	push   $0x0
801076a5:	ff 75 f4             	push   -0xc(%ebp)
801076a8:	e8 a1 d7 ff ff       	call   80104e4e <memset>
801076ad:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801076b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b3:	05 00 00 00 80       	add    $0x80000000,%eax
801076b8:	83 c8 07             	or     $0x7,%eax
801076bb:	89 c2                	mov    %eax,%edx
801076bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076c0:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801076c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801076c5:	c1 e8 0c             	shr    $0xc,%eax
801076c8:	25 ff 03 00 00       	and    $0x3ff,%eax
801076cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801076d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d7:	01 d0                	add    %edx,%eax
}
801076d9:	c9                   	leave  
801076da:	c3                   	ret    

801076db <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801076db:	55                   	push   %ebp
801076dc:	89 e5                	mov    %esp,%ebp
801076de:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801076e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801076e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801076ec:	8b 55 0c             	mov    0xc(%ebp),%edx
801076ef:	8b 45 10             	mov    0x10(%ebp),%eax
801076f2:	01 d0                	add    %edx,%eax
801076f4:	83 e8 01             	sub    $0x1,%eax
801076f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801076ff:	83 ec 04             	sub    $0x4,%esp
80107702:	6a 01                	push   $0x1
80107704:	ff 75 f4             	push   -0xc(%ebp)
80107707:	ff 75 08             	push   0x8(%ebp)
8010770a:	e8 36 ff ff ff       	call   80107645 <walkpgdir>
8010770f:	83 c4 10             	add    $0x10,%esp
80107712:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107715:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107719:	75 07                	jne    80107722 <mappages+0x47>
      return -1;
8010771b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107720:	eb 47                	jmp    80107769 <mappages+0x8e>
    if(*pte & PTE_P)
80107722:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107725:	8b 00                	mov    (%eax),%eax
80107727:	83 e0 01             	and    $0x1,%eax
8010772a:	85 c0                	test   %eax,%eax
8010772c:	74 0d                	je     8010773b <mappages+0x60>
      panic("remap");
8010772e:	83 ec 0c             	sub    $0xc,%esp
80107731:	68 6c a9 10 80       	push   $0x8010a96c
80107736:	e8 6e 8e ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
8010773b:	8b 45 18             	mov    0x18(%ebp),%eax
8010773e:	0b 45 14             	or     0x14(%ebp),%eax
80107741:	83 c8 01             	or     $0x1,%eax
80107744:	89 c2                	mov    %eax,%edx
80107746:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107749:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010774b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107751:	74 10                	je     80107763 <mappages+0x88>
      break;
    a += PGSIZE;
80107753:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010775a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107761:	eb 9c                	jmp    801076ff <mappages+0x24>
      break;
80107763:	90                   	nop
  }
  return 0;
80107764:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107769:	c9                   	leave  
8010776a:	c3                   	ret    

8010776b <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010776b:	55                   	push   %ebp
8010776c:	89 e5                	mov    %esp,%ebp
8010776e:	53                   	push   %ebx
8010776f:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107772:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107779:	8b 15 90 9d 11 80    	mov    0x80119d90,%edx
8010777f:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107784:	29 d0                	sub    %edx,%eax
80107786:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107789:	a1 88 9d 11 80       	mov    0x80119d88,%eax
8010778e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107791:	8b 15 88 9d 11 80    	mov    0x80119d88,%edx
80107797:	a1 90 9d 11 80       	mov    0x80119d90,%eax
8010779c:	01 d0                	add    %edx,%eax
8010779e:	89 45 e8             	mov    %eax,-0x18(%ebp)
801077a1:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801077a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ab:	83 c0 30             	add    $0x30,%eax
801077ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
801077b1:	89 10                	mov    %edx,(%eax)
801077b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801077b6:	89 50 04             	mov    %edx,0x4(%eax)
801077b9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801077bc:	89 50 08             	mov    %edx,0x8(%eax)
801077bf:	8b 55 ec             	mov    -0x14(%ebp),%edx
801077c2:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801077c5:	e8 ba b4 ff ff       	call   80102c84 <kalloc>
801077ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
801077cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801077d1:	75 07                	jne    801077da <setupkvm+0x6f>
    return 0;
801077d3:	b8 00 00 00 00       	mov    $0x0,%eax
801077d8:	eb 78                	jmp    80107852 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
801077da:	83 ec 04             	sub    $0x4,%esp
801077dd:	68 00 10 00 00       	push   $0x1000
801077e2:	6a 00                	push   $0x0
801077e4:	ff 75 f0             	push   -0x10(%ebp)
801077e7:	e8 62 d6 ff ff       	call   80104e4e <memset>
801077ec:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801077ef:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801077f6:	eb 4e                	jmp    80107846 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801077f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fb:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801077fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107801:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107807:	8b 58 08             	mov    0x8(%eax),%ebx
8010780a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780d:	8b 40 04             	mov    0x4(%eax),%eax
80107810:	29 c3                	sub    %eax,%ebx
80107812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107815:	8b 00                	mov    (%eax),%eax
80107817:	83 ec 0c             	sub    $0xc,%esp
8010781a:	51                   	push   %ecx
8010781b:	52                   	push   %edx
8010781c:	53                   	push   %ebx
8010781d:	50                   	push   %eax
8010781e:	ff 75 f0             	push   -0x10(%ebp)
80107821:	e8 b5 fe ff ff       	call   801076db <mappages>
80107826:	83 c4 20             	add    $0x20,%esp
80107829:	85 c0                	test   %eax,%eax
8010782b:	79 15                	jns    80107842 <setupkvm+0xd7>
      freevm(pgdir);
8010782d:	83 ec 0c             	sub    $0xc,%esp
80107830:	ff 75 f0             	push   -0x10(%ebp)
80107833:	e8 f5 04 00 00       	call   80107d2d <freevm>
80107838:	83 c4 10             	add    $0x10,%esp
      return 0;
8010783b:	b8 00 00 00 00       	mov    $0x0,%eax
80107840:	eb 10                	jmp    80107852 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107842:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107846:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
8010784d:	72 a9                	jb     801077f8 <setupkvm+0x8d>
    }
  return pgdir;
8010784f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107852:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107855:	c9                   	leave  
80107856:	c3                   	ret    

80107857 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107857:	55                   	push   %ebp
80107858:	89 e5                	mov    %esp,%ebp
8010785a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010785d:	e8 09 ff ff ff       	call   8010776b <setupkvm>
80107862:	a3 bc 9a 11 80       	mov    %eax,0x80119abc
  switchkvm();
80107867:	e8 03 00 00 00       	call   8010786f <switchkvm>
}
8010786c:	90                   	nop
8010786d:	c9                   	leave  
8010786e:	c3                   	ret    

8010786f <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010786f:	55                   	push   %ebp
80107870:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107872:	a1 bc 9a 11 80       	mov    0x80119abc,%eax
80107877:	05 00 00 00 80       	add    $0x80000000,%eax
8010787c:	50                   	push   %eax
8010787d:	e8 61 fa ff ff       	call   801072e3 <lcr3>
80107882:	83 c4 04             	add    $0x4,%esp
}
80107885:	90                   	nop
80107886:	c9                   	leave  
80107887:	c3                   	ret    

80107888 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107888:	55                   	push   %ebp
80107889:	89 e5                	mov    %esp,%ebp
8010788b:	56                   	push   %esi
8010788c:	53                   	push   %ebx
8010788d:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107890:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107894:	75 0d                	jne    801078a3 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107896:	83 ec 0c             	sub    $0xc,%esp
80107899:	68 72 a9 10 80       	push   $0x8010a972
8010789e:	e8 06 8d ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
801078a3:	8b 45 08             	mov    0x8(%ebp),%eax
801078a6:	8b 40 08             	mov    0x8(%eax),%eax
801078a9:	85 c0                	test   %eax,%eax
801078ab:	75 0d                	jne    801078ba <switchuvm+0x32>
    panic("switchuvm: no kstack");
801078ad:	83 ec 0c             	sub    $0xc,%esp
801078b0:	68 88 a9 10 80       	push   $0x8010a988
801078b5:	e8 ef 8c ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
801078ba:	8b 45 08             	mov    0x8(%ebp),%eax
801078bd:	8b 40 04             	mov    0x4(%eax),%eax
801078c0:	85 c0                	test   %eax,%eax
801078c2:	75 0d                	jne    801078d1 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
801078c4:	83 ec 0c             	sub    $0xc,%esp
801078c7:	68 9d a9 10 80       	push   $0x8010a99d
801078cc:	e8 d8 8c ff ff       	call   801005a9 <panic>

  pushcli();
801078d1:	e8 6d d4 ff ff       	call   80104d43 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801078d6:	e8 c1 c5 ff ff       	call   80103e9c <mycpu>
801078db:	89 c3                	mov    %eax,%ebx
801078dd:	e8 ba c5 ff ff       	call   80103e9c <mycpu>
801078e2:	83 c0 08             	add    $0x8,%eax
801078e5:	89 c6                	mov    %eax,%esi
801078e7:	e8 b0 c5 ff ff       	call   80103e9c <mycpu>
801078ec:	83 c0 08             	add    $0x8,%eax
801078ef:	c1 e8 10             	shr    $0x10,%eax
801078f2:	88 45 f7             	mov    %al,-0x9(%ebp)
801078f5:	e8 a2 c5 ff ff       	call   80103e9c <mycpu>
801078fa:	83 c0 08             	add    $0x8,%eax
801078fd:	c1 e8 18             	shr    $0x18,%eax
80107900:	89 c2                	mov    %eax,%edx
80107902:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107909:	67 00 
8010790b:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107912:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107916:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010791c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107923:	83 e0 f0             	and    $0xfffffff0,%eax
80107926:	83 c8 09             	or     $0x9,%eax
80107929:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010792f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107936:	83 c8 10             	or     $0x10,%eax
80107939:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010793f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107946:	83 e0 9f             	and    $0xffffff9f,%eax
80107949:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010794f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107956:	83 c8 80             	or     $0xffffff80,%eax
80107959:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010795f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107966:	83 e0 f0             	and    $0xfffffff0,%eax
80107969:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010796f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107976:	83 e0 ef             	and    $0xffffffef,%eax
80107979:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010797f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107986:	83 e0 df             	and    $0xffffffdf,%eax
80107989:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010798f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107996:	83 c8 40             	or     $0x40,%eax
80107999:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010799f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079a6:	83 e0 7f             	and    $0x7f,%eax
801079a9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079af:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801079b5:	e8 e2 c4 ff ff       	call   80103e9c <mycpu>
801079ba:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801079c1:	83 e2 ef             	and    $0xffffffef,%edx
801079c4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801079ca:	e8 cd c4 ff ff       	call   80103e9c <mycpu>
801079cf:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801079d5:	8b 45 08             	mov    0x8(%ebp),%eax
801079d8:	8b 40 08             	mov    0x8(%eax),%eax
801079db:	89 c3                	mov    %eax,%ebx
801079dd:	e8 ba c4 ff ff       	call   80103e9c <mycpu>
801079e2:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801079e8:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801079eb:	e8 ac c4 ff ff       	call   80103e9c <mycpu>
801079f0:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801079f6:	83 ec 0c             	sub    $0xc,%esp
801079f9:	6a 28                	push   $0x28
801079fb:	e8 cc f8 ff ff       	call   801072cc <ltr>
80107a00:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107a03:	8b 45 08             	mov    0x8(%ebp),%eax
80107a06:	8b 40 04             	mov    0x4(%eax),%eax
80107a09:	05 00 00 00 80       	add    $0x80000000,%eax
80107a0e:	83 ec 0c             	sub    $0xc,%esp
80107a11:	50                   	push   %eax
80107a12:	e8 cc f8 ff ff       	call   801072e3 <lcr3>
80107a17:	83 c4 10             	add    $0x10,%esp
  popcli();
80107a1a:	e8 71 d3 ff ff       	call   80104d90 <popcli>
}
80107a1f:	90                   	nop
80107a20:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107a23:	5b                   	pop    %ebx
80107a24:	5e                   	pop    %esi
80107a25:	5d                   	pop    %ebp
80107a26:	c3                   	ret    

80107a27 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107a27:	55                   	push   %ebp
80107a28:	89 e5                	mov    %esp,%ebp
80107a2a:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107a2d:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107a34:	76 0d                	jbe    80107a43 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107a36:	83 ec 0c             	sub    $0xc,%esp
80107a39:	68 b1 a9 10 80       	push   $0x8010a9b1
80107a3e:	e8 66 8b ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107a43:	e8 3c b2 ff ff       	call   80102c84 <kalloc>
80107a48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107a4b:	83 ec 04             	sub    $0x4,%esp
80107a4e:	68 00 10 00 00       	push   $0x1000
80107a53:	6a 00                	push   $0x0
80107a55:	ff 75 f4             	push   -0xc(%ebp)
80107a58:	e8 f1 d3 ff ff       	call   80104e4e <memset>
80107a5d:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a63:	05 00 00 00 80       	add    $0x80000000,%eax
80107a68:	83 ec 0c             	sub    $0xc,%esp
80107a6b:	6a 06                	push   $0x6
80107a6d:	50                   	push   %eax
80107a6e:	68 00 10 00 00       	push   $0x1000
80107a73:	6a 00                	push   $0x0
80107a75:	ff 75 08             	push   0x8(%ebp)
80107a78:	e8 5e fc ff ff       	call   801076db <mappages>
80107a7d:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107a80:	83 ec 04             	sub    $0x4,%esp
80107a83:	ff 75 10             	push   0x10(%ebp)
80107a86:	ff 75 0c             	push   0xc(%ebp)
80107a89:	ff 75 f4             	push   -0xc(%ebp)
80107a8c:	e8 7c d4 ff ff       	call   80104f0d <memmove>
80107a91:	83 c4 10             	add    $0x10,%esp
}
80107a94:	90                   	nop
80107a95:	c9                   	leave  
80107a96:	c3                   	ret    

80107a97 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107a97:	55                   	push   %ebp
80107a98:	89 e5                	mov    %esp,%ebp
80107a9a:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107aa0:	25 ff 0f 00 00       	and    $0xfff,%eax
80107aa5:	85 c0                	test   %eax,%eax
80107aa7:	74 0d                	je     80107ab6 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107aa9:	83 ec 0c             	sub    $0xc,%esp
80107aac:	68 cc a9 10 80       	push   $0x8010a9cc
80107ab1:	e8 f3 8a ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107ab6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107abd:	e9 8f 00 00 00       	jmp    80107b51 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac8:	01 d0                	add    %edx,%eax
80107aca:	83 ec 04             	sub    $0x4,%esp
80107acd:	6a 00                	push   $0x0
80107acf:	50                   	push   %eax
80107ad0:	ff 75 08             	push   0x8(%ebp)
80107ad3:	e8 6d fb ff ff       	call   80107645 <walkpgdir>
80107ad8:	83 c4 10             	add    $0x10,%esp
80107adb:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ade:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ae2:	75 0d                	jne    80107af1 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107ae4:	83 ec 0c             	sub    $0xc,%esp
80107ae7:	68 ef a9 10 80       	push   $0x8010a9ef
80107aec:	e8 b8 8a ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107af1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107af4:	8b 00                	mov    (%eax),%eax
80107af6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107afb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107afe:	8b 45 18             	mov    0x18(%ebp),%eax
80107b01:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b04:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107b09:	77 0b                	ja     80107b16 <loaduvm+0x7f>
      n = sz - i;
80107b0b:	8b 45 18             	mov    0x18(%ebp),%eax
80107b0e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b11:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b14:	eb 07                	jmp    80107b1d <loaduvm+0x86>
    else
      n = PGSIZE;
80107b16:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107b1d:	8b 55 14             	mov    0x14(%ebp),%edx
80107b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b23:	01 d0                	add    %edx,%eax
80107b25:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107b28:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107b2e:	ff 75 f0             	push   -0x10(%ebp)
80107b31:	50                   	push   %eax
80107b32:	52                   	push   %edx
80107b33:	ff 75 10             	push   0x10(%ebp)
80107b36:	e8 9b a3 ff ff       	call   80101ed6 <readi>
80107b3b:	83 c4 10             	add    $0x10,%esp
80107b3e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107b41:	74 07                	je     80107b4a <loaduvm+0xb3>
      return -1;
80107b43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b48:	eb 18                	jmp    80107b62 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107b4a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b54:	3b 45 18             	cmp    0x18(%ebp),%eax
80107b57:	0f 82 65 ff ff ff    	jb     80107ac2 <loaduvm+0x2b>
  }
  return 0;
80107b5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b62:	c9                   	leave  
80107b63:	c3                   	ret    

80107b64 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107b64:	55                   	push   %ebp
80107b65:	89 e5                	mov    %esp,%ebp
80107b67:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107b6a:	8b 45 10             	mov    0x10(%ebp),%eax
80107b6d:	85 c0                	test   %eax,%eax
80107b6f:	79 0a                	jns    80107b7b <allocuvm+0x17>
    return 0;
80107b71:	b8 00 00 00 00       	mov    $0x0,%eax
80107b76:	e9 ec 00 00 00       	jmp    80107c67 <allocuvm+0x103>
  if(newsz < oldsz)
80107b7b:	8b 45 10             	mov    0x10(%ebp),%eax
80107b7e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107b81:	73 08                	jae    80107b8b <allocuvm+0x27>
    return oldsz;
80107b83:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b86:	e9 dc 00 00 00       	jmp    80107c67 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b8e:	05 ff 0f 00 00       	add    $0xfff,%eax
80107b93:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b98:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107b9b:	e9 b8 00 00 00       	jmp    80107c58 <allocuvm+0xf4>
    mem = kalloc();
80107ba0:	e8 df b0 ff ff       	call   80102c84 <kalloc>
80107ba5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107ba8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bac:	75 2e                	jne    80107bdc <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107bae:	83 ec 0c             	sub    $0xc,%esp
80107bb1:	68 0d aa 10 80       	push   $0x8010aa0d
80107bb6:	e8 39 88 ff ff       	call   801003f4 <cprintf>
80107bbb:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107bbe:	83 ec 04             	sub    $0x4,%esp
80107bc1:	ff 75 0c             	push   0xc(%ebp)
80107bc4:	ff 75 10             	push   0x10(%ebp)
80107bc7:	ff 75 08             	push   0x8(%ebp)
80107bca:	e8 9a 00 00 00       	call   80107c69 <deallocuvm>
80107bcf:	83 c4 10             	add    $0x10,%esp
      return 0;
80107bd2:	b8 00 00 00 00       	mov    $0x0,%eax
80107bd7:	e9 8b 00 00 00       	jmp    80107c67 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107bdc:	83 ec 04             	sub    $0x4,%esp
80107bdf:	68 00 10 00 00       	push   $0x1000
80107be4:	6a 00                	push   $0x0
80107be6:	ff 75 f0             	push   -0x10(%ebp)
80107be9:	e8 60 d2 ff ff       	call   80104e4e <memset>
80107bee:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107bf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bf4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfd:	83 ec 0c             	sub    $0xc,%esp
80107c00:	6a 06                	push   $0x6
80107c02:	52                   	push   %edx
80107c03:	68 00 10 00 00       	push   $0x1000
80107c08:	50                   	push   %eax
80107c09:	ff 75 08             	push   0x8(%ebp)
80107c0c:	e8 ca fa ff ff       	call   801076db <mappages>
80107c11:	83 c4 20             	add    $0x20,%esp
80107c14:	85 c0                	test   %eax,%eax
80107c16:	79 39                	jns    80107c51 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107c18:	83 ec 0c             	sub    $0xc,%esp
80107c1b:	68 25 aa 10 80       	push   $0x8010aa25
80107c20:	e8 cf 87 ff ff       	call   801003f4 <cprintf>
80107c25:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107c28:	83 ec 04             	sub    $0x4,%esp
80107c2b:	ff 75 0c             	push   0xc(%ebp)
80107c2e:	ff 75 10             	push   0x10(%ebp)
80107c31:	ff 75 08             	push   0x8(%ebp)
80107c34:	e8 30 00 00 00       	call   80107c69 <deallocuvm>
80107c39:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107c3c:	83 ec 0c             	sub    $0xc,%esp
80107c3f:	ff 75 f0             	push   -0x10(%ebp)
80107c42:	e8 a3 af ff ff       	call   80102bea <kfree>
80107c47:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c4a:	b8 00 00 00 00       	mov    $0x0,%eax
80107c4f:	eb 16                	jmp    80107c67 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107c51:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5b:	3b 45 10             	cmp    0x10(%ebp),%eax
80107c5e:	0f 82 3c ff ff ff    	jb     80107ba0 <allocuvm+0x3c>
    }
  }
  return newsz;
80107c64:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107c67:	c9                   	leave  
80107c68:	c3                   	ret    

80107c69 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107c69:	55                   	push   %ebp
80107c6a:	89 e5                	mov    %esp,%ebp
80107c6c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107c6f:	8b 45 10             	mov    0x10(%ebp),%eax
80107c72:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c75:	72 08                	jb     80107c7f <deallocuvm+0x16>
    return oldsz;
80107c77:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c7a:	e9 ac 00 00 00       	jmp    80107d2b <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107c7f:	8b 45 10             	mov    0x10(%ebp),%eax
80107c82:	05 ff 0f 00 00       	add    $0xfff,%eax
80107c87:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107c8f:	e9 88 00 00 00       	jmp    80107d1c <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c97:	83 ec 04             	sub    $0x4,%esp
80107c9a:	6a 00                	push   $0x0
80107c9c:	50                   	push   %eax
80107c9d:	ff 75 08             	push   0x8(%ebp)
80107ca0:	e8 a0 f9 ff ff       	call   80107645 <walkpgdir>
80107ca5:	83 c4 10             	add    $0x10,%esp
80107ca8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107cab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107caf:	75 16                	jne    80107cc7 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb4:	c1 e8 16             	shr    $0x16,%eax
80107cb7:	83 c0 01             	add    $0x1,%eax
80107cba:	c1 e0 16             	shl    $0x16,%eax
80107cbd:	2d 00 10 00 00       	sub    $0x1000,%eax
80107cc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107cc5:	eb 4e                	jmp    80107d15 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cca:	8b 00                	mov    (%eax),%eax
80107ccc:	83 e0 01             	and    $0x1,%eax
80107ccf:	85 c0                	test   %eax,%eax
80107cd1:	74 42                	je     80107d15 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cd6:	8b 00                	mov    (%eax),%eax
80107cd8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107ce0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ce4:	75 0d                	jne    80107cf3 <deallocuvm+0x8a>
        panic("kfree");
80107ce6:	83 ec 0c             	sub    $0xc,%esp
80107ce9:	68 41 aa 10 80       	push   $0x8010aa41
80107cee:	e8 b6 88 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107cf3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cf6:	05 00 00 00 80       	add    $0x80000000,%eax
80107cfb:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107cfe:	83 ec 0c             	sub    $0xc,%esp
80107d01:	ff 75 e8             	push   -0x18(%ebp)
80107d04:	e8 e1 ae ff ff       	call   80102bea <kfree>
80107d09:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107d0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107d15:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d22:	0f 82 6c ff ff ff    	jb     80107c94 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107d28:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107d2b:	c9                   	leave  
80107d2c:	c3                   	ret    

80107d2d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107d2d:	55                   	push   %ebp
80107d2e:	89 e5                	mov    %esp,%ebp
80107d30:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107d33:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107d37:	75 0d                	jne    80107d46 <freevm+0x19>
    panic("freevm: no pgdir");
80107d39:	83 ec 0c             	sub    $0xc,%esp
80107d3c:	68 47 aa 10 80       	push   $0x8010aa47
80107d41:	e8 63 88 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107d46:	83 ec 04             	sub    $0x4,%esp
80107d49:	6a 00                	push   $0x0
80107d4b:	68 00 00 00 80       	push   $0x80000000
80107d50:	ff 75 08             	push   0x8(%ebp)
80107d53:	e8 11 ff ff ff       	call   80107c69 <deallocuvm>
80107d58:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107d5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d62:	eb 48                	jmp    80107dac <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d67:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80107d71:	01 d0                	add    %edx,%eax
80107d73:	8b 00                	mov    (%eax),%eax
80107d75:	83 e0 01             	and    $0x1,%eax
80107d78:	85 c0                	test   %eax,%eax
80107d7a:	74 2c                	je     80107da8 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d86:	8b 45 08             	mov    0x8(%ebp),%eax
80107d89:	01 d0                	add    %edx,%eax
80107d8b:	8b 00                	mov    (%eax),%eax
80107d8d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d92:	05 00 00 00 80       	add    $0x80000000,%eax
80107d97:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107d9a:	83 ec 0c             	sub    $0xc,%esp
80107d9d:	ff 75 f0             	push   -0x10(%ebp)
80107da0:	e8 45 ae ff ff       	call   80102bea <kfree>
80107da5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107da8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107dac:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107db3:	76 af                	jbe    80107d64 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107db5:	83 ec 0c             	sub    $0xc,%esp
80107db8:	ff 75 08             	push   0x8(%ebp)
80107dbb:	e8 2a ae ff ff       	call   80102bea <kfree>
80107dc0:	83 c4 10             	add    $0x10,%esp
}
80107dc3:	90                   	nop
80107dc4:	c9                   	leave  
80107dc5:	c3                   	ret    

80107dc6 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107dc6:	55                   	push   %ebp
80107dc7:	89 e5                	mov    %esp,%ebp
80107dc9:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107dcc:	83 ec 04             	sub    $0x4,%esp
80107dcf:	6a 00                	push   $0x0
80107dd1:	ff 75 0c             	push   0xc(%ebp)
80107dd4:	ff 75 08             	push   0x8(%ebp)
80107dd7:	e8 69 f8 ff ff       	call   80107645 <walkpgdir>
80107ddc:	83 c4 10             	add    $0x10,%esp
80107ddf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107de2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107de6:	75 0d                	jne    80107df5 <clearpteu+0x2f>
    panic("clearpteu");
80107de8:	83 ec 0c             	sub    $0xc,%esp
80107deb:	68 58 aa 10 80       	push   $0x8010aa58
80107df0:	e8 b4 87 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df8:	8b 00                	mov    (%eax),%eax
80107dfa:	83 e0 fb             	and    $0xfffffffb,%eax
80107dfd:	89 c2                	mov    %eax,%edx
80107dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e02:	89 10                	mov    %edx,(%eax)
}
80107e04:	90                   	nop
80107e05:	c9                   	leave  
80107e06:	c3                   	ret    

80107e07 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107e07:	55                   	push   %ebp
80107e08:	89 e5                	mov    %esp,%ebp
80107e0a:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107e0d:	e8 59 f9 ff ff       	call   8010776b <setupkvm>
80107e12:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e15:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e19:	75 0a                	jne    80107e25 <copyuvm+0x1e>
    return 0;
80107e1b:	b8 00 00 00 00       	mov    $0x0,%eax
80107e20:	e9 eb 00 00 00       	jmp    80107f10 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107e25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e2c:	e9 b7 00 00 00       	jmp    80107ee8 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e34:	83 ec 04             	sub    $0x4,%esp
80107e37:	6a 00                	push   $0x0
80107e39:	50                   	push   %eax
80107e3a:	ff 75 08             	push   0x8(%ebp)
80107e3d:	e8 03 f8 ff ff       	call   80107645 <walkpgdir>
80107e42:	83 c4 10             	add    $0x10,%esp
80107e45:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e48:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e4c:	75 0d                	jne    80107e5b <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107e4e:	83 ec 0c             	sub    $0xc,%esp
80107e51:	68 62 aa 10 80       	push   $0x8010aa62
80107e56:	e8 4e 87 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107e5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e5e:	8b 00                	mov    (%eax),%eax
80107e60:	83 e0 01             	and    $0x1,%eax
80107e63:	85 c0                	test   %eax,%eax
80107e65:	75 0d                	jne    80107e74 <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107e67:	83 ec 0c             	sub    $0xc,%esp
80107e6a:	68 7c aa 10 80       	push   $0x8010aa7c
80107e6f:	e8 35 87 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107e74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e77:	8b 00                	mov    (%eax),%eax
80107e79:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107e81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e84:	8b 00                	mov    (%eax),%eax
80107e86:	25 ff 0f 00 00       	and    $0xfff,%eax
80107e8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107e8e:	e8 f1 ad ff ff       	call   80102c84 <kalloc>
80107e93:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107e96:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107e9a:	74 5d                	je     80107ef9 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107e9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107e9f:	05 00 00 00 80       	add    $0x80000000,%eax
80107ea4:	83 ec 04             	sub    $0x4,%esp
80107ea7:	68 00 10 00 00       	push   $0x1000
80107eac:	50                   	push   %eax
80107ead:	ff 75 e0             	push   -0x20(%ebp)
80107eb0:	e8 58 d0 ff ff       	call   80104f0d <memmove>
80107eb5:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107eb8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107ebb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107ebe:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec7:	83 ec 0c             	sub    $0xc,%esp
80107eca:	52                   	push   %edx
80107ecb:	51                   	push   %ecx
80107ecc:	68 00 10 00 00       	push   $0x1000
80107ed1:	50                   	push   %eax
80107ed2:	ff 75 f0             	push   -0x10(%ebp)
80107ed5:	e8 01 f8 ff ff       	call   801076db <mappages>
80107eda:	83 c4 20             	add    $0x20,%esp
80107edd:	85 c0                	test   %eax,%eax
80107edf:	78 1b                	js     80107efc <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107ee1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eeb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107eee:	0f 82 3d ff ff ff    	jb     80107e31 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107ef4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ef7:	eb 17                	jmp    80107f10 <copyuvm+0x109>
      goto bad;
80107ef9:	90                   	nop
80107efa:	eb 01                	jmp    80107efd <copyuvm+0xf6>
      goto bad;
80107efc:	90                   	nop

bad:
  freevm(d);
80107efd:	83 ec 0c             	sub    $0xc,%esp
80107f00:	ff 75 f0             	push   -0x10(%ebp)
80107f03:	e8 25 fe ff ff       	call   80107d2d <freevm>
80107f08:	83 c4 10             	add    $0x10,%esp
  return 0;
80107f0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f10:	c9                   	leave  
80107f11:	c3                   	ret    

80107f12 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107f12:	55                   	push   %ebp
80107f13:	89 e5                	mov    %esp,%ebp
80107f15:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f18:	83 ec 04             	sub    $0x4,%esp
80107f1b:	6a 00                	push   $0x0
80107f1d:	ff 75 0c             	push   0xc(%ebp)
80107f20:	ff 75 08             	push   0x8(%ebp)
80107f23:	e8 1d f7 ff ff       	call   80107645 <walkpgdir>
80107f28:	83 c4 10             	add    $0x10,%esp
80107f2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f31:	8b 00                	mov    (%eax),%eax
80107f33:	83 e0 01             	and    $0x1,%eax
80107f36:	85 c0                	test   %eax,%eax
80107f38:	75 07                	jne    80107f41 <uva2ka+0x2f>
    return 0;
80107f3a:	b8 00 00 00 00       	mov    $0x0,%eax
80107f3f:	eb 22                	jmp    80107f63 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f44:	8b 00                	mov    (%eax),%eax
80107f46:	83 e0 04             	and    $0x4,%eax
80107f49:	85 c0                	test   %eax,%eax
80107f4b:	75 07                	jne    80107f54 <uva2ka+0x42>
    return 0;
80107f4d:	b8 00 00 00 00       	mov    $0x0,%eax
80107f52:	eb 0f                	jmp    80107f63 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f57:	8b 00                	mov    (%eax),%eax
80107f59:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f5e:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107f63:	c9                   	leave  
80107f64:	c3                   	ret    

80107f65 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107f65:	55                   	push   %ebp
80107f66:	89 e5                	mov    %esp,%ebp
80107f68:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107f6b:	8b 45 10             	mov    0x10(%ebp),%eax
80107f6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107f71:	eb 7f                	jmp    80107ff2 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107f73:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f76:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107f7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f81:	83 ec 08             	sub    $0x8,%esp
80107f84:	50                   	push   %eax
80107f85:	ff 75 08             	push   0x8(%ebp)
80107f88:	e8 85 ff ff ff       	call   80107f12 <uva2ka>
80107f8d:	83 c4 10             	add    $0x10,%esp
80107f90:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107f93:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107f97:	75 07                	jne    80107fa0 <copyout+0x3b>
      return -1;
80107f99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f9e:	eb 61                	jmp    80108001 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107fa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fa3:	2b 45 0c             	sub    0xc(%ebp),%eax
80107fa6:	05 00 10 00 00       	add    $0x1000,%eax
80107fab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107fae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fb1:	3b 45 14             	cmp    0x14(%ebp),%eax
80107fb4:	76 06                	jbe    80107fbc <copyout+0x57>
      n = len;
80107fb6:	8b 45 14             	mov    0x14(%ebp),%eax
80107fb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107fbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fbf:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107fc2:	89 c2                	mov    %eax,%edx
80107fc4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107fc7:	01 d0                	add    %edx,%eax
80107fc9:	83 ec 04             	sub    $0x4,%esp
80107fcc:	ff 75 f0             	push   -0x10(%ebp)
80107fcf:	ff 75 f4             	push   -0xc(%ebp)
80107fd2:	50                   	push   %eax
80107fd3:	e8 35 cf ff ff       	call   80104f0d <memmove>
80107fd8:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107fdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fde:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fe4:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fea:	05 00 10 00 00       	add    $0x1000,%eax
80107fef:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107ff2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107ff6:	0f 85 77 ff ff ff    	jne    80107f73 <copyout+0xe>
  }
  return 0;
80107ffc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108001:	c9                   	leave  
80108002:	c3                   	ret    

80108003 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108003:	55                   	push   %ebp
80108004:	89 e5                	mov    %esp,%ebp
80108006:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108009:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108010:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108013:	8b 40 08             	mov    0x8(%eax),%eax
80108016:	05 00 00 00 80       	add    $0x80000000,%eax
8010801b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
8010801e:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108028:	8b 40 24             	mov    0x24(%eax),%eax
8010802b:	a3 40 71 11 80       	mov    %eax,0x80117140
  ncpu = 0;
80108030:	c7 05 80 9d 11 80 00 	movl   $0x0,0x80119d80
80108037:	00 00 00 

  while(i<madt->len){
8010803a:	90                   	nop
8010803b:	e9 bd 00 00 00       	jmp    801080fd <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80108040:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108043:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108046:	01 d0                	add    %edx,%eax
80108048:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010804b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010804e:	0f b6 00             	movzbl (%eax),%eax
80108051:	0f b6 c0             	movzbl %al,%eax
80108054:	83 f8 05             	cmp    $0x5,%eax
80108057:	0f 87 a0 00 00 00    	ja     801080fd <mpinit_uefi+0xfa>
8010805d:	8b 04 85 98 aa 10 80 	mov    -0x7fef5568(,%eax,4),%eax
80108064:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108066:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108069:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
8010806c:	a1 80 9d 11 80       	mov    0x80119d80,%eax
80108071:	83 f8 03             	cmp    $0x3,%eax
80108074:	7f 28                	jg     8010809e <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108076:	8b 15 80 9d 11 80    	mov    0x80119d80,%edx
8010807c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010807f:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108083:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80108089:	81 c2 c0 9a 11 80    	add    $0x80119ac0,%edx
8010808f:	88 02                	mov    %al,(%edx)
          ncpu++;
80108091:	a1 80 9d 11 80       	mov    0x80119d80,%eax
80108096:	83 c0 01             	add    $0x1,%eax
80108099:	a3 80 9d 11 80       	mov    %eax,0x80119d80
        }
        i += lapic_entry->record_len;
8010809e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080a1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801080a5:	0f b6 c0             	movzbl %al,%eax
801080a8:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801080ab:	eb 50                	jmp    801080fd <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801080ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801080b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801080b6:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801080ba:	a2 84 9d 11 80       	mov    %al,0x80119d84
        i += ioapic->record_len;
801080bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801080c2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801080c6:	0f b6 c0             	movzbl %al,%eax
801080c9:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801080cc:	eb 2f                	jmp    801080fd <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801080ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801080d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801080d7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801080db:	0f b6 c0             	movzbl %al,%eax
801080de:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801080e1:	eb 1a                	jmp    801080fd <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801080e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801080e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080ec:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801080f0:	0f b6 c0             	movzbl %al,%eax
801080f3:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801080f6:	eb 05                	jmp    801080fd <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
801080f8:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801080fc:	90                   	nop
  while(i<madt->len){
801080fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108100:	8b 40 04             	mov    0x4(%eax),%eax
80108103:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108106:	0f 82 34 ff ff ff    	jb     80108040 <mpinit_uefi+0x3d>
    }
  }

}
8010810c:	90                   	nop
8010810d:	90                   	nop
8010810e:	c9                   	leave  
8010810f:	c3                   	ret    

80108110 <inb>:
{
80108110:	55                   	push   %ebp
80108111:	89 e5                	mov    %esp,%ebp
80108113:	83 ec 14             	sub    $0x14,%esp
80108116:	8b 45 08             	mov    0x8(%ebp),%eax
80108119:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010811d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108121:	89 c2                	mov    %eax,%edx
80108123:	ec                   	in     (%dx),%al
80108124:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108127:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010812b:	c9                   	leave  
8010812c:	c3                   	ret    

8010812d <outb>:
{
8010812d:	55                   	push   %ebp
8010812e:	89 e5                	mov    %esp,%ebp
80108130:	83 ec 08             	sub    $0x8,%esp
80108133:	8b 45 08             	mov    0x8(%ebp),%eax
80108136:	8b 55 0c             	mov    0xc(%ebp),%edx
80108139:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010813d:	89 d0                	mov    %edx,%eax
8010813f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108142:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108146:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010814a:	ee                   	out    %al,(%dx)
}
8010814b:	90                   	nop
8010814c:	c9                   	leave  
8010814d:	c3                   	ret    

8010814e <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
8010814e:	55                   	push   %ebp
8010814f:	89 e5                	mov    %esp,%ebp
80108151:	83 ec 28             	sub    $0x28,%esp
80108154:	8b 45 08             	mov    0x8(%ebp),%eax
80108157:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010815a:	6a 00                	push   $0x0
8010815c:	68 fa 03 00 00       	push   $0x3fa
80108161:	e8 c7 ff ff ff       	call   8010812d <outb>
80108166:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108169:	68 80 00 00 00       	push   $0x80
8010816e:	68 fb 03 00 00       	push   $0x3fb
80108173:	e8 b5 ff ff ff       	call   8010812d <outb>
80108178:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010817b:	6a 0c                	push   $0xc
8010817d:	68 f8 03 00 00       	push   $0x3f8
80108182:	e8 a6 ff ff ff       	call   8010812d <outb>
80108187:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010818a:	6a 00                	push   $0x0
8010818c:	68 f9 03 00 00       	push   $0x3f9
80108191:	e8 97 ff ff ff       	call   8010812d <outb>
80108196:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108199:	6a 03                	push   $0x3
8010819b:	68 fb 03 00 00       	push   $0x3fb
801081a0:	e8 88 ff ff ff       	call   8010812d <outb>
801081a5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801081a8:	6a 00                	push   $0x0
801081aa:	68 fc 03 00 00       	push   $0x3fc
801081af:	e8 79 ff ff ff       	call   8010812d <outb>
801081b4:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801081b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081be:	eb 11                	jmp    801081d1 <uart_debug+0x83>
801081c0:	83 ec 0c             	sub    $0xc,%esp
801081c3:	6a 0a                	push   $0xa
801081c5:	e8 51 ae ff ff       	call   8010301b <microdelay>
801081ca:	83 c4 10             	add    $0x10,%esp
801081cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801081d1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801081d5:	7f 1a                	jg     801081f1 <uart_debug+0xa3>
801081d7:	83 ec 0c             	sub    $0xc,%esp
801081da:	68 fd 03 00 00       	push   $0x3fd
801081df:	e8 2c ff ff ff       	call   80108110 <inb>
801081e4:	83 c4 10             	add    $0x10,%esp
801081e7:	0f b6 c0             	movzbl %al,%eax
801081ea:	83 e0 20             	and    $0x20,%eax
801081ed:	85 c0                	test   %eax,%eax
801081ef:	74 cf                	je     801081c0 <uart_debug+0x72>
  outb(COM1+0, p);
801081f1:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801081f5:	0f b6 c0             	movzbl %al,%eax
801081f8:	83 ec 08             	sub    $0x8,%esp
801081fb:	50                   	push   %eax
801081fc:	68 f8 03 00 00       	push   $0x3f8
80108201:	e8 27 ff ff ff       	call   8010812d <outb>
80108206:	83 c4 10             	add    $0x10,%esp
}
80108209:	90                   	nop
8010820a:	c9                   	leave  
8010820b:	c3                   	ret    

8010820c <uart_debugs>:

void uart_debugs(char *p){
8010820c:	55                   	push   %ebp
8010820d:	89 e5                	mov    %esp,%ebp
8010820f:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108212:	eb 1b                	jmp    8010822f <uart_debugs+0x23>
    uart_debug(*p++);
80108214:	8b 45 08             	mov    0x8(%ebp),%eax
80108217:	8d 50 01             	lea    0x1(%eax),%edx
8010821a:	89 55 08             	mov    %edx,0x8(%ebp)
8010821d:	0f b6 00             	movzbl (%eax),%eax
80108220:	0f be c0             	movsbl %al,%eax
80108223:	83 ec 0c             	sub    $0xc,%esp
80108226:	50                   	push   %eax
80108227:	e8 22 ff ff ff       	call   8010814e <uart_debug>
8010822c:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010822f:	8b 45 08             	mov    0x8(%ebp),%eax
80108232:	0f b6 00             	movzbl (%eax),%eax
80108235:	84 c0                	test   %al,%al
80108237:	75 db                	jne    80108214 <uart_debugs+0x8>
  }
}
80108239:	90                   	nop
8010823a:	90                   	nop
8010823b:	c9                   	leave  
8010823c:	c3                   	ret    

8010823d <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010823d:	55                   	push   %ebp
8010823e:	89 e5                	mov    %esp,%ebp
80108240:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108243:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010824a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010824d:	8b 50 14             	mov    0x14(%eax),%edx
80108250:	8b 40 10             	mov    0x10(%eax),%eax
80108253:	a3 88 9d 11 80       	mov    %eax,0x80119d88
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108258:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010825b:	8b 50 1c             	mov    0x1c(%eax),%edx
8010825e:	8b 40 18             	mov    0x18(%eax),%eax
80108261:	a3 90 9d 11 80       	mov    %eax,0x80119d90
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108266:	8b 15 90 9d 11 80    	mov    0x80119d90,%edx
8010826c:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80108271:	29 d0                	sub    %edx,%eax
80108273:	a3 8c 9d 11 80       	mov    %eax,0x80119d8c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108278:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010827b:	8b 50 24             	mov    0x24(%eax),%edx
8010827e:	8b 40 20             	mov    0x20(%eax),%eax
80108281:	a3 94 9d 11 80       	mov    %eax,0x80119d94
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108286:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108289:	8b 50 2c             	mov    0x2c(%eax),%edx
8010828c:	8b 40 28             	mov    0x28(%eax),%eax
8010828f:	a3 98 9d 11 80       	mov    %eax,0x80119d98
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108294:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108297:	8b 50 34             	mov    0x34(%eax),%edx
8010829a:	8b 40 30             	mov    0x30(%eax),%eax
8010829d:	a3 9c 9d 11 80       	mov    %eax,0x80119d9c
}
801082a2:	90                   	nop
801082a3:	c9                   	leave  
801082a4:	c3                   	ret    

801082a5 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801082a5:	55                   	push   %ebp
801082a6:	89 e5                	mov    %esp,%ebp
801082a8:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801082ab:	8b 15 9c 9d 11 80    	mov    0x80119d9c,%edx
801082b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801082b4:	0f af d0             	imul   %eax,%edx
801082b7:	8b 45 08             	mov    0x8(%ebp),%eax
801082ba:	01 d0                	add    %edx,%eax
801082bc:	c1 e0 02             	shl    $0x2,%eax
801082bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801082c2:	8b 15 8c 9d 11 80    	mov    0x80119d8c,%edx
801082c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082cb:	01 d0                	add    %edx,%eax
801082cd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801082d0:	8b 45 10             	mov    0x10(%ebp),%eax
801082d3:	0f b6 10             	movzbl (%eax),%edx
801082d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801082d9:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801082db:	8b 45 10             	mov    0x10(%ebp),%eax
801082de:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801082e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801082e5:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801082e8:	8b 45 10             	mov    0x10(%ebp),%eax
801082eb:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801082ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
801082f2:	88 50 02             	mov    %dl,0x2(%eax)
}
801082f5:	90                   	nop
801082f6:	c9                   	leave  
801082f7:	c3                   	ret    

801082f8 <graphic_scroll_up>:

void graphic_scroll_up(int height){
801082f8:	55                   	push   %ebp
801082f9:	89 e5                	mov    %esp,%ebp
801082fb:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801082fe:	8b 15 9c 9d 11 80    	mov    0x80119d9c,%edx
80108304:	8b 45 08             	mov    0x8(%ebp),%eax
80108307:	0f af c2             	imul   %edx,%eax
8010830a:	c1 e0 02             	shl    $0x2,%eax
8010830d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108310:	a1 90 9d 11 80       	mov    0x80119d90,%eax
80108315:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108318:	29 d0                	sub    %edx,%eax
8010831a:	8b 0d 8c 9d 11 80    	mov    0x80119d8c,%ecx
80108320:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108323:	01 ca                	add    %ecx,%edx
80108325:	89 d1                	mov    %edx,%ecx
80108327:	8b 15 8c 9d 11 80    	mov    0x80119d8c,%edx
8010832d:	83 ec 04             	sub    $0x4,%esp
80108330:	50                   	push   %eax
80108331:	51                   	push   %ecx
80108332:	52                   	push   %edx
80108333:	e8 d5 cb ff ff       	call   80104f0d <memmove>
80108338:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
8010833b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833e:	8b 0d 8c 9d 11 80    	mov    0x80119d8c,%ecx
80108344:	8b 15 90 9d 11 80    	mov    0x80119d90,%edx
8010834a:	01 ca                	add    %ecx,%edx
8010834c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010834f:	29 ca                	sub    %ecx,%edx
80108351:	83 ec 04             	sub    $0x4,%esp
80108354:	50                   	push   %eax
80108355:	6a 00                	push   $0x0
80108357:	52                   	push   %edx
80108358:	e8 f1 ca ff ff       	call   80104e4e <memset>
8010835d:	83 c4 10             	add    $0x10,%esp
}
80108360:	90                   	nop
80108361:	c9                   	leave  
80108362:	c3                   	ret    

80108363 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108363:	55                   	push   %ebp
80108364:	89 e5                	mov    %esp,%ebp
80108366:	53                   	push   %ebx
80108367:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010836a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108371:	e9 b1 00 00 00       	jmp    80108427 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108376:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
8010837d:	e9 97 00 00 00       	jmp    80108419 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108382:	8b 45 10             	mov    0x10(%ebp),%eax
80108385:	83 e8 20             	sub    $0x20,%eax
80108388:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010838b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838e:	01 d0                	add    %edx,%eax
80108390:	0f b7 84 00 c0 aa 10 	movzwl -0x7fef5540(%eax,%eax,1),%eax
80108397:	80 
80108398:	0f b7 d0             	movzwl %ax,%edx
8010839b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010839e:	bb 01 00 00 00       	mov    $0x1,%ebx
801083a3:	89 c1                	mov    %eax,%ecx
801083a5:	d3 e3                	shl    %cl,%ebx
801083a7:	89 d8                	mov    %ebx,%eax
801083a9:	21 d0                	and    %edx,%eax
801083ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801083ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083b1:	ba 01 00 00 00       	mov    $0x1,%edx
801083b6:	89 c1                	mov    %eax,%ecx
801083b8:	d3 e2                	shl    %cl,%edx
801083ba:	89 d0                	mov    %edx,%eax
801083bc:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801083bf:	75 2b                	jne    801083ec <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801083c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801083c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c7:	01 c2                	add    %eax,%edx
801083c9:	b8 0e 00 00 00       	mov    $0xe,%eax
801083ce:	2b 45 f0             	sub    -0x10(%ebp),%eax
801083d1:	89 c1                	mov    %eax,%ecx
801083d3:	8b 45 08             	mov    0x8(%ebp),%eax
801083d6:	01 c8                	add    %ecx,%eax
801083d8:	83 ec 04             	sub    $0x4,%esp
801083db:	68 e0 f4 10 80       	push   $0x8010f4e0
801083e0:	52                   	push   %edx
801083e1:	50                   	push   %eax
801083e2:	e8 be fe ff ff       	call   801082a5 <graphic_draw_pixel>
801083e7:	83 c4 10             	add    $0x10,%esp
801083ea:	eb 29                	jmp    80108415 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801083ec:	8b 55 0c             	mov    0xc(%ebp),%edx
801083ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f2:	01 c2                	add    %eax,%edx
801083f4:	b8 0e 00 00 00       	mov    $0xe,%eax
801083f9:	2b 45 f0             	sub    -0x10(%ebp),%eax
801083fc:	89 c1                	mov    %eax,%ecx
801083fe:	8b 45 08             	mov    0x8(%ebp),%eax
80108401:	01 c8                	add    %ecx,%eax
80108403:	83 ec 04             	sub    $0x4,%esp
80108406:	68 a0 9d 11 80       	push   $0x80119da0
8010840b:	52                   	push   %edx
8010840c:	50                   	push   %eax
8010840d:	e8 93 fe ff ff       	call   801082a5 <graphic_draw_pixel>
80108412:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108415:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108419:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010841d:	0f 89 5f ff ff ff    	jns    80108382 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108423:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108427:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010842b:	0f 8e 45 ff ff ff    	jle    80108376 <font_render+0x13>
      }
    }
  }
}
80108431:	90                   	nop
80108432:	90                   	nop
80108433:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108436:	c9                   	leave  
80108437:	c3                   	ret    

80108438 <font_render_string>:

void font_render_string(char *string,int row){
80108438:	55                   	push   %ebp
80108439:	89 e5                	mov    %esp,%ebp
8010843b:	53                   	push   %ebx
8010843c:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
8010843f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108446:	eb 33                	jmp    8010847b <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108448:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010844b:	8b 45 08             	mov    0x8(%ebp),%eax
8010844e:	01 d0                	add    %edx,%eax
80108450:	0f b6 00             	movzbl (%eax),%eax
80108453:	0f be c8             	movsbl %al,%ecx
80108456:	8b 45 0c             	mov    0xc(%ebp),%eax
80108459:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010845c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010845f:	89 d8                	mov    %ebx,%eax
80108461:	c1 e0 04             	shl    $0x4,%eax
80108464:	29 d8                	sub    %ebx,%eax
80108466:	83 c0 02             	add    $0x2,%eax
80108469:	83 ec 04             	sub    $0x4,%esp
8010846c:	51                   	push   %ecx
8010846d:	52                   	push   %edx
8010846e:	50                   	push   %eax
8010846f:	e8 ef fe ff ff       	call   80108363 <font_render>
80108474:	83 c4 10             	add    $0x10,%esp
    i++;
80108477:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
8010847b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010847e:	8b 45 08             	mov    0x8(%ebp),%eax
80108481:	01 d0                	add    %edx,%eax
80108483:	0f b6 00             	movzbl (%eax),%eax
80108486:	84 c0                	test   %al,%al
80108488:	74 06                	je     80108490 <font_render_string+0x58>
8010848a:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
8010848e:	7e b8                	jle    80108448 <font_render_string+0x10>
  }
}
80108490:	90                   	nop
80108491:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108494:	c9                   	leave  
80108495:	c3                   	ret    

80108496 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108496:	55                   	push   %ebp
80108497:	89 e5                	mov    %esp,%ebp
80108499:	53                   	push   %ebx
8010849a:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
8010849d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084a4:	eb 6b                	jmp    80108511 <pci_init+0x7b>
    for(int j=0;j<32;j++){
801084a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801084ad:	eb 58                	jmp    80108507 <pci_init+0x71>
      for(int k=0;k<8;k++){
801084af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801084b6:	eb 45                	jmp    801084fd <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801084b8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801084bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801084be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c1:	83 ec 0c             	sub    $0xc,%esp
801084c4:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801084c7:	53                   	push   %ebx
801084c8:	6a 00                	push   $0x0
801084ca:	51                   	push   %ecx
801084cb:	52                   	push   %edx
801084cc:	50                   	push   %eax
801084cd:	e8 b0 00 00 00       	call   80108582 <pci_access_config>
801084d2:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801084d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084d8:	0f b7 c0             	movzwl %ax,%eax
801084db:	3d ff ff 00 00       	cmp    $0xffff,%eax
801084e0:	74 17                	je     801084f9 <pci_init+0x63>
        pci_init_device(i,j,k);
801084e2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801084e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801084e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084eb:	83 ec 04             	sub    $0x4,%esp
801084ee:	51                   	push   %ecx
801084ef:	52                   	push   %edx
801084f0:	50                   	push   %eax
801084f1:	e8 37 01 00 00       	call   8010862d <pci_init_device>
801084f6:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801084f9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801084fd:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108501:	7e b5                	jle    801084b8 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108503:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108507:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
8010850b:	7e a2                	jle    801084af <pci_init+0x19>
  for(int i=0;i<256;i++){
8010850d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108511:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108518:	7e 8c                	jle    801084a6 <pci_init+0x10>
      }
      }
    }
  }
}
8010851a:	90                   	nop
8010851b:	90                   	nop
8010851c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010851f:	c9                   	leave  
80108520:	c3                   	ret    

80108521 <pci_write_config>:

void pci_write_config(uint config){
80108521:	55                   	push   %ebp
80108522:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108524:	8b 45 08             	mov    0x8(%ebp),%eax
80108527:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010852c:	89 c0                	mov    %eax,%eax
8010852e:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010852f:	90                   	nop
80108530:	5d                   	pop    %ebp
80108531:	c3                   	ret    

80108532 <pci_write_data>:

void pci_write_data(uint config){
80108532:	55                   	push   %ebp
80108533:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108535:	8b 45 08             	mov    0x8(%ebp),%eax
80108538:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010853d:	89 c0                	mov    %eax,%eax
8010853f:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108540:	90                   	nop
80108541:	5d                   	pop    %ebp
80108542:	c3                   	ret    

80108543 <pci_read_config>:
uint pci_read_config(){
80108543:	55                   	push   %ebp
80108544:	89 e5                	mov    %esp,%ebp
80108546:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108549:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010854e:	ed                   	in     (%dx),%eax
8010854f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108552:	83 ec 0c             	sub    $0xc,%esp
80108555:	68 c8 00 00 00       	push   $0xc8
8010855a:	e8 bc aa ff ff       	call   8010301b <microdelay>
8010855f:	83 c4 10             	add    $0x10,%esp
  return data;
80108562:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108565:	c9                   	leave  
80108566:	c3                   	ret    

80108567 <pci_test>:


void pci_test(){
80108567:	55                   	push   %ebp
80108568:	89 e5                	mov    %esp,%ebp
8010856a:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
8010856d:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108574:	ff 75 fc             	push   -0x4(%ebp)
80108577:	e8 a5 ff ff ff       	call   80108521 <pci_write_config>
8010857c:	83 c4 04             	add    $0x4,%esp
}
8010857f:	90                   	nop
80108580:	c9                   	leave  
80108581:	c3                   	ret    

80108582 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108582:	55                   	push   %ebp
80108583:	89 e5                	mov    %esp,%ebp
80108585:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108588:	8b 45 08             	mov    0x8(%ebp),%eax
8010858b:	c1 e0 10             	shl    $0x10,%eax
8010858e:	25 00 00 ff 00       	and    $0xff0000,%eax
80108593:	89 c2                	mov    %eax,%edx
80108595:	8b 45 0c             	mov    0xc(%ebp),%eax
80108598:	c1 e0 0b             	shl    $0xb,%eax
8010859b:	0f b7 c0             	movzwl %ax,%eax
8010859e:	09 c2                	or     %eax,%edx
801085a0:	8b 45 10             	mov    0x10(%ebp),%eax
801085a3:	c1 e0 08             	shl    $0x8,%eax
801085a6:	25 00 07 00 00       	and    $0x700,%eax
801085ab:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801085ad:	8b 45 14             	mov    0x14(%ebp),%eax
801085b0:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801085b5:	09 d0                	or     %edx,%eax
801085b7:	0d 00 00 00 80       	or     $0x80000000,%eax
801085bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801085bf:	ff 75 f4             	push   -0xc(%ebp)
801085c2:	e8 5a ff ff ff       	call   80108521 <pci_write_config>
801085c7:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801085ca:	e8 74 ff ff ff       	call   80108543 <pci_read_config>
801085cf:	8b 55 18             	mov    0x18(%ebp),%edx
801085d2:	89 02                	mov    %eax,(%edx)
}
801085d4:	90                   	nop
801085d5:	c9                   	leave  
801085d6:	c3                   	ret    

801085d7 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801085d7:	55                   	push   %ebp
801085d8:	89 e5                	mov    %esp,%ebp
801085da:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801085dd:	8b 45 08             	mov    0x8(%ebp),%eax
801085e0:	c1 e0 10             	shl    $0x10,%eax
801085e3:	25 00 00 ff 00       	and    $0xff0000,%eax
801085e8:	89 c2                	mov    %eax,%edx
801085ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801085ed:	c1 e0 0b             	shl    $0xb,%eax
801085f0:	0f b7 c0             	movzwl %ax,%eax
801085f3:	09 c2                	or     %eax,%edx
801085f5:	8b 45 10             	mov    0x10(%ebp),%eax
801085f8:	c1 e0 08             	shl    $0x8,%eax
801085fb:	25 00 07 00 00       	and    $0x700,%eax
80108600:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108602:	8b 45 14             	mov    0x14(%ebp),%eax
80108605:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010860a:	09 d0                	or     %edx,%eax
8010860c:	0d 00 00 00 80       	or     $0x80000000,%eax
80108611:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108614:	ff 75 fc             	push   -0x4(%ebp)
80108617:	e8 05 ff ff ff       	call   80108521 <pci_write_config>
8010861c:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010861f:	ff 75 18             	push   0x18(%ebp)
80108622:	e8 0b ff ff ff       	call   80108532 <pci_write_data>
80108627:	83 c4 04             	add    $0x4,%esp
}
8010862a:	90                   	nop
8010862b:	c9                   	leave  
8010862c:	c3                   	ret    

8010862d <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010862d:	55                   	push   %ebp
8010862e:	89 e5                	mov    %esp,%ebp
80108630:	53                   	push   %ebx
80108631:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108634:	8b 45 08             	mov    0x8(%ebp),%eax
80108637:	a2 a4 9d 11 80       	mov    %al,0x80119da4
  dev.device_num = device_num;
8010863c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010863f:	a2 a5 9d 11 80       	mov    %al,0x80119da5
  dev.function_num = function_num;
80108644:	8b 45 10             	mov    0x10(%ebp),%eax
80108647:	a2 a6 9d 11 80       	mov    %al,0x80119da6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
8010864c:	ff 75 10             	push   0x10(%ebp)
8010864f:	ff 75 0c             	push   0xc(%ebp)
80108652:	ff 75 08             	push   0x8(%ebp)
80108655:	68 04 c1 10 80       	push   $0x8010c104
8010865a:	e8 95 7d ff ff       	call   801003f4 <cprintf>
8010865f:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108662:	83 ec 0c             	sub    $0xc,%esp
80108665:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108668:	50                   	push   %eax
80108669:	6a 00                	push   $0x0
8010866b:	ff 75 10             	push   0x10(%ebp)
8010866e:	ff 75 0c             	push   0xc(%ebp)
80108671:	ff 75 08             	push   0x8(%ebp)
80108674:	e8 09 ff ff ff       	call   80108582 <pci_access_config>
80108679:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
8010867c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010867f:	c1 e8 10             	shr    $0x10,%eax
80108682:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108685:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108688:	25 ff ff 00 00       	and    $0xffff,%eax
8010868d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108693:	a3 a8 9d 11 80       	mov    %eax,0x80119da8
  dev.vendor_id = vendor_id;
80108698:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010869b:	a3 ac 9d 11 80       	mov    %eax,0x80119dac
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801086a0:	83 ec 04             	sub    $0x4,%esp
801086a3:	ff 75 f0             	push   -0x10(%ebp)
801086a6:	ff 75 f4             	push   -0xc(%ebp)
801086a9:	68 38 c1 10 80       	push   $0x8010c138
801086ae:	e8 41 7d ff ff       	call   801003f4 <cprintf>
801086b3:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801086b6:	83 ec 0c             	sub    $0xc,%esp
801086b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086bc:	50                   	push   %eax
801086bd:	6a 08                	push   $0x8
801086bf:	ff 75 10             	push   0x10(%ebp)
801086c2:	ff 75 0c             	push   0xc(%ebp)
801086c5:	ff 75 08             	push   0x8(%ebp)
801086c8:	e8 b5 fe ff ff       	call   80108582 <pci_access_config>
801086cd:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801086d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086d3:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801086d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086d9:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801086dc:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801086df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086e2:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801086e5:	0f b6 c0             	movzbl %al,%eax
801086e8:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801086eb:	c1 eb 18             	shr    $0x18,%ebx
801086ee:	83 ec 0c             	sub    $0xc,%esp
801086f1:	51                   	push   %ecx
801086f2:	52                   	push   %edx
801086f3:	50                   	push   %eax
801086f4:	53                   	push   %ebx
801086f5:	68 5c c1 10 80       	push   $0x8010c15c
801086fa:	e8 f5 7c ff ff       	call   801003f4 <cprintf>
801086ff:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108702:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108705:	c1 e8 18             	shr    $0x18,%eax
80108708:	a2 b0 9d 11 80       	mov    %al,0x80119db0
  dev.sub_class = (data>>16)&0xFF;
8010870d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108710:	c1 e8 10             	shr    $0x10,%eax
80108713:	a2 b1 9d 11 80       	mov    %al,0x80119db1
  dev.interface = (data>>8)&0xFF;
80108718:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010871b:	c1 e8 08             	shr    $0x8,%eax
8010871e:	a2 b2 9d 11 80       	mov    %al,0x80119db2
  dev.revision_id = data&0xFF;
80108723:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108726:	a2 b3 9d 11 80       	mov    %al,0x80119db3
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
8010872b:	83 ec 0c             	sub    $0xc,%esp
8010872e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108731:	50                   	push   %eax
80108732:	6a 10                	push   $0x10
80108734:	ff 75 10             	push   0x10(%ebp)
80108737:	ff 75 0c             	push   0xc(%ebp)
8010873a:	ff 75 08             	push   0x8(%ebp)
8010873d:	e8 40 fe ff ff       	call   80108582 <pci_access_config>
80108742:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108745:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108748:	a3 b4 9d 11 80       	mov    %eax,0x80119db4
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
8010874d:	83 ec 0c             	sub    $0xc,%esp
80108750:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108753:	50                   	push   %eax
80108754:	6a 14                	push   $0x14
80108756:	ff 75 10             	push   0x10(%ebp)
80108759:	ff 75 0c             	push   0xc(%ebp)
8010875c:	ff 75 08             	push   0x8(%ebp)
8010875f:	e8 1e fe ff ff       	call   80108582 <pci_access_config>
80108764:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108767:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010876a:	a3 b8 9d 11 80       	mov    %eax,0x80119db8
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
8010876f:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108776:	75 5a                	jne    801087d2 <pci_init_device+0x1a5>
80108778:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
8010877f:	75 51                	jne    801087d2 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108781:	83 ec 0c             	sub    $0xc,%esp
80108784:	68 a1 c1 10 80       	push   $0x8010c1a1
80108789:	e8 66 7c ff ff       	call   801003f4 <cprintf>
8010878e:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108791:	83 ec 0c             	sub    $0xc,%esp
80108794:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108797:	50                   	push   %eax
80108798:	68 f0 00 00 00       	push   $0xf0
8010879d:	ff 75 10             	push   0x10(%ebp)
801087a0:	ff 75 0c             	push   0xc(%ebp)
801087a3:	ff 75 08             	push   0x8(%ebp)
801087a6:	e8 d7 fd ff ff       	call   80108582 <pci_access_config>
801087ab:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801087ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087b1:	83 ec 08             	sub    $0x8,%esp
801087b4:	50                   	push   %eax
801087b5:	68 bb c1 10 80       	push   $0x8010c1bb
801087ba:	e8 35 7c ff ff       	call   801003f4 <cprintf>
801087bf:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801087c2:	83 ec 0c             	sub    $0xc,%esp
801087c5:	68 a4 9d 11 80       	push   $0x80119da4
801087ca:	e8 09 00 00 00       	call   801087d8 <i8254_init>
801087cf:	83 c4 10             	add    $0x10,%esp
  }
}
801087d2:	90                   	nop
801087d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801087d6:	c9                   	leave  
801087d7:	c3                   	ret    

801087d8 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801087d8:	55                   	push   %ebp
801087d9:	89 e5                	mov    %esp,%ebp
801087db:	53                   	push   %ebx
801087dc:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801087df:	8b 45 08             	mov    0x8(%ebp),%eax
801087e2:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801087e6:	0f b6 c8             	movzbl %al,%ecx
801087e9:	8b 45 08             	mov    0x8(%ebp),%eax
801087ec:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801087f0:	0f b6 d0             	movzbl %al,%edx
801087f3:	8b 45 08             	mov    0x8(%ebp),%eax
801087f6:	0f b6 00             	movzbl (%eax),%eax
801087f9:	0f b6 c0             	movzbl %al,%eax
801087fc:	83 ec 0c             	sub    $0xc,%esp
801087ff:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108802:	53                   	push   %ebx
80108803:	6a 04                	push   $0x4
80108805:	51                   	push   %ecx
80108806:	52                   	push   %edx
80108807:	50                   	push   %eax
80108808:	e8 75 fd ff ff       	call   80108582 <pci_access_config>
8010880d:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108810:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108813:	83 c8 04             	or     $0x4,%eax
80108816:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108819:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010881c:	8b 45 08             	mov    0x8(%ebp),%eax
8010881f:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108823:	0f b6 c8             	movzbl %al,%ecx
80108826:	8b 45 08             	mov    0x8(%ebp),%eax
80108829:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010882d:	0f b6 d0             	movzbl %al,%edx
80108830:	8b 45 08             	mov    0x8(%ebp),%eax
80108833:	0f b6 00             	movzbl (%eax),%eax
80108836:	0f b6 c0             	movzbl %al,%eax
80108839:	83 ec 0c             	sub    $0xc,%esp
8010883c:	53                   	push   %ebx
8010883d:	6a 04                	push   $0x4
8010883f:	51                   	push   %ecx
80108840:	52                   	push   %edx
80108841:	50                   	push   %eax
80108842:	e8 90 fd ff ff       	call   801085d7 <pci_write_config_register>
80108847:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
8010884a:	8b 45 08             	mov    0x8(%ebp),%eax
8010884d:	8b 40 10             	mov    0x10(%eax),%eax
80108850:	05 00 00 00 40       	add    $0x40000000,%eax
80108855:	a3 bc 9d 11 80       	mov    %eax,0x80119dbc
  uint *ctrl = (uint *)base_addr;
8010885a:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
8010885f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108862:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108867:	05 d8 00 00 00       	add    $0xd8,%eax
8010886c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
8010886f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108872:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887b:	8b 00                	mov    (%eax),%eax
8010887d:	0d 00 00 00 04       	or     $0x4000000,%eax
80108882:	89 c2                	mov    %eax,%edx
80108884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108887:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010888c:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108895:	8b 00                	mov    (%eax),%eax
80108897:	83 c8 40             	or     $0x40,%eax
8010889a:	89 c2                	mov    %eax,%edx
8010889c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889f:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801088a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a4:	8b 10                	mov    (%eax),%edx
801088a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a9:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801088ab:	83 ec 0c             	sub    $0xc,%esp
801088ae:	68 d0 c1 10 80       	push   $0x8010c1d0
801088b3:	e8 3c 7b ff ff       	call   801003f4 <cprintf>
801088b8:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801088bb:	e8 c4 a3 ff ff       	call   80102c84 <kalloc>
801088c0:	a3 c8 9d 11 80       	mov    %eax,0x80119dc8
  *intr_addr = 0;
801088c5:	a1 c8 9d 11 80       	mov    0x80119dc8,%eax
801088ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
801088d0:	a1 c8 9d 11 80       	mov    0x80119dc8,%eax
801088d5:	83 ec 08             	sub    $0x8,%esp
801088d8:	50                   	push   %eax
801088d9:	68 f2 c1 10 80       	push   $0x8010c1f2
801088de:	e8 11 7b ff ff       	call   801003f4 <cprintf>
801088e3:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
801088e6:	e8 50 00 00 00       	call   8010893b <i8254_init_recv>
  i8254_init_send();
801088eb:	e8 69 03 00 00       	call   80108c59 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
801088f0:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801088f7:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
801088fa:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108901:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108904:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010890b:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010890e:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108915:	0f b6 c0             	movzbl %al,%eax
80108918:	83 ec 0c             	sub    $0xc,%esp
8010891b:	53                   	push   %ebx
8010891c:	51                   	push   %ecx
8010891d:	52                   	push   %edx
8010891e:	50                   	push   %eax
8010891f:	68 00 c2 10 80       	push   $0x8010c200
80108924:	e8 cb 7a ff ff       	call   801003f4 <cprintf>
80108929:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010892c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010892f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108935:	90                   	nop
80108936:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108939:	c9                   	leave  
8010893a:	c3                   	ret    

8010893b <i8254_init_recv>:

void i8254_init_recv(){
8010893b:	55                   	push   %ebp
8010893c:	89 e5                	mov    %esp,%ebp
8010893e:	57                   	push   %edi
8010893f:	56                   	push   %esi
80108940:	53                   	push   %ebx
80108941:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108944:	83 ec 0c             	sub    $0xc,%esp
80108947:	6a 00                	push   $0x0
80108949:	e8 e8 04 00 00       	call   80108e36 <i8254_read_eeprom>
8010894e:	83 c4 10             	add    $0x10,%esp
80108951:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108954:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108957:	a2 c0 9d 11 80       	mov    %al,0x80119dc0
  mac_addr[1] = data_l>>8;
8010895c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010895f:	c1 e8 08             	shr    $0x8,%eax
80108962:	a2 c1 9d 11 80       	mov    %al,0x80119dc1
  uint data_m = i8254_read_eeprom(0x1);
80108967:	83 ec 0c             	sub    $0xc,%esp
8010896a:	6a 01                	push   $0x1
8010896c:	e8 c5 04 00 00       	call   80108e36 <i8254_read_eeprom>
80108971:	83 c4 10             	add    $0x10,%esp
80108974:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108977:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010897a:	a2 c2 9d 11 80       	mov    %al,0x80119dc2
  mac_addr[3] = data_m>>8;
8010897f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108982:	c1 e8 08             	shr    $0x8,%eax
80108985:	a2 c3 9d 11 80       	mov    %al,0x80119dc3
  uint data_h = i8254_read_eeprom(0x2);
8010898a:	83 ec 0c             	sub    $0xc,%esp
8010898d:	6a 02                	push   $0x2
8010898f:	e8 a2 04 00 00       	call   80108e36 <i8254_read_eeprom>
80108994:	83 c4 10             	add    $0x10,%esp
80108997:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
8010899a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010899d:	a2 c4 9d 11 80       	mov    %al,0x80119dc4
  mac_addr[5] = data_h>>8;
801089a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089a5:	c1 e8 08             	shr    $0x8,%eax
801089a8:	a2 c5 9d 11 80       	mov    %al,0x80119dc5
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
801089ad:	0f b6 05 c5 9d 11 80 	movzbl 0x80119dc5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801089b4:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801089b7:	0f b6 05 c4 9d 11 80 	movzbl 0x80119dc4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801089be:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
801089c1:	0f b6 05 c3 9d 11 80 	movzbl 0x80119dc3,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801089c8:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
801089cb:	0f b6 05 c2 9d 11 80 	movzbl 0x80119dc2,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801089d2:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
801089d5:	0f b6 05 c1 9d 11 80 	movzbl 0x80119dc1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801089dc:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
801089df:	0f b6 05 c0 9d 11 80 	movzbl 0x80119dc0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801089e6:	0f b6 c0             	movzbl %al,%eax
801089e9:	83 ec 04             	sub    $0x4,%esp
801089ec:	57                   	push   %edi
801089ed:	56                   	push   %esi
801089ee:	53                   	push   %ebx
801089ef:	51                   	push   %ecx
801089f0:	52                   	push   %edx
801089f1:	50                   	push   %eax
801089f2:	68 18 c2 10 80       	push   $0x8010c218
801089f7:	e8 f8 79 ff ff       	call   801003f4 <cprintf>
801089fc:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
801089ff:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108a04:	05 00 54 00 00       	add    $0x5400,%eax
80108a09:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108a0c:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108a11:	05 04 54 00 00       	add    $0x5404,%eax
80108a16:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108a19:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a1c:	c1 e0 10             	shl    $0x10,%eax
80108a1f:	0b 45 d8             	or     -0x28(%ebp),%eax
80108a22:	89 c2                	mov    %eax,%edx
80108a24:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108a27:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108a29:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a2c:	0d 00 00 00 80       	or     $0x80000000,%eax
80108a31:	89 c2                	mov    %eax,%edx
80108a33:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108a36:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108a38:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108a3d:	05 00 52 00 00       	add    $0x5200,%eax
80108a42:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108a45:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108a4c:	eb 19                	jmp    80108a67 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108a4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108a51:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a58:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108a5b:	01 d0                	add    %edx,%eax
80108a5d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108a63:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108a67:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108a6b:	7e e1                	jle    80108a4e <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108a6d:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108a72:	05 d0 00 00 00       	add    $0xd0,%eax
80108a77:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108a7a:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108a7d:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108a83:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108a88:	05 c8 00 00 00       	add    $0xc8,%eax
80108a8d:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108a90:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108a93:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108a99:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108a9e:	05 28 28 00 00       	add    $0x2828,%eax
80108aa3:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108aa6:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108aa9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108aaf:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ab4:	05 00 01 00 00       	add    $0x100,%eax
80108ab9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108abc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108abf:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108ac5:	e8 ba a1 ff ff       	call   80102c84 <kalloc>
80108aca:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108acd:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ad2:	05 00 28 00 00       	add    $0x2800,%eax
80108ad7:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108ada:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108adf:	05 04 28 00 00       	add    $0x2804,%eax
80108ae4:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108ae7:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108aec:	05 08 28 00 00       	add    $0x2808,%eax
80108af1:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108af4:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108af9:	05 10 28 00 00       	add    $0x2810,%eax
80108afe:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108b01:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108b06:	05 18 28 00 00       	add    $0x2818,%eax
80108b0b:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108b0e:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108b11:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108b17:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108b1a:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108b1c:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108b1f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108b25:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108b28:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108b2e:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108b31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108b37:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108b3a:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108b40:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108b43:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108b46:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108b4d:	eb 73                	jmp    80108bc2 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108b4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b52:	c1 e0 04             	shl    $0x4,%eax
80108b55:	89 c2                	mov    %eax,%edx
80108b57:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b5a:	01 d0                	add    %edx,%eax
80108b5c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108b63:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b66:	c1 e0 04             	shl    $0x4,%eax
80108b69:	89 c2                	mov    %eax,%edx
80108b6b:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b6e:	01 d0                	add    %edx,%eax
80108b70:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108b76:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b79:	c1 e0 04             	shl    $0x4,%eax
80108b7c:	89 c2                	mov    %eax,%edx
80108b7e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b81:	01 d0                	add    %edx,%eax
80108b83:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108b89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b8c:	c1 e0 04             	shl    $0x4,%eax
80108b8f:	89 c2                	mov    %eax,%edx
80108b91:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b94:	01 d0                	add    %edx,%eax
80108b96:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108b9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b9d:	c1 e0 04             	shl    $0x4,%eax
80108ba0:	89 c2                	mov    %eax,%edx
80108ba2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ba5:	01 d0                	add    %edx,%eax
80108ba7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108bab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bae:	c1 e0 04             	shl    $0x4,%eax
80108bb1:	89 c2                	mov    %eax,%edx
80108bb3:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bb6:	01 d0                	add    %edx,%eax
80108bb8:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108bbe:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108bc2:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108bc9:	7e 84                	jle    80108b4f <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108bcb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108bd2:	eb 57                	jmp    80108c2b <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108bd4:	e8 ab a0 ff ff       	call   80102c84 <kalloc>
80108bd9:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108bdc:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108be0:	75 12                	jne    80108bf4 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108be2:	83 ec 0c             	sub    $0xc,%esp
80108be5:	68 38 c2 10 80       	push   $0x8010c238
80108bea:	e8 05 78 ff ff       	call   801003f4 <cprintf>
80108bef:	83 c4 10             	add    $0x10,%esp
      break;
80108bf2:	eb 3d                	jmp    80108c31 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108bf4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108bf7:	c1 e0 04             	shl    $0x4,%eax
80108bfa:	89 c2                	mov    %eax,%edx
80108bfc:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bff:	01 d0                	add    %edx,%eax
80108c01:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108c04:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108c0a:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108c0c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c0f:	83 c0 01             	add    $0x1,%eax
80108c12:	c1 e0 04             	shl    $0x4,%eax
80108c15:	89 c2                	mov    %eax,%edx
80108c17:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c1a:	01 d0                	add    %edx,%eax
80108c1c:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108c1f:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108c25:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108c27:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108c2b:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108c2f:	7e a3                	jle    80108bd4 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108c31:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108c34:	8b 00                	mov    (%eax),%eax
80108c36:	83 c8 02             	or     $0x2,%eax
80108c39:	89 c2                	mov    %eax,%edx
80108c3b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108c3e:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108c40:	83 ec 0c             	sub    $0xc,%esp
80108c43:	68 58 c2 10 80       	push   $0x8010c258
80108c48:	e8 a7 77 ff ff       	call   801003f4 <cprintf>
80108c4d:	83 c4 10             	add    $0x10,%esp
}
80108c50:	90                   	nop
80108c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108c54:	5b                   	pop    %ebx
80108c55:	5e                   	pop    %esi
80108c56:	5f                   	pop    %edi
80108c57:	5d                   	pop    %ebp
80108c58:	c3                   	ret    

80108c59 <i8254_init_send>:

void i8254_init_send(){
80108c59:	55                   	push   %ebp
80108c5a:	89 e5                	mov    %esp,%ebp
80108c5c:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108c5f:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108c64:	05 28 38 00 00       	add    $0x3828,%eax
80108c69:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108c6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c6f:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108c75:	e8 0a a0 ff ff       	call   80102c84 <kalloc>
80108c7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108c7d:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108c82:	05 00 38 00 00       	add    $0x3800,%eax
80108c87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108c8a:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108c8f:	05 04 38 00 00       	add    $0x3804,%eax
80108c94:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108c97:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108c9c:	05 08 38 00 00       	add    $0x3808,%eax
80108ca1:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108ca4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ca7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108cad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108cb0:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108cb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cb5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108cbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cbe:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108cc4:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108cc9:	05 10 38 00 00       	add    $0x3810,%eax
80108cce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108cd1:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108cd6:	05 18 38 00 00       	add    $0x3818,%eax
80108cdb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108cde:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108ce1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108ce7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108cea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108cf0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108cf3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108cf6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108cfd:	e9 82 00 00 00       	jmp    80108d84 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d05:	c1 e0 04             	shl    $0x4,%eax
80108d08:	89 c2                	mov    %eax,%edx
80108d0a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d0d:	01 d0                	add    %edx,%eax
80108d0f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d19:	c1 e0 04             	shl    $0x4,%eax
80108d1c:	89 c2                	mov    %eax,%edx
80108d1e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d21:	01 d0                	add    %edx,%eax
80108d23:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d2c:	c1 e0 04             	shl    $0x4,%eax
80108d2f:	89 c2                	mov    %eax,%edx
80108d31:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d34:	01 d0                	add    %edx,%eax
80108d36:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d3d:	c1 e0 04             	shl    $0x4,%eax
80108d40:	89 c2                	mov    %eax,%edx
80108d42:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d45:	01 d0                	add    %edx,%eax
80108d47:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d4e:	c1 e0 04             	shl    $0x4,%eax
80108d51:	89 c2                	mov    %eax,%edx
80108d53:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d56:	01 d0                	add    %edx,%eax
80108d58:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d5f:	c1 e0 04             	shl    $0x4,%eax
80108d62:	89 c2                	mov    %eax,%edx
80108d64:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d67:	01 d0                	add    %edx,%eax
80108d69:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d70:	c1 e0 04             	shl    $0x4,%eax
80108d73:	89 c2                	mov    %eax,%edx
80108d75:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d78:	01 d0                	add    %edx,%eax
80108d7a:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108d80:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108d84:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108d8b:	0f 8e 71 ff ff ff    	jle    80108d02 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108d91:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108d98:	eb 57                	jmp    80108df1 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108d9a:	e8 e5 9e ff ff       	call   80102c84 <kalloc>
80108d9f:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108da2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108da6:	75 12                	jne    80108dba <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108da8:	83 ec 0c             	sub    $0xc,%esp
80108dab:	68 38 c2 10 80       	push   $0x8010c238
80108db0:	e8 3f 76 ff ff       	call   801003f4 <cprintf>
80108db5:	83 c4 10             	add    $0x10,%esp
      break;
80108db8:	eb 3d                	jmp    80108df7 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dbd:	c1 e0 04             	shl    $0x4,%eax
80108dc0:	89 c2                	mov    %eax,%edx
80108dc2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dc5:	01 d0                	add    %edx,%eax
80108dc7:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108dca:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108dd0:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dd5:	83 c0 01             	add    $0x1,%eax
80108dd8:	c1 e0 04             	shl    $0x4,%eax
80108ddb:	89 c2                	mov    %eax,%edx
80108ddd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108de0:	01 d0                	add    %edx,%eax
80108de2:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108de5:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108deb:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108ded:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108df1:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108df5:	7e a3                	jle    80108d9a <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108df7:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108dfc:	05 00 04 00 00       	add    $0x400,%eax
80108e01:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108e04:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108e07:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108e0d:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108e12:	05 10 04 00 00       	add    $0x410,%eax
80108e17:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108e1a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108e1d:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108e23:	83 ec 0c             	sub    $0xc,%esp
80108e26:	68 78 c2 10 80       	push   $0x8010c278
80108e2b:	e8 c4 75 ff ff       	call   801003f4 <cprintf>
80108e30:	83 c4 10             	add    $0x10,%esp

}
80108e33:	90                   	nop
80108e34:	c9                   	leave  
80108e35:	c3                   	ret    

80108e36 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108e36:	55                   	push   %ebp
80108e37:	89 e5                	mov    %esp,%ebp
80108e39:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108e3c:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108e41:	83 c0 14             	add    $0x14,%eax
80108e44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108e47:	8b 45 08             	mov    0x8(%ebp),%eax
80108e4a:	c1 e0 08             	shl    $0x8,%eax
80108e4d:	0f b7 c0             	movzwl %ax,%eax
80108e50:	83 c8 01             	or     $0x1,%eax
80108e53:	89 c2                	mov    %eax,%edx
80108e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e58:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108e5a:	83 ec 0c             	sub    $0xc,%esp
80108e5d:	68 98 c2 10 80       	push   $0x8010c298
80108e62:	e8 8d 75 ff ff       	call   801003f4 <cprintf>
80108e67:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e6d:	8b 00                	mov    (%eax),%eax
80108e6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e75:	83 e0 10             	and    $0x10,%eax
80108e78:	85 c0                	test   %eax,%eax
80108e7a:	75 02                	jne    80108e7e <i8254_read_eeprom+0x48>
  while(1){
80108e7c:	eb dc                	jmp    80108e5a <i8254_read_eeprom+0x24>
      break;
80108e7e:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e82:	8b 00                	mov    (%eax),%eax
80108e84:	c1 e8 10             	shr    $0x10,%eax
}
80108e87:	c9                   	leave  
80108e88:	c3                   	ret    

80108e89 <i8254_recv>:
void i8254_recv(){
80108e89:	55                   	push   %ebp
80108e8a:	89 e5                	mov    %esp,%ebp
80108e8c:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108e8f:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108e94:	05 10 28 00 00       	add    $0x2810,%eax
80108e99:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108e9c:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ea1:	05 18 28 00 00       	add    $0x2818,%eax
80108ea6:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108ea9:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108eae:	05 00 28 00 00       	add    $0x2800,%eax
80108eb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108eb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108eb9:	8b 00                	mov    (%eax),%eax
80108ebb:	05 00 00 00 80       	add    $0x80000000,%eax
80108ec0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ec6:	8b 10                	mov    (%eax),%edx
80108ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ecb:	8b 08                	mov    (%eax),%ecx
80108ecd:	89 d0                	mov    %edx,%eax
80108ecf:	29 c8                	sub    %ecx,%eax
80108ed1:	25 ff 00 00 00       	and    $0xff,%eax
80108ed6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108ed9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108edd:	7e 37                	jle    80108f16 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108edf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ee2:	8b 00                	mov    (%eax),%eax
80108ee4:	c1 e0 04             	shl    $0x4,%eax
80108ee7:	89 c2                	mov    %eax,%edx
80108ee9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108eec:	01 d0                	add    %edx,%eax
80108eee:	8b 00                	mov    (%eax),%eax
80108ef0:	05 00 00 00 80       	add    $0x80000000,%eax
80108ef5:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108ef8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108efb:	8b 00                	mov    (%eax),%eax
80108efd:	83 c0 01             	add    $0x1,%eax
80108f00:	0f b6 d0             	movzbl %al,%edx
80108f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f06:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108f08:	83 ec 0c             	sub    $0xc,%esp
80108f0b:	ff 75 e0             	push   -0x20(%ebp)
80108f0e:	e8 15 09 00 00       	call   80109828 <eth_proc>
80108f13:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108f16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f19:	8b 10                	mov    (%eax),%edx
80108f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f1e:	8b 00                	mov    (%eax),%eax
80108f20:	39 c2                	cmp    %eax,%edx
80108f22:	75 9f                	jne    80108ec3 <i8254_recv+0x3a>
      (*rdt)--;
80108f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f27:	8b 00                	mov    (%eax),%eax
80108f29:	8d 50 ff             	lea    -0x1(%eax),%edx
80108f2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f2f:	89 10                	mov    %edx,(%eax)
  while(1){
80108f31:	eb 90                	jmp    80108ec3 <i8254_recv+0x3a>

80108f33 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108f33:	55                   	push   %ebp
80108f34:	89 e5                	mov    %esp,%ebp
80108f36:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108f39:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f3e:	05 10 38 00 00       	add    $0x3810,%eax
80108f43:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108f46:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f4b:	05 18 38 00 00       	add    $0x3818,%eax
80108f50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108f53:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f58:	05 00 38 00 00       	add    $0x3800,%eax
80108f5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108f60:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f63:	8b 00                	mov    (%eax),%eax
80108f65:	05 00 00 00 80       	add    $0x80000000,%eax
80108f6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f70:	8b 10                	mov    (%eax),%edx
80108f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f75:	8b 08                	mov    (%eax),%ecx
80108f77:	89 d0                	mov    %edx,%eax
80108f79:	29 c8                	sub    %ecx,%eax
80108f7b:	0f b6 d0             	movzbl %al,%edx
80108f7e:	b8 00 01 00 00       	mov    $0x100,%eax
80108f83:	29 d0                	sub    %edx,%eax
80108f85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108f88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f8b:	8b 00                	mov    (%eax),%eax
80108f8d:	25 ff 00 00 00       	and    $0xff,%eax
80108f92:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108f95:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108f99:	0f 8e a8 00 00 00    	jle    80109047 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80108fa2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108fa5:	89 d1                	mov    %edx,%ecx
80108fa7:	c1 e1 04             	shl    $0x4,%ecx
80108faa:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108fad:	01 ca                	add    %ecx,%edx
80108faf:	8b 12                	mov    (%edx),%edx
80108fb1:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108fb7:	83 ec 04             	sub    $0x4,%esp
80108fba:	ff 75 0c             	push   0xc(%ebp)
80108fbd:	50                   	push   %eax
80108fbe:	52                   	push   %edx
80108fbf:	e8 49 bf ff ff       	call   80104f0d <memmove>
80108fc4:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108fc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fca:	c1 e0 04             	shl    $0x4,%eax
80108fcd:	89 c2                	mov    %eax,%edx
80108fcf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fd2:	01 d0                	add    %edx,%eax
80108fd4:	8b 55 0c             	mov    0xc(%ebp),%edx
80108fd7:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108fdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fde:	c1 e0 04             	shl    $0x4,%eax
80108fe1:	89 c2                	mov    %eax,%edx
80108fe3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fe6:	01 d0                	add    %edx,%eax
80108fe8:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108fec:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fef:	c1 e0 04             	shl    $0x4,%eax
80108ff2:	89 c2                	mov    %eax,%edx
80108ff4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ff7:	01 d0                	add    %edx,%eax
80108ff9:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108ffd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109000:	c1 e0 04             	shl    $0x4,%eax
80109003:	89 c2                	mov    %eax,%edx
80109005:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109008:	01 d0                	add    %edx,%eax
8010900a:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010900e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109011:	c1 e0 04             	shl    $0x4,%eax
80109014:	89 c2                	mov    %eax,%edx
80109016:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109019:	01 d0                	add    %edx,%eax
8010901b:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109021:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109024:	c1 e0 04             	shl    $0x4,%eax
80109027:	89 c2                	mov    %eax,%edx
80109029:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010902c:	01 d0                	add    %edx,%eax
8010902e:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109032:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109035:	8b 00                	mov    (%eax),%eax
80109037:	83 c0 01             	add    $0x1,%eax
8010903a:	0f b6 d0             	movzbl %al,%edx
8010903d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109040:	89 10                	mov    %edx,(%eax)
    return len;
80109042:	8b 45 0c             	mov    0xc(%ebp),%eax
80109045:	eb 05                	jmp    8010904c <i8254_send+0x119>
  }else{
    return -1;
80109047:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010904c:	c9                   	leave  
8010904d:	c3                   	ret    

8010904e <i8254_intr>:

void i8254_intr(){
8010904e:	55                   	push   %ebp
8010904f:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109051:	a1 c8 9d 11 80       	mov    0x80119dc8,%eax
80109056:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
8010905c:	90                   	nop
8010905d:	5d                   	pop    %ebp
8010905e:	c3                   	ret    

8010905f <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
8010905f:	55                   	push   %ebp
80109060:	89 e5                	mov    %esp,%ebp
80109062:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80109065:	8b 45 08             	mov    0x8(%ebp),%eax
80109068:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
8010906b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010906e:	0f b7 00             	movzwl (%eax),%eax
80109071:	66 3d 00 01          	cmp    $0x100,%ax
80109075:	74 0a                	je     80109081 <arp_proc+0x22>
80109077:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010907c:	e9 4f 01 00 00       	jmp    801091d0 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109084:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109088:	66 83 f8 08          	cmp    $0x8,%ax
8010908c:	74 0a                	je     80109098 <arp_proc+0x39>
8010908e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109093:	e9 38 01 00 00       	jmp    801091d0 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80109098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010909b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
8010909f:	3c 06                	cmp    $0x6,%al
801090a1:	74 0a                	je     801090ad <arp_proc+0x4e>
801090a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090a8:	e9 23 01 00 00       	jmp    801091d0 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
801090ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090b0:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801090b4:	3c 04                	cmp    $0x4,%al
801090b6:	74 0a                	je     801090c2 <arp_proc+0x63>
801090b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090bd:	e9 0e 01 00 00       	jmp    801091d0 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801090c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c5:	83 c0 18             	add    $0x18,%eax
801090c8:	83 ec 04             	sub    $0x4,%esp
801090cb:	6a 04                	push   $0x4
801090cd:	50                   	push   %eax
801090ce:	68 e4 f4 10 80       	push   $0x8010f4e4
801090d3:	e8 dd bd ff ff       	call   80104eb5 <memcmp>
801090d8:	83 c4 10             	add    $0x10,%esp
801090db:	85 c0                	test   %eax,%eax
801090dd:	74 27                	je     80109106 <arp_proc+0xa7>
801090df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090e2:	83 c0 0e             	add    $0xe,%eax
801090e5:	83 ec 04             	sub    $0x4,%esp
801090e8:	6a 04                	push   $0x4
801090ea:	50                   	push   %eax
801090eb:	68 e4 f4 10 80       	push   $0x8010f4e4
801090f0:	e8 c0 bd ff ff       	call   80104eb5 <memcmp>
801090f5:	83 c4 10             	add    $0x10,%esp
801090f8:	85 c0                	test   %eax,%eax
801090fa:	74 0a                	je     80109106 <arp_proc+0xa7>
801090fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109101:	e9 ca 00 00 00       	jmp    801091d0 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109106:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109109:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010910d:	66 3d 00 01          	cmp    $0x100,%ax
80109111:	75 69                	jne    8010917c <arp_proc+0x11d>
80109113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109116:	83 c0 18             	add    $0x18,%eax
80109119:	83 ec 04             	sub    $0x4,%esp
8010911c:	6a 04                	push   $0x4
8010911e:	50                   	push   %eax
8010911f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109124:	e8 8c bd ff ff       	call   80104eb5 <memcmp>
80109129:	83 c4 10             	add    $0x10,%esp
8010912c:	85 c0                	test   %eax,%eax
8010912e:	75 4c                	jne    8010917c <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109130:	e8 4f 9b ff ff       	call   80102c84 <kalloc>
80109135:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109138:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
8010913f:	83 ec 04             	sub    $0x4,%esp
80109142:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109145:	50                   	push   %eax
80109146:	ff 75 f0             	push   -0x10(%ebp)
80109149:	ff 75 f4             	push   -0xc(%ebp)
8010914c:	e8 1f 04 00 00       	call   80109570 <arp_reply_pkt_create>
80109151:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109154:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109157:	83 ec 08             	sub    $0x8,%esp
8010915a:	50                   	push   %eax
8010915b:	ff 75 f0             	push   -0x10(%ebp)
8010915e:	e8 d0 fd ff ff       	call   80108f33 <i8254_send>
80109163:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109166:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109169:	83 ec 0c             	sub    $0xc,%esp
8010916c:	50                   	push   %eax
8010916d:	e8 78 9a ff ff       	call   80102bea <kfree>
80109172:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109175:	b8 02 00 00 00       	mov    $0x2,%eax
8010917a:	eb 54                	jmp    801091d0 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010917c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010917f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109183:	66 3d 00 02          	cmp    $0x200,%ax
80109187:	75 42                	jne    801091cb <arp_proc+0x16c>
80109189:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010918c:	83 c0 18             	add    $0x18,%eax
8010918f:	83 ec 04             	sub    $0x4,%esp
80109192:	6a 04                	push   $0x4
80109194:	50                   	push   %eax
80109195:	68 e4 f4 10 80       	push   $0x8010f4e4
8010919a:	e8 16 bd ff ff       	call   80104eb5 <memcmp>
8010919f:	83 c4 10             	add    $0x10,%esp
801091a2:	85 c0                	test   %eax,%eax
801091a4:	75 25                	jne    801091cb <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
801091a6:	83 ec 0c             	sub    $0xc,%esp
801091a9:	68 9c c2 10 80       	push   $0x8010c29c
801091ae:	e8 41 72 ff ff       	call   801003f4 <cprintf>
801091b3:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801091b6:	83 ec 0c             	sub    $0xc,%esp
801091b9:	ff 75 f4             	push   -0xc(%ebp)
801091bc:	e8 af 01 00 00       	call   80109370 <arp_table_update>
801091c1:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801091c4:	b8 01 00 00 00       	mov    $0x1,%eax
801091c9:	eb 05                	jmp    801091d0 <arp_proc+0x171>
  }else{
    return -1;
801091cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801091d0:	c9                   	leave  
801091d1:	c3                   	ret    

801091d2 <arp_scan>:

void arp_scan(){
801091d2:	55                   	push   %ebp
801091d3:	89 e5                	mov    %esp,%ebp
801091d5:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801091d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801091df:	eb 6f                	jmp    80109250 <arp_scan+0x7e>
    uint send = (uint)kalloc();
801091e1:	e8 9e 9a ff ff       	call   80102c84 <kalloc>
801091e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801091e9:	83 ec 04             	sub    $0x4,%esp
801091ec:	ff 75 f4             	push   -0xc(%ebp)
801091ef:	8d 45 e8             	lea    -0x18(%ebp),%eax
801091f2:	50                   	push   %eax
801091f3:	ff 75 ec             	push   -0x14(%ebp)
801091f6:	e8 62 00 00 00       	call   8010925d <arp_broadcast>
801091fb:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801091fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109201:	83 ec 08             	sub    $0x8,%esp
80109204:	50                   	push   %eax
80109205:	ff 75 ec             	push   -0x14(%ebp)
80109208:	e8 26 fd ff ff       	call   80108f33 <i8254_send>
8010920d:	83 c4 10             	add    $0x10,%esp
80109210:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109213:	eb 22                	jmp    80109237 <arp_scan+0x65>
      microdelay(1);
80109215:	83 ec 0c             	sub    $0xc,%esp
80109218:	6a 01                	push   $0x1
8010921a:	e8 fc 9d ff ff       	call   8010301b <microdelay>
8010921f:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109222:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109225:	83 ec 08             	sub    $0x8,%esp
80109228:	50                   	push   %eax
80109229:	ff 75 ec             	push   -0x14(%ebp)
8010922c:	e8 02 fd ff ff       	call   80108f33 <i8254_send>
80109231:	83 c4 10             	add    $0x10,%esp
80109234:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109237:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010923b:	74 d8                	je     80109215 <arp_scan+0x43>
    }
    kfree((char *)send);
8010923d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109240:	83 ec 0c             	sub    $0xc,%esp
80109243:	50                   	push   %eax
80109244:	e8 a1 99 ff ff       	call   80102bea <kfree>
80109249:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
8010924c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109250:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109257:	7e 88                	jle    801091e1 <arp_scan+0xf>
  }
}
80109259:	90                   	nop
8010925a:	90                   	nop
8010925b:	c9                   	leave  
8010925c:	c3                   	ret    

8010925d <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010925d:	55                   	push   %ebp
8010925e:	89 e5                	mov    %esp,%ebp
80109260:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109263:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109267:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
8010926b:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
8010926f:	8b 45 10             	mov    0x10(%ebp),%eax
80109272:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109275:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
8010927c:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109282:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109289:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010928f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109292:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109298:	8b 45 08             	mov    0x8(%ebp),%eax
8010929b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010929e:	8b 45 08             	mov    0x8(%ebp),%eax
801092a1:	83 c0 0e             	add    $0xe,%eax
801092a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801092a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092aa:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801092ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b1:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801092b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b8:	83 ec 04             	sub    $0x4,%esp
801092bb:	6a 06                	push   $0x6
801092bd:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801092c0:	52                   	push   %edx
801092c1:	50                   	push   %eax
801092c2:	e8 46 bc ff ff       	call   80104f0d <memmove>
801092c7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801092ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092cd:	83 c0 06             	add    $0x6,%eax
801092d0:	83 ec 04             	sub    $0x4,%esp
801092d3:	6a 06                	push   $0x6
801092d5:	68 c0 9d 11 80       	push   $0x80119dc0
801092da:	50                   	push   %eax
801092db:	e8 2d bc ff ff       	call   80104f0d <memmove>
801092e0:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801092e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092e6:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801092eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092ee:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801092f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092f7:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801092fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092fe:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109302:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109305:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010930b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010930e:	8d 50 12             	lea    0x12(%eax),%edx
80109311:	83 ec 04             	sub    $0x4,%esp
80109314:	6a 06                	push   $0x6
80109316:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109319:	50                   	push   %eax
8010931a:	52                   	push   %edx
8010931b:	e8 ed bb ff ff       	call   80104f0d <memmove>
80109320:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109323:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109326:	8d 50 18             	lea    0x18(%eax),%edx
80109329:	83 ec 04             	sub    $0x4,%esp
8010932c:	6a 04                	push   $0x4
8010932e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109331:	50                   	push   %eax
80109332:	52                   	push   %edx
80109333:	e8 d5 bb ff ff       	call   80104f0d <memmove>
80109338:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010933b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010933e:	83 c0 08             	add    $0x8,%eax
80109341:	83 ec 04             	sub    $0x4,%esp
80109344:	6a 06                	push   $0x6
80109346:	68 c0 9d 11 80       	push   $0x80119dc0
8010934b:	50                   	push   %eax
8010934c:	e8 bc bb ff ff       	call   80104f0d <memmove>
80109351:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109354:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109357:	83 c0 0e             	add    $0xe,%eax
8010935a:	83 ec 04             	sub    $0x4,%esp
8010935d:	6a 04                	push   $0x4
8010935f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109364:	50                   	push   %eax
80109365:	e8 a3 bb ff ff       	call   80104f0d <memmove>
8010936a:	83 c4 10             	add    $0x10,%esp
}
8010936d:	90                   	nop
8010936e:	c9                   	leave  
8010936f:	c3                   	ret    

80109370 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109370:	55                   	push   %ebp
80109371:	89 e5                	mov    %esp,%ebp
80109373:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109376:	8b 45 08             	mov    0x8(%ebp),%eax
80109379:	83 c0 0e             	add    $0xe,%eax
8010937c:	83 ec 0c             	sub    $0xc,%esp
8010937f:	50                   	push   %eax
80109380:	e8 bc 00 00 00       	call   80109441 <arp_table_search>
80109385:	83 c4 10             	add    $0x10,%esp
80109388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010938b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010938f:	78 2d                	js     801093be <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109391:	8b 45 08             	mov    0x8(%ebp),%eax
80109394:	8d 48 08             	lea    0x8(%eax),%ecx
80109397:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010939a:	89 d0                	mov    %edx,%eax
8010939c:	c1 e0 02             	shl    $0x2,%eax
8010939f:	01 d0                	add    %edx,%eax
801093a1:	01 c0                	add    %eax,%eax
801093a3:	01 d0                	add    %edx,%eax
801093a5:	05 e0 9d 11 80       	add    $0x80119de0,%eax
801093aa:	83 c0 04             	add    $0x4,%eax
801093ad:	83 ec 04             	sub    $0x4,%esp
801093b0:	6a 06                	push   $0x6
801093b2:	51                   	push   %ecx
801093b3:	50                   	push   %eax
801093b4:	e8 54 bb ff ff       	call   80104f0d <memmove>
801093b9:	83 c4 10             	add    $0x10,%esp
801093bc:	eb 70                	jmp    8010942e <arp_table_update+0xbe>
  }else{
    index += 1;
801093be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801093c2:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801093c5:	8b 45 08             	mov    0x8(%ebp),%eax
801093c8:	8d 48 08             	lea    0x8(%eax),%ecx
801093cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093ce:	89 d0                	mov    %edx,%eax
801093d0:	c1 e0 02             	shl    $0x2,%eax
801093d3:	01 d0                	add    %edx,%eax
801093d5:	01 c0                	add    %eax,%eax
801093d7:	01 d0                	add    %edx,%eax
801093d9:	05 e0 9d 11 80       	add    $0x80119de0,%eax
801093de:	83 c0 04             	add    $0x4,%eax
801093e1:	83 ec 04             	sub    $0x4,%esp
801093e4:	6a 06                	push   $0x6
801093e6:	51                   	push   %ecx
801093e7:	50                   	push   %eax
801093e8:	e8 20 bb ff ff       	call   80104f0d <memmove>
801093ed:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801093f0:	8b 45 08             	mov    0x8(%ebp),%eax
801093f3:	8d 48 0e             	lea    0xe(%eax),%ecx
801093f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093f9:	89 d0                	mov    %edx,%eax
801093fb:	c1 e0 02             	shl    $0x2,%eax
801093fe:	01 d0                	add    %edx,%eax
80109400:	01 c0                	add    %eax,%eax
80109402:	01 d0                	add    %edx,%eax
80109404:	05 e0 9d 11 80       	add    $0x80119de0,%eax
80109409:	83 ec 04             	sub    $0x4,%esp
8010940c:	6a 04                	push   $0x4
8010940e:	51                   	push   %ecx
8010940f:	50                   	push   %eax
80109410:	e8 f8 ba ff ff       	call   80104f0d <memmove>
80109415:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109418:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010941b:	89 d0                	mov    %edx,%eax
8010941d:	c1 e0 02             	shl    $0x2,%eax
80109420:	01 d0                	add    %edx,%eax
80109422:	01 c0                	add    %eax,%eax
80109424:	01 d0                	add    %edx,%eax
80109426:	05 ea 9d 11 80       	add    $0x80119dea,%eax
8010942b:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010942e:	83 ec 0c             	sub    $0xc,%esp
80109431:	68 e0 9d 11 80       	push   $0x80119de0
80109436:	e8 83 00 00 00       	call   801094be <print_arp_table>
8010943b:	83 c4 10             	add    $0x10,%esp
}
8010943e:	90                   	nop
8010943f:	c9                   	leave  
80109440:	c3                   	ret    

80109441 <arp_table_search>:

int arp_table_search(uchar *ip){
80109441:	55                   	push   %ebp
80109442:	89 e5                	mov    %esp,%ebp
80109444:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109447:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010944e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109455:	eb 59                	jmp    801094b0 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109457:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010945a:	89 d0                	mov    %edx,%eax
8010945c:	c1 e0 02             	shl    $0x2,%eax
8010945f:	01 d0                	add    %edx,%eax
80109461:	01 c0                	add    %eax,%eax
80109463:	01 d0                	add    %edx,%eax
80109465:	05 e0 9d 11 80       	add    $0x80119de0,%eax
8010946a:	83 ec 04             	sub    $0x4,%esp
8010946d:	6a 04                	push   $0x4
8010946f:	ff 75 08             	push   0x8(%ebp)
80109472:	50                   	push   %eax
80109473:	e8 3d ba ff ff       	call   80104eb5 <memcmp>
80109478:	83 c4 10             	add    $0x10,%esp
8010947b:	85 c0                	test   %eax,%eax
8010947d:	75 05                	jne    80109484 <arp_table_search+0x43>
      return i;
8010947f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109482:	eb 38                	jmp    801094bc <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109484:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109487:	89 d0                	mov    %edx,%eax
80109489:	c1 e0 02             	shl    $0x2,%eax
8010948c:	01 d0                	add    %edx,%eax
8010948e:	01 c0                	add    %eax,%eax
80109490:	01 d0                	add    %edx,%eax
80109492:	05 ea 9d 11 80       	add    $0x80119dea,%eax
80109497:	0f b6 00             	movzbl (%eax),%eax
8010949a:	84 c0                	test   %al,%al
8010949c:	75 0e                	jne    801094ac <arp_table_search+0x6b>
8010949e:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801094a2:	75 08                	jne    801094ac <arp_table_search+0x6b>
      empty = -i;
801094a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094a7:	f7 d8                	neg    %eax
801094a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801094ac:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801094b0:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801094b4:	7e a1                	jle    80109457 <arp_table_search+0x16>
    }
  }
  return empty-1;
801094b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b9:	83 e8 01             	sub    $0x1,%eax
}
801094bc:	c9                   	leave  
801094bd:	c3                   	ret    

801094be <print_arp_table>:

void print_arp_table(){
801094be:	55                   	push   %ebp
801094bf:	89 e5                	mov    %esp,%ebp
801094c1:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801094c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801094cb:	e9 92 00 00 00       	jmp    80109562 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
801094d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094d3:	89 d0                	mov    %edx,%eax
801094d5:	c1 e0 02             	shl    $0x2,%eax
801094d8:	01 d0                	add    %edx,%eax
801094da:	01 c0                	add    %eax,%eax
801094dc:	01 d0                	add    %edx,%eax
801094de:	05 ea 9d 11 80       	add    $0x80119dea,%eax
801094e3:	0f b6 00             	movzbl (%eax),%eax
801094e6:	84 c0                	test   %al,%al
801094e8:	74 74                	je     8010955e <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
801094ea:	83 ec 08             	sub    $0x8,%esp
801094ed:	ff 75 f4             	push   -0xc(%ebp)
801094f0:	68 af c2 10 80       	push   $0x8010c2af
801094f5:	e8 fa 6e ff ff       	call   801003f4 <cprintf>
801094fa:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801094fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109500:	89 d0                	mov    %edx,%eax
80109502:	c1 e0 02             	shl    $0x2,%eax
80109505:	01 d0                	add    %edx,%eax
80109507:	01 c0                	add    %eax,%eax
80109509:	01 d0                	add    %edx,%eax
8010950b:	05 e0 9d 11 80       	add    $0x80119de0,%eax
80109510:	83 ec 0c             	sub    $0xc,%esp
80109513:	50                   	push   %eax
80109514:	e8 54 02 00 00       	call   8010976d <print_ipv4>
80109519:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010951c:	83 ec 0c             	sub    $0xc,%esp
8010951f:	68 be c2 10 80       	push   $0x8010c2be
80109524:	e8 cb 6e ff ff       	call   801003f4 <cprintf>
80109529:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010952c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010952f:	89 d0                	mov    %edx,%eax
80109531:	c1 e0 02             	shl    $0x2,%eax
80109534:	01 d0                	add    %edx,%eax
80109536:	01 c0                	add    %eax,%eax
80109538:	01 d0                	add    %edx,%eax
8010953a:	05 e0 9d 11 80       	add    $0x80119de0,%eax
8010953f:	83 c0 04             	add    $0x4,%eax
80109542:	83 ec 0c             	sub    $0xc,%esp
80109545:	50                   	push   %eax
80109546:	e8 70 02 00 00       	call   801097bb <print_mac>
8010954b:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010954e:	83 ec 0c             	sub    $0xc,%esp
80109551:	68 c0 c2 10 80       	push   $0x8010c2c0
80109556:	e8 99 6e ff ff       	call   801003f4 <cprintf>
8010955b:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010955e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109562:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109566:	0f 8e 64 ff ff ff    	jle    801094d0 <print_arp_table+0x12>
    }
  }
}
8010956c:	90                   	nop
8010956d:	90                   	nop
8010956e:	c9                   	leave  
8010956f:	c3                   	ret    

80109570 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109570:	55                   	push   %ebp
80109571:	89 e5                	mov    %esp,%ebp
80109573:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109576:	8b 45 10             	mov    0x10(%ebp),%eax
80109579:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010957f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109582:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109585:	8b 45 0c             	mov    0xc(%ebp),%eax
80109588:	83 c0 0e             	add    $0xe,%eax
8010958b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010958e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109591:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109598:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010959c:	8b 45 08             	mov    0x8(%ebp),%eax
8010959f:	8d 50 08             	lea    0x8(%eax),%edx
801095a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a5:	83 ec 04             	sub    $0x4,%esp
801095a8:	6a 06                	push   $0x6
801095aa:	52                   	push   %edx
801095ab:	50                   	push   %eax
801095ac:	e8 5c b9 ff ff       	call   80104f0d <memmove>
801095b1:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801095b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b7:	83 c0 06             	add    $0x6,%eax
801095ba:	83 ec 04             	sub    $0x4,%esp
801095bd:	6a 06                	push   $0x6
801095bf:	68 c0 9d 11 80       	push   $0x80119dc0
801095c4:	50                   	push   %eax
801095c5:	e8 43 b9 ff ff       	call   80104f0d <memmove>
801095ca:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801095cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095d0:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801095d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095d8:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801095de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e1:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801095e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e8:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801095ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ef:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801095f5:	8b 45 08             	mov    0x8(%ebp),%eax
801095f8:	8d 50 08             	lea    0x8(%eax),%edx
801095fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095fe:	83 c0 12             	add    $0x12,%eax
80109601:	83 ec 04             	sub    $0x4,%esp
80109604:	6a 06                	push   $0x6
80109606:	52                   	push   %edx
80109607:	50                   	push   %eax
80109608:	e8 00 b9 ff ff       	call   80104f0d <memmove>
8010960d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109610:	8b 45 08             	mov    0x8(%ebp),%eax
80109613:	8d 50 0e             	lea    0xe(%eax),%edx
80109616:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109619:	83 c0 18             	add    $0x18,%eax
8010961c:	83 ec 04             	sub    $0x4,%esp
8010961f:	6a 04                	push   $0x4
80109621:	52                   	push   %edx
80109622:	50                   	push   %eax
80109623:	e8 e5 b8 ff ff       	call   80104f0d <memmove>
80109628:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010962b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010962e:	83 c0 08             	add    $0x8,%eax
80109631:	83 ec 04             	sub    $0x4,%esp
80109634:	6a 06                	push   $0x6
80109636:	68 c0 9d 11 80       	push   $0x80119dc0
8010963b:	50                   	push   %eax
8010963c:	e8 cc b8 ff ff       	call   80104f0d <memmove>
80109641:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109644:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109647:	83 c0 0e             	add    $0xe,%eax
8010964a:	83 ec 04             	sub    $0x4,%esp
8010964d:	6a 04                	push   $0x4
8010964f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109654:	50                   	push   %eax
80109655:	e8 b3 b8 ff ff       	call   80104f0d <memmove>
8010965a:	83 c4 10             	add    $0x10,%esp
}
8010965d:	90                   	nop
8010965e:	c9                   	leave  
8010965f:	c3                   	ret    

80109660 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109660:	55                   	push   %ebp
80109661:	89 e5                	mov    %esp,%ebp
80109663:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109666:	83 ec 0c             	sub    $0xc,%esp
80109669:	68 c2 c2 10 80       	push   $0x8010c2c2
8010966e:	e8 81 6d ff ff       	call   801003f4 <cprintf>
80109673:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109676:	8b 45 08             	mov    0x8(%ebp),%eax
80109679:	83 c0 0e             	add    $0xe,%eax
8010967c:	83 ec 0c             	sub    $0xc,%esp
8010967f:	50                   	push   %eax
80109680:	e8 e8 00 00 00       	call   8010976d <print_ipv4>
80109685:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109688:	83 ec 0c             	sub    $0xc,%esp
8010968b:	68 c0 c2 10 80       	push   $0x8010c2c0
80109690:	e8 5f 6d ff ff       	call   801003f4 <cprintf>
80109695:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109698:	8b 45 08             	mov    0x8(%ebp),%eax
8010969b:	83 c0 08             	add    $0x8,%eax
8010969e:	83 ec 0c             	sub    $0xc,%esp
801096a1:	50                   	push   %eax
801096a2:	e8 14 01 00 00       	call   801097bb <print_mac>
801096a7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801096aa:	83 ec 0c             	sub    $0xc,%esp
801096ad:	68 c0 c2 10 80       	push   $0x8010c2c0
801096b2:	e8 3d 6d ff ff       	call   801003f4 <cprintf>
801096b7:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801096ba:	83 ec 0c             	sub    $0xc,%esp
801096bd:	68 d9 c2 10 80       	push   $0x8010c2d9
801096c2:	e8 2d 6d ff ff       	call   801003f4 <cprintf>
801096c7:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801096ca:	8b 45 08             	mov    0x8(%ebp),%eax
801096cd:	83 c0 18             	add    $0x18,%eax
801096d0:	83 ec 0c             	sub    $0xc,%esp
801096d3:	50                   	push   %eax
801096d4:	e8 94 00 00 00       	call   8010976d <print_ipv4>
801096d9:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801096dc:	83 ec 0c             	sub    $0xc,%esp
801096df:	68 c0 c2 10 80       	push   $0x8010c2c0
801096e4:	e8 0b 6d ff ff       	call   801003f4 <cprintf>
801096e9:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801096ec:	8b 45 08             	mov    0x8(%ebp),%eax
801096ef:	83 c0 12             	add    $0x12,%eax
801096f2:	83 ec 0c             	sub    $0xc,%esp
801096f5:	50                   	push   %eax
801096f6:	e8 c0 00 00 00       	call   801097bb <print_mac>
801096fb:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801096fe:	83 ec 0c             	sub    $0xc,%esp
80109701:	68 c0 c2 10 80       	push   $0x8010c2c0
80109706:	e8 e9 6c ff ff       	call   801003f4 <cprintf>
8010970b:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010970e:	83 ec 0c             	sub    $0xc,%esp
80109711:	68 f0 c2 10 80       	push   $0x8010c2f0
80109716:	e8 d9 6c ff ff       	call   801003f4 <cprintf>
8010971b:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010971e:	8b 45 08             	mov    0x8(%ebp),%eax
80109721:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109725:	66 3d 00 01          	cmp    $0x100,%ax
80109729:	75 12                	jne    8010973d <print_arp_info+0xdd>
8010972b:	83 ec 0c             	sub    $0xc,%esp
8010972e:	68 fc c2 10 80       	push   $0x8010c2fc
80109733:	e8 bc 6c ff ff       	call   801003f4 <cprintf>
80109738:	83 c4 10             	add    $0x10,%esp
8010973b:	eb 1d                	jmp    8010975a <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010973d:	8b 45 08             	mov    0x8(%ebp),%eax
80109740:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109744:	66 3d 00 02          	cmp    $0x200,%ax
80109748:	75 10                	jne    8010975a <print_arp_info+0xfa>
    cprintf("Reply\n");
8010974a:	83 ec 0c             	sub    $0xc,%esp
8010974d:	68 05 c3 10 80       	push   $0x8010c305
80109752:	e8 9d 6c ff ff       	call   801003f4 <cprintf>
80109757:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010975a:	83 ec 0c             	sub    $0xc,%esp
8010975d:	68 c0 c2 10 80       	push   $0x8010c2c0
80109762:	e8 8d 6c ff ff       	call   801003f4 <cprintf>
80109767:	83 c4 10             	add    $0x10,%esp
}
8010976a:	90                   	nop
8010976b:	c9                   	leave  
8010976c:	c3                   	ret    

8010976d <print_ipv4>:

void print_ipv4(uchar *ip){
8010976d:	55                   	push   %ebp
8010976e:	89 e5                	mov    %esp,%ebp
80109770:	53                   	push   %ebx
80109771:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109774:	8b 45 08             	mov    0x8(%ebp),%eax
80109777:	83 c0 03             	add    $0x3,%eax
8010977a:	0f b6 00             	movzbl (%eax),%eax
8010977d:	0f b6 d8             	movzbl %al,%ebx
80109780:	8b 45 08             	mov    0x8(%ebp),%eax
80109783:	83 c0 02             	add    $0x2,%eax
80109786:	0f b6 00             	movzbl (%eax),%eax
80109789:	0f b6 c8             	movzbl %al,%ecx
8010978c:	8b 45 08             	mov    0x8(%ebp),%eax
8010978f:	83 c0 01             	add    $0x1,%eax
80109792:	0f b6 00             	movzbl (%eax),%eax
80109795:	0f b6 d0             	movzbl %al,%edx
80109798:	8b 45 08             	mov    0x8(%ebp),%eax
8010979b:	0f b6 00             	movzbl (%eax),%eax
8010979e:	0f b6 c0             	movzbl %al,%eax
801097a1:	83 ec 0c             	sub    $0xc,%esp
801097a4:	53                   	push   %ebx
801097a5:	51                   	push   %ecx
801097a6:	52                   	push   %edx
801097a7:	50                   	push   %eax
801097a8:	68 0c c3 10 80       	push   $0x8010c30c
801097ad:	e8 42 6c ff ff       	call   801003f4 <cprintf>
801097b2:	83 c4 20             	add    $0x20,%esp
}
801097b5:	90                   	nop
801097b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801097b9:	c9                   	leave  
801097ba:	c3                   	ret    

801097bb <print_mac>:

void print_mac(uchar *mac){
801097bb:	55                   	push   %ebp
801097bc:	89 e5                	mov    %esp,%ebp
801097be:	57                   	push   %edi
801097bf:	56                   	push   %esi
801097c0:	53                   	push   %ebx
801097c1:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801097c4:	8b 45 08             	mov    0x8(%ebp),%eax
801097c7:	83 c0 05             	add    $0x5,%eax
801097ca:	0f b6 00             	movzbl (%eax),%eax
801097cd:	0f b6 f8             	movzbl %al,%edi
801097d0:	8b 45 08             	mov    0x8(%ebp),%eax
801097d3:	83 c0 04             	add    $0x4,%eax
801097d6:	0f b6 00             	movzbl (%eax),%eax
801097d9:	0f b6 f0             	movzbl %al,%esi
801097dc:	8b 45 08             	mov    0x8(%ebp),%eax
801097df:	83 c0 03             	add    $0x3,%eax
801097e2:	0f b6 00             	movzbl (%eax),%eax
801097e5:	0f b6 d8             	movzbl %al,%ebx
801097e8:	8b 45 08             	mov    0x8(%ebp),%eax
801097eb:	83 c0 02             	add    $0x2,%eax
801097ee:	0f b6 00             	movzbl (%eax),%eax
801097f1:	0f b6 c8             	movzbl %al,%ecx
801097f4:	8b 45 08             	mov    0x8(%ebp),%eax
801097f7:	83 c0 01             	add    $0x1,%eax
801097fa:	0f b6 00             	movzbl (%eax),%eax
801097fd:	0f b6 d0             	movzbl %al,%edx
80109800:	8b 45 08             	mov    0x8(%ebp),%eax
80109803:	0f b6 00             	movzbl (%eax),%eax
80109806:	0f b6 c0             	movzbl %al,%eax
80109809:	83 ec 04             	sub    $0x4,%esp
8010980c:	57                   	push   %edi
8010980d:	56                   	push   %esi
8010980e:	53                   	push   %ebx
8010980f:	51                   	push   %ecx
80109810:	52                   	push   %edx
80109811:	50                   	push   %eax
80109812:	68 24 c3 10 80       	push   $0x8010c324
80109817:	e8 d8 6b ff ff       	call   801003f4 <cprintf>
8010981c:	83 c4 20             	add    $0x20,%esp
}
8010981f:	90                   	nop
80109820:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109823:	5b                   	pop    %ebx
80109824:	5e                   	pop    %esi
80109825:	5f                   	pop    %edi
80109826:	5d                   	pop    %ebp
80109827:	c3                   	ret    

80109828 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109828:	55                   	push   %ebp
80109829:	89 e5                	mov    %esp,%ebp
8010982b:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010982e:	8b 45 08             	mov    0x8(%ebp),%eax
80109831:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109834:	8b 45 08             	mov    0x8(%ebp),%eax
80109837:	83 c0 0e             	add    $0xe,%eax
8010983a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010983d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109840:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109844:	3c 08                	cmp    $0x8,%al
80109846:	75 1b                	jne    80109863 <eth_proc+0x3b>
80109848:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010984b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010984f:	3c 06                	cmp    $0x6,%al
80109851:	75 10                	jne    80109863 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109853:	83 ec 0c             	sub    $0xc,%esp
80109856:	ff 75 f0             	push   -0x10(%ebp)
80109859:	e8 01 f8 ff ff       	call   8010905f <arp_proc>
8010985e:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109861:	eb 24                	jmp    80109887 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109866:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010986a:	3c 08                	cmp    $0x8,%al
8010986c:	75 19                	jne    80109887 <eth_proc+0x5f>
8010986e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109871:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109875:	84 c0                	test   %al,%al
80109877:	75 0e                	jne    80109887 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109879:	83 ec 0c             	sub    $0xc,%esp
8010987c:	ff 75 08             	push   0x8(%ebp)
8010987f:	e8 a3 00 00 00       	call   80109927 <ipv4_proc>
80109884:	83 c4 10             	add    $0x10,%esp
}
80109887:	90                   	nop
80109888:	c9                   	leave  
80109889:	c3                   	ret    

8010988a <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010988a:	55                   	push   %ebp
8010988b:	89 e5                	mov    %esp,%ebp
8010988d:	83 ec 04             	sub    $0x4,%esp
80109890:	8b 45 08             	mov    0x8(%ebp),%eax
80109893:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109897:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010989b:	c1 e0 08             	shl    $0x8,%eax
8010989e:	89 c2                	mov    %eax,%edx
801098a0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801098a4:	66 c1 e8 08          	shr    $0x8,%ax
801098a8:	01 d0                	add    %edx,%eax
}
801098aa:	c9                   	leave  
801098ab:	c3                   	ret    

801098ac <H2N_ushort>:

ushort H2N_ushort(ushort value){
801098ac:	55                   	push   %ebp
801098ad:	89 e5                	mov    %esp,%ebp
801098af:	83 ec 04             	sub    $0x4,%esp
801098b2:	8b 45 08             	mov    0x8(%ebp),%eax
801098b5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801098b9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801098bd:	c1 e0 08             	shl    $0x8,%eax
801098c0:	89 c2                	mov    %eax,%edx
801098c2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801098c6:	66 c1 e8 08          	shr    $0x8,%ax
801098ca:	01 d0                	add    %edx,%eax
}
801098cc:	c9                   	leave  
801098cd:	c3                   	ret    

801098ce <H2N_uint>:

uint H2N_uint(uint value){
801098ce:	55                   	push   %ebp
801098cf:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
801098d1:	8b 45 08             	mov    0x8(%ebp),%eax
801098d4:	c1 e0 18             	shl    $0x18,%eax
801098d7:	25 00 00 00 0f       	and    $0xf000000,%eax
801098dc:	89 c2                	mov    %eax,%edx
801098de:	8b 45 08             	mov    0x8(%ebp),%eax
801098e1:	c1 e0 08             	shl    $0x8,%eax
801098e4:	25 00 f0 00 00       	and    $0xf000,%eax
801098e9:	09 c2                	or     %eax,%edx
801098eb:	8b 45 08             	mov    0x8(%ebp),%eax
801098ee:	c1 e8 08             	shr    $0x8,%eax
801098f1:	83 e0 0f             	and    $0xf,%eax
801098f4:	01 d0                	add    %edx,%eax
}
801098f6:	5d                   	pop    %ebp
801098f7:	c3                   	ret    

801098f8 <N2H_uint>:

uint N2H_uint(uint value){
801098f8:	55                   	push   %ebp
801098f9:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801098fb:	8b 45 08             	mov    0x8(%ebp),%eax
801098fe:	c1 e0 18             	shl    $0x18,%eax
80109901:	89 c2                	mov    %eax,%edx
80109903:	8b 45 08             	mov    0x8(%ebp),%eax
80109906:	c1 e0 08             	shl    $0x8,%eax
80109909:	25 00 00 ff 00       	and    $0xff0000,%eax
8010990e:	01 c2                	add    %eax,%edx
80109910:	8b 45 08             	mov    0x8(%ebp),%eax
80109913:	c1 e8 08             	shr    $0x8,%eax
80109916:	25 00 ff 00 00       	and    $0xff00,%eax
8010991b:	01 c2                	add    %eax,%edx
8010991d:	8b 45 08             	mov    0x8(%ebp),%eax
80109920:	c1 e8 18             	shr    $0x18,%eax
80109923:	01 d0                	add    %edx,%eax
}
80109925:	5d                   	pop    %ebp
80109926:	c3                   	ret    

80109927 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109927:	55                   	push   %ebp
80109928:	89 e5                	mov    %esp,%ebp
8010992a:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010992d:	8b 45 08             	mov    0x8(%ebp),%eax
80109930:	83 c0 0e             	add    $0xe,%eax
80109933:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109939:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010993d:	0f b7 d0             	movzwl %ax,%edx
80109940:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109945:	39 c2                	cmp    %eax,%edx
80109947:	74 60                	je     801099a9 <ipv4_proc+0x82>
80109949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010994c:	83 c0 0c             	add    $0xc,%eax
8010994f:	83 ec 04             	sub    $0x4,%esp
80109952:	6a 04                	push   $0x4
80109954:	50                   	push   %eax
80109955:	68 e4 f4 10 80       	push   $0x8010f4e4
8010995a:	e8 56 b5 ff ff       	call   80104eb5 <memcmp>
8010995f:	83 c4 10             	add    $0x10,%esp
80109962:	85 c0                	test   %eax,%eax
80109964:	74 43                	je     801099a9 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109969:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010996d:	0f b7 c0             	movzwl %ax,%eax
80109970:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109978:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010997c:	3c 01                	cmp    $0x1,%al
8010997e:	75 10                	jne    80109990 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109980:	83 ec 0c             	sub    $0xc,%esp
80109983:	ff 75 08             	push   0x8(%ebp)
80109986:	e8 a3 00 00 00       	call   80109a2e <icmp_proc>
8010998b:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010998e:	eb 19                	jmp    801099a9 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109993:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109997:	3c 06                	cmp    $0x6,%al
80109999:	75 0e                	jne    801099a9 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
8010999b:	83 ec 0c             	sub    $0xc,%esp
8010999e:	ff 75 08             	push   0x8(%ebp)
801099a1:	e8 b3 03 00 00       	call   80109d59 <tcp_proc>
801099a6:	83 c4 10             	add    $0x10,%esp
}
801099a9:	90                   	nop
801099aa:	c9                   	leave  
801099ab:	c3                   	ret    

801099ac <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
801099ac:	55                   	push   %ebp
801099ad:	89 e5                	mov    %esp,%ebp
801099af:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
801099b2:	8b 45 08             	mov    0x8(%ebp),%eax
801099b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
801099b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099bb:	0f b6 00             	movzbl (%eax),%eax
801099be:	83 e0 0f             	and    $0xf,%eax
801099c1:	01 c0                	add    %eax,%eax
801099c3:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
801099c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
801099cd:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801099d4:	eb 48                	jmp    80109a1e <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
801099d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801099d9:	01 c0                	add    %eax,%eax
801099db:	89 c2                	mov    %eax,%edx
801099dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099e0:	01 d0                	add    %edx,%eax
801099e2:	0f b6 00             	movzbl (%eax),%eax
801099e5:	0f b6 c0             	movzbl %al,%eax
801099e8:	c1 e0 08             	shl    $0x8,%eax
801099eb:	89 c2                	mov    %eax,%edx
801099ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
801099f0:	01 c0                	add    %eax,%eax
801099f2:	8d 48 01             	lea    0x1(%eax),%ecx
801099f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099f8:	01 c8                	add    %ecx,%eax
801099fa:	0f b6 00             	movzbl (%eax),%eax
801099fd:	0f b6 c0             	movzbl %al,%eax
80109a00:	01 d0                	add    %edx,%eax
80109a02:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109a05:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109a0c:	76 0c                	jbe    80109a1a <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109a0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a11:	0f b7 c0             	movzwl %ax,%eax
80109a14:	83 c0 01             	add    $0x1,%eax
80109a17:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109a1a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109a1e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109a22:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109a25:	7c af                	jl     801099d6 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109a27:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a2a:	f7 d0                	not    %eax
}
80109a2c:	c9                   	leave  
80109a2d:	c3                   	ret    

80109a2e <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109a2e:	55                   	push   %ebp
80109a2f:	89 e5                	mov    %esp,%ebp
80109a31:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109a34:	8b 45 08             	mov    0x8(%ebp),%eax
80109a37:	83 c0 0e             	add    $0xe,%eax
80109a3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a40:	0f b6 00             	movzbl (%eax),%eax
80109a43:	0f b6 c0             	movzbl %al,%eax
80109a46:	83 e0 0f             	and    $0xf,%eax
80109a49:	c1 e0 02             	shl    $0x2,%eax
80109a4c:	89 c2                	mov    %eax,%edx
80109a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a51:	01 d0                	add    %edx,%eax
80109a53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a59:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109a5d:	84 c0                	test   %al,%al
80109a5f:	75 4f                	jne    80109ab0 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a64:	0f b6 00             	movzbl (%eax),%eax
80109a67:	3c 08                	cmp    $0x8,%al
80109a69:	75 45                	jne    80109ab0 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109a6b:	e8 14 92 ff ff       	call   80102c84 <kalloc>
80109a70:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109a73:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109a7a:	83 ec 04             	sub    $0x4,%esp
80109a7d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109a80:	50                   	push   %eax
80109a81:	ff 75 ec             	push   -0x14(%ebp)
80109a84:	ff 75 08             	push   0x8(%ebp)
80109a87:	e8 78 00 00 00       	call   80109b04 <icmp_reply_pkt_create>
80109a8c:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109a8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a92:	83 ec 08             	sub    $0x8,%esp
80109a95:	50                   	push   %eax
80109a96:	ff 75 ec             	push   -0x14(%ebp)
80109a99:	e8 95 f4 ff ff       	call   80108f33 <i8254_send>
80109a9e:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109aa1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109aa4:	83 ec 0c             	sub    $0xc,%esp
80109aa7:	50                   	push   %eax
80109aa8:	e8 3d 91 ff ff       	call   80102bea <kfree>
80109aad:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109ab0:	90                   	nop
80109ab1:	c9                   	leave  
80109ab2:	c3                   	ret    

80109ab3 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109ab3:	55                   	push   %ebp
80109ab4:	89 e5                	mov    %esp,%ebp
80109ab6:	53                   	push   %ebx
80109ab7:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109aba:	8b 45 08             	mov    0x8(%ebp),%eax
80109abd:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109ac1:	0f b7 c0             	movzwl %ax,%eax
80109ac4:	83 ec 0c             	sub    $0xc,%esp
80109ac7:	50                   	push   %eax
80109ac8:	e8 bd fd ff ff       	call   8010988a <N2H_ushort>
80109acd:	83 c4 10             	add    $0x10,%esp
80109ad0:	0f b7 d8             	movzwl %ax,%ebx
80109ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109ada:	0f b7 c0             	movzwl %ax,%eax
80109add:	83 ec 0c             	sub    $0xc,%esp
80109ae0:	50                   	push   %eax
80109ae1:	e8 a4 fd ff ff       	call   8010988a <N2H_ushort>
80109ae6:	83 c4 10             	add    $0x10,%esp
80109ae9:	0f b7 c0             	movzwl %ax,%eax
80109aec:	83 ec 04             	sub    $0x4,%esp
80109aef:	53                   	push   %ebx
80109af0:	50                   	push   %eax
80109af1:	68 43 c3 10 80       	push   $0x8010c343
80109af6:	e8 f9 68 ff ff       	call   801003f4 <cprintf>
80109afb:	83 c4 10             	add    $0x10,%esp
}
80109afe:	90                   	nop
80109aff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109b02:	c9                   	leave  
80109b03:	c3                   	ret    

80109b04 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109b04:	55                   	push   %ebp
80109b05:	89 e5                	mov    %esp,%ebp
80109b07:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109b10:	8b 45 08             	mov    0x8(%ebp),%eax
80109b13:	83 c0 0e             	add    $0xe,%eax
80109b16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b1c:	0f b6 00             	movzbl (%eax),%eax
80109b1f:	0f b6 c0             	movzbl %al,%eax
80109b22:	83 e0 0f             	and    $0xf,%eax
80109b25:	c1 e0 02             	shl    $0x2,%eax
80109b28:	89 c2                	mov    %eax,%edx
80109b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b2d:	01 d0                	add    %edx,%eax
80109b2f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109b32:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b35:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109b38:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b3b:	83 c0 0e             	add    $0xe,%eax
80109b3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109b41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b44:	83 c0 14             	add    $0x14,%eax
80109b47:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109b4a:	8b 45 10             	mov    0x10(%ebp),%eax
80109b4d:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b56:	8d 50 06             	lea    0x6(%eax),%edx
80109b59:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b5c:	83 ec 04             	sub    $0x4,%esp
80109b5f:	6a 06                	push   $0x6
80109b61:	52                   	push   %edx
80109b62:	50                   	push   %eax
80109b63:	e8 a5 b3 ff ff       	call   80104f0d <memmove>
80109b68:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109b6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b6e:	83 c0 06             	add    $0x6,%eax
80109b71:	83 ec 04             	sub    $0x4,%esp
80109b74:	6a 06                	push   $0x6
80109b76:	68 c0 9d 11 80       	push   $0x80119dc0
80109b7b:	50                   	push   %eax
80109b7c:	e8 8c b3 ff ff       	call   80104f0d <memmove>
80109b81:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109b84:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b87:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109b8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b8e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109b92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b95:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109b98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b9b:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109b9f:	83 ec 0c             	sub    $0xc,%esp
80109ba2:	6a 54                	push   $0x54
80109ba4:	e8 03 fd ff ff       	call   801098ac <H2N_ushort>
80109ba9:	83 c4 10             	add    $0x10,%esp
80109bac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109baf:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109bb3:	0f b7 15 a0 a0 11 80 	movzwl 0x8011a0a0,%edx
80109bba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bbd:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109bc1:	0f b7 05 a0 a0 11 80 	movzwl 0x8011a0a0,%eax
80109bc8:	83 c0 01             	add    $0x1,%eax
80109bcb:	66 a3 a0 a0 11 80    	mov    %ax,0x8011a0a0
  ipv4_send->fragment = H2N_ushort(0x4000);
80109bd1:	83 ec 0c             	sub    $0xc,%esp
80109bd4:	68 00 40 00 00       	push   $0x4000
80109bd9:	e8 ce fc ff ff       	call   801098ac <H2N_ushort>
80109bde:	83 c4 10             	add    $0x10,%esp
80109be1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109be4:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109be8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109beb:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109bef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bf2:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109bf6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bf9:	83 c0 0c             	add    $0xc,%eax
80109bfc:	83 ec 04             	sub    $0x4,%esp
80109bff:	6a 04                	push   $0x4
80109c01:	68 e4 f4 10 80       	push   $0x8010f4e4
80109c06:	50                   	push   %eax
80109c07:	e8 01 b3 ff ff       	call   80104f0d <memmove>
80109c0c:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109c0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c12:	8d 50 0c             	lea    0xc(%eax),%edx
80109c15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c18:	83 c0 10             	add    $0x10,%eax
80109c1b:	83 ec 04             	sub    $0x4,%esp
80109c1e:	6a 04                	push   $0x4
80109c20:	52                   	push   %edx
80109c21:	50                   	push   %eax
80109c22:	e8 e6 b2 ff ff       	call   80104f0d <memmove>
80109c27:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109c2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c2d:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109c33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c36:	83 ec 0c             	sub    $0xc,%esp
80109c39:	50                   	push   %eax
80109c3a:	e8 6d fd ff ff       	call   801099ac <ipv4_chksum>
80109c3f:	83 c4 10             	add    $0x10,%esp
80109c42:	0f b7 c0             	movzwl %ax,%eax
80109c45:	83 ec 0c             	sub    $0xc,%esp
80109c48:	50                   	push   %eax
80109c49:	e8 5e fc ff ff       	call   801098ac <H2N_ushort>
80109c4e:	83 c4 10             	add    $0x10,%esp
80109c51:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c54:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109c58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c5b:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109c5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c61:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109c65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c68:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109c6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c6f:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109c73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c76:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109c7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c7d:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109c81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c84:	8d 50 08             	lea    0x8(%eax),%edx
80109c87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c8a:	83 c0 08             	add    $0x8,%eax
80109c8d:	83 ec 04             	sub    $0x4,%esp
80109c90:	6a 08                	push   $0x8
80109c92:	52                   	push   %edx
80109c93:	50                   	push   %eax
80109c94:	e8 74 b2 ff ff       	call   80104f0d <memmove>
80109c99:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109c9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c9f:	8d 50 10             	lea    0x10(%eax),%edx
80109ca2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ca5:	83 c0 10             	add    $0x10,%eax
80109ca8:	83 ec 04             	sub    $0x4,%esp
80109cab:	6a 30                	push   $0x30
80109cad:	52                   	push   %edx
80109cae:	50                   	push   %eax
80109caf:	e8 59 b2 ff ff       	call   80104f0d <memmove>
80109cb4:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109cb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cba:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109cc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cc3:	83 ec 0c             	sub    $0xc,%esp
80109cc6:	50                   	push   %eax
80109cc7:	e8 1c 00 00 00       	call   80109ce8 <icmp_chksum>
80109ccc:	83 c4 10             	add    $0x10,%esp
80109ccf:	0f b7 c0             	movzwl %ax,%eax
80109cd2:	83 ec 0c             	sub    $0xc,%esp
80109cd5:	50                   	push   %eax
80109cd6:	e8 d1 fb ff ff       	call   801098ac <H2N_ushort>
80109cdb:	83 c4 10             	add    $0x10,%esp
80109cde:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109ce1:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109ce5:	90                   	nop
80109ce6:	c9                   	leave  
80109ce7:	c3                   	ret    

80109ce8 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109ce8:	55                   	push   %ebp
80109ce9:	89 e5                	mov    %esp,%ebp
80109ceb:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109cee:	8b 45 08             	mov    0x8(%ebp),%eax
80109cf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109cf4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109cfb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109d02:	eb 48                	jmp    80109d4c <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d04:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d07:	01 c0                	add    %eax,%eax
80109d09:	89 c2                	mov    %eax,%edx
80109d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d0e:	01 d0                	add    %edx,%eax
80109d10:	0f b6 00             	movzbl (%eax),%eax
80109d13:	0f b6 c0             	movzbl %al,%eax
80109d16:	c1 e0 08             	shl    $0x8,%eax
80109d19:	89 c2                	mov    %eax,%edx
80109d1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d1e:	01 c0                	add    %eax,%eax
80109d20:	8d 48 01             	lea    0x1(%eax),%ecx
80109d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d26:	01 c8                	add    %ecx,%eax
80109d28:	0f b6 00             	movzbl (%eax),%eax
80109d2b:	0f b6 c0             	movzbl %al,%eax
80109d2e:	01 d0                	add    %edx,%eax
80109d30:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109d33:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109d3a:	76 0c                	jbe    80109d48 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109d3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d3f:	0f b7 c0             	movzwl %ax,%eax
80109d42:	83 c0 01             	add    $0x1,%eax
80109d45:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d48:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109d4c:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109d50:	7e b2                	jle    80109d04 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109d52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d55:	f7 d0                	not    %eax
}
80109d57:	c9                   	leave  
80109d58:	c3                   	ret    

80109d59 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109d59:	55                   	push   %ebp
80109d5a:	89 e5                	mov    %esp,%ebp
80109d5c:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80109d62:	83 c0 0e             	add    $0xe,%eax
80109d65:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d6b:	0f b6 00             	movzbl (%eax),%eax
80109d6e:	0f b6 c0             	movzbl %al,%eax
80109d71:	83 e0 0f             	and    $0xf,%eax
80109d74:	c1 e0 02             	shl    $0x2,%eax
80109d77:	89 c2                	mov    %eax,%edx
80109d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d7c:	01 d0                	add    %edx,%eax
80109d7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d84:	83 c0 14             	add    $0x14,%eax
80109d87:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109d8a:	e8 f5 8e ff ff       	call   80102c84 <kalloc>
80109d8f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109d92:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d9c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109da0:	0f b6 c0             	movzbl %al,%eax
80109da3:	83 e0 02             	and    $0x2,%eax
80109da6:	85 c0                	test   %eax,%eax
80109da8:	74 3d                	je     80109de7 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109daa:	83 ec 0c             	sub    $0xc,%esp
80109dad:	6a 00                	push   $0x0
80109daf:	6a 12                	push   $0x12
80109db1:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109db4:	50                   	push   %eax
80109db5:	ff 75 e8             	push   -0x18(%ebp)
80109db8:	ff 75 08             	push   0x8(%ebp)
80109dbb:	e8 a2 01 00 00       	call   80109f62 <tcp_pkt_create>
80109dc0:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109dc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109dc6:	83 ec 08             	sub    $0x8,%esp
80109dc9:	50                   	push   %eax
80109dca:	ff 75 e8             	push   -0x18(%ebp)
80109dcd:	e8 61 f1 ff ff       	call   80108f33 <i8254_send>
80109dd2:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109dd5:	a1 a4 a0 11 80       	mov    0x8011a0a4,%eax
80109dda:	83 c0 01             	add    $0x1,%eax
80109ddd:	a3 a4 a0 11 80       	mov    %eax,0x8011a0a4
80109de2:	e9 69 01 00 00       	jmp    80109f50 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dea:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109dee:	3c 18                	cmp    $0x18,%al
80109df0:	0f 85 10 01 00 00    	jne    80109f06 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109df6:	83 ec 04             	sub    $0x4,%esp
80109df9:	6a 03                	push   $0x3
80109dfb:	68 5e c3 10 80       	push   $0x8010c35e
80109e00:	ff 75 ec             	push   -0x14(%ebp)
80109e03:	e8 ad b0 ff ff       	call   80104eb5 <memcmp>
80109e08:	83 c4 10             	add    $0x10,%esp
80109e0b:	85 c0                	test   %eax,%eax
80109e0d:	74 74                	je     80109e83 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109e0f:	83 ec 0c             	sub    $0xc,%esp
80109e12:	68 62 c3 10 80       	push   $0x8010c362
80109e17:	e8 d8 65 ff ff       	call   801003f4 <cprintf>
80109e1c:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109e1f:	83 ec 0c             	sub    $0xc,%esp
80109e22:	6a 00                	push   $0x0
80109e24:	6a 10                	push   $0x10
80109e26:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e29:	50                   	push   %eax
80109e2a:	ff 75 e8             	push   -0x18(%ebp)
80109e2d:	ff 75 08             	push   0x8(%ebp)
80109e30:	e8 2d 01 00 00       	call   80109f62 <tcp_pkt_create>
80109e35:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109e38:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e3b:	83 ec 08             	sub    $0x8,%esp
80109e3e:	50                   	push   %eax
80109e3f:	ff 75 e8             	push   -0x18(%ebp)
80109e42:	e8 ec f0 ff ff       	call   80108f33 <i8254_send>
80109e47:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109e4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e4d:	83 c0 36             	add    $0x36,%eax
80109e50:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109e53:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109e56:	50                   	push   %eax
80109e57:	ff 75 e0             	push   -0x20(%ebp)
80109e5a:	6a 00                	push   $0x0
80109e5c:	6a 00                	push   $0x0
80109e5e:	e8 5a 04 00 00       	call   8010a2bd <http_proc>
80109e63:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109e66:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109e69:	83 ec 0c             	sub    $0xc,%esp
80109e6c:	50                   	push   %eax
80109e6d:	6a 18                	push   $0x18
80109e6f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e72:	50                   	push   %eax
80109e73:	ff 75 e8             	push   -0x18(%ebp)
80109e76:	ff 75 08             	push   0x8(%ebp)
80109e79:	e8 e4 00 00 00       	call   80109f62 <tcp_pkt_create>
80109e7e:	83 c4 20             	add    $0x20,%esp
80109e81:	eb 62                	jmp    80109ee5 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109e83:	83 ec 0c             	sub    $0xc,%esp
80109e86:	6a 00                	push   $0x0
80109e88:	6a 10                	push   $0x10
80109e8a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e8d:	50                   	push   %eax
80109e8e:	ff 75 e8             	push   -0x18(%ebp)
80109e91:	ff 75 08             	push   0x8(%ebp)
80109e94:	e8 c9 00 00 00       	call   80109f62 <tcp_pkt_create>
80109e99:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109e9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e9f:	83 ec 08             	sub    $0x8,%esp
80109ea2:	50                   	push   %eax
80109ea3:	ff 75 e8             	push   -0x18(%ebp)
80109ea6:	e8 88 f0 ff ff       	call   80108f33 <i8254_send>
80109eab:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109eae:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109eb1:	83 c0 36             	add    $0x36,%eax
80109eb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109eb7:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109eba:	50                   	push   %eax
80109ebb:	ff 75 e4             	push   -0x1c(%ebp)
80109ebe:	6a 00                	push   $0x0
80109ec0:	6a 00                	push   $0x0
80109ec2:	e8 f6 03 00 00       	call   8010a2bd <http_proc>
80109ec7:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109eca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109ecd:	83 ec 0c             	sub    $0xc,%esp
80109ed0:	50                   	push   %eax
80109ed1:	6a 18                	push   $0x18
80109ed3:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ed6:	50                   	push   %eax
80109ed7:	ff 75 e8             	push   -0x18(%ebp)
80109eda:	ff 75 08             	push   0x8(%ebp)
80109edd:	e8 80 00 00 00       	call   80109f62 <tcp_pkt_create>
80109ee2:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109ee5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ee8:	83 ec 08             	sub    $0x8,%esp
80109eeb:	50                   	push   %eax
80109eec:	ff 75 e8             	push   -0x18(%ebp)
80109eef:	e8 3f f0 ff ff       	call   80108f33 <i8254_send>
80109ef4:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109ef7:	a1 a4 a0 11 80       	mov    0x8011a0a4,%eax
80109efc:	83 c0 01             	add    $0x1,%eax
80109eff:	a3 a4 a0 11 80       	mov    %eax,0x8011a0a4
80109f04:	eb 4a                	jmp    80109f50 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109f06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f09:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f0d:	3c 10                	cmp    $0x10,%al
80109f0f:	75 3f                	jne    80109f50 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109f11:	a1 a8 a0 11 80       	mov    0x8011a0a8,%eax
80109f16:	83 f8 01             	cmp    $0x1,%eax
80109f19:	75 35                	jne    80109f50 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109f1b:	83 ec 0c             	sub    $0xc,%esp
80109f1e:	6a 00                	push   $0x0
80109f20:	6a 01                	push   $0x1
80109f22:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f25:	50                   	push   %eax
80109f26:	ff 75 e8             	push   -0x18(%ebp)
80109f29:	ff 75 08             	push   0x8(%ebp)
80109f2c:	e8 31 00 00 00       	call   80109f62 <tcp_pkt_create>
80109f31:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109f34:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f37:	83 ec 08             	sub    $0x8,%esp
80109f3a:	50                   	push   %eax
80109f3b:	ff 75 e8             	push   -0x18(%ebp)
80109f3e:	e8 f0 ef ff ff       	call   80108f33 <i8254_send>
80109f43:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109f46:	c7 05 a8 a0 11 80 00 	movl   $0x0,0x8011a0a8
80109f4d:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109f50:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f53:	83 ec 0c             	sub    $0xc,%esp
80109f56:	50                   	push   %eax
80109f57:	e8 8e 8c ff ff       	call   80102bea <kfree>
80109f5c:	83 c4 10             	add    $0x10,%esp
}
80109f5f:	90                   	nop
80109f60:	c9                   	leave  
80109f61:	c3                   	ret    

80109f62 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109f62:	55                   	push   %ebp
80109f63:	89 e5                	mov    %esp,%ebp
80109f65:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109f68:	8b 45 08             	mov    0x8(%ebp),%eax
80109f6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109f6e:	8b 45 08             	mov    0x8(%ebp),%eax
80109f71:	83 c0 0e             	add    $0xe,%eax
80109f74:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f7a:	0f b6 00             	movzbl (%eax),%eax
80109f7d:	0f b6 c0             	movzbl %al,%eax
80109f80:	83 e0 0f             	and    $0xf,%eax
80109f83:	c1 e0 02             	shl    $0x2,%eax
80109f86:	89 c2                	mov    %eax,%edx
80109f88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f8b:	01 d0                	add    %edx,%eax
80109f8d:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109f90:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f93:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109f96:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f99:	83 c0 0e             	add    $0xe,%eax
80109f9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109f9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fa2:	83 c0 14             	add    $0x14,%eax
80109fa5:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109fa8:	8b 45 18             	mov    0x18(%ebp),%eax
80109fab:	8d 50 36             	lea    0x36(%eax),%edx
80109fae:	8b 45 10             	mov    0x10(%ebp),%eax
80109fb1:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fb6:	8d 50 06             	lea    0x6(%eax),%edx
80109fb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fbc:	83 ec 04             	sub    $0x4,%esp
80109fbf:	6a 06                	push   $0x6
80109fc1:	52                   	push   %edx
80109fc2:	50                   	push   %eax
80109fc3:	e8 45 af ff ff       	call   80104f0d <memmove>
80109fc8:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109fcb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fce:	83 c0 06             	add    $0x6,%eax
80109fd1:	83 ec 04             	sub    $0x4,%esp
80109fd4:	6a 06                	push   $0x6
80109fd6:	68 c0 9d 11 80       	push   $0x80119dc0
80109fdb:	50                   	push   %eax
80109fdc:	e8 2c af ff ff       	call   80104f0d <memmove>
80109fe1:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109fe4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fe7:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109feb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fee:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109ff2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ff5:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109ff8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ffb:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109fff:	8b 45 18             	mov    0x18(%ebp),%eax
8010a002:	83 c0 28             	add    $0x28,%eax
8010a005:	0f b7 c0             	movzwl %ax,%eax
8010a008:	83 ec 0c             	sub    $0xc,%esp
8010a00b:	50                   	push   %eax
8010a00c:	e8 9b f8 ff ff       	call   801098ac <H2N_ushort>
8010a011:	83 c4 10             	add    $0x10,%esp
8010a014:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a017:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a01b:	0f b7 15 a0 a0 11 80 	movzwl 0x8011a0a0,%edx
8010a022:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a025:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a029:	0f b7 05 a0 a0 11 80 	movzwl 0x8011a0a0,%eax
8010a030:	83 c0 01             	add    $0x1,%eax
8010a033:	66 a3 a0 a0 11 80    	mov    %ax,0x8011a0a0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a039:	83 ec 0c             	sub    $0xc,%esp
8010a03c:	6a 00                	push   $0x0
8010a03e:	e8 69 f8 ff ff       	call   801098ac <H2N_ushort>
8010a043:	83 c4 10             	add    $0x10,%esp
8010a046:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a049:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a04d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a050:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a057:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a05b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a05e:	83 c0 0c             	add    $0xc,%eax
8010a061:	83 ec 04             	sub    $0x4,%esp
8010a064:	6a 04                	push   $0x4
8010a066:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a06b:	50                   	push   %eax
8010a06c:	e8 9c ae ff ff       	call   80104f0d <memmove>
8010a071:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a074:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a077:	8d 50 0c             	lea    0xc(%eax),%edx
8010a07a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a07d:	83 c0 10             	add    $0x10,%eax
8010a080:	83 ec 04             	sub    $0x4,%esp
8010a083:	6a 04                	push   $0x4
8010a085:	52                   	push   %edx
8010a086:	50                   	push   %eax
8010a087:	e8 81 ae ff ff       	call   80104f0d <memmove>
8010a08c:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a08f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a092:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a098:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a09b:	83 ec 0c             	sub    $0xc,%esp
8010a09e:	50                   	push   %eax
8010a09f:	e8 08 f9 ff ff       	call   801099ac <ipv4_chksum>
8010a0a4:	83 c4 10             	add    $0x10,%esp
8010a0a7:	0f b7 c0             	movzwl %ax,%eax
8010a0aa:	83 ec 0c             	sub    $0xc,%esp
8010a0ad:	50                   	push   %eax
8010a0ae:	e8 f9 f7 ff ff       	call   801098ac <H2N_ushort>
8010a0b3:	83 c4 10             	add    $0x10,%esp
8010a0b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0b9:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a0bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0c0:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a0c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0c7:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a0ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0cd:	0f b7 10             	movzwl (%eax),%edx
8010a0d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0d3:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a0d7:	a1 a4 a0 11 80       	mov    0x8011a0a4,%eax
8010a0dc:	83 ec 0c             	sub    $0xc,%esp
8010a0df:	50                   	push   %eax
8010a0e0:	e8 e9 f7 ff ff       	call   801098ce <H2N_uint>
8010a0e5:	83 c4 10             	add    $0x10,%esp
8010a0e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a0eb:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a0ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0f1:	8b 40 04             	mov    0x4(%eax),%eax
8010a0f4:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a0fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0fd:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a100:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a103:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a107:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a10a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a10e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a111:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a115:	8b 45 14             	mov    0x14(%ebp),%eax
8010a118:	89 c2                	mov    %eax,%edx
8010a11a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a11d:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a120:	83 ec 0c             	sub    $0xc,%esp
8010a123:	68 90 38 00 00       	push   $0x3890
8010a128:	e8 7f f7 ff ff       	call   801098ac <H2N_ushort>
8010a12d:	83 c4 10             	add    $0x10,%esp
8010a130:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a133:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a137:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a13a:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a140:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a143:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a149:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a14c:	83 ec 0c             	sub    $0xc,%esp
8010a14f:	50                   	push   %eax
8010a150:	e8 1f 00 00 00       	call   8010a174 <tcp_chksum>
8010a155:	83 c4 10             	add    $0x10,%esp
8010a158:	83 c0 08             	add    $0x8,%eax
8010a15b:	0f b7 c0             	movzwl %ax,%eax
8010a15e:	83 ec 0c             	sub    $0xc,%esp
8010a161:	50                   	push   %eax
8010a162:	e8 45 f7 ff ff       	call   801098ac <H2N_ushort>
8010a167:	83 c4 10             	add    $0x10,%esp
8010a16a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a16d:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a171:	90                   	nop
8010a172:	c9                   	leave  
8010a173:	c3                   	ret    

8010a174 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a174:	55                   	push   %ebp
8010a175:	89 e5                	mov    %esp,%ebp
8010a177:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a17a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a17d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a180:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a183:	83 c0 14             	add    $0x14,%eax
8010a186:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a189:	83 ec 04             	sub    $0x4,%esp
8010a18c:	6a 04                	push   $0x4
8010a18e:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a193:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a196:	50                   	push   %eax
8010a197:	e8 71 ad ff ff       	call   80104f0d <memmove>
8010a19c:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a19f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1a2:	83 c0 0c             	add    $0xc,%eax
8010a1a5:	83 ec 04             	sub    $0x4,%esp
8010a1a8:	6a 04                	push   $0x4
8010a1aa:	50                   	push   %eax
8010a1ab:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1ae:	83 c0 04             	add    $0x4,%eax
8010a1b1:	50                   	push   %eax
8010a1b2:	e8 56 ad ff ff       	call   80104f0d <memmove>
8010a1b7:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a1ba:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a1be:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a1c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1c5:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a1c9:	0f b7 c0             	movzwl %ax,%eax
8010a1cc:	83 ec 0c             	sub    $0xc,%esp
8010a1cf:	50                   	push   %eax
8010a1d0:	e8 b5 f6 ff ff       	call   8010988a <N2H_ushort>
8010a1d5:	83 c4 10             	add    $0x10,%esp
8010a1d8:	83 e8 14             	sub    $0x14,%eax
8010a1db:	0f b7 c0             	movzwl %ax,%eax
8010a1de:	83 ec 0c             	sub    $0xc,%esp
8010a1e1:	50                   	push   %eax
8010a1e2:	e8 c5 f6 ff ff       	call   801098ac <H2N_ushort>
8010a1e7:	83 c4 10             	add    $0x10,%esp
8010a1ea:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a1ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a1f5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a1fb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a202:	eb 33                	jmp    8010a237 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a204:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a207:	01 c0                	add    %eax,%eax
8010a209:	89 c2                	mov    %eax,%edx
8010a20b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a20e:	01 d0                	add    %edx,%eax
8010a210:	0f b6 00             	movzbl (%eax),%eax
8010a213:	0f b6 c0             	movzbl %al,%eax
8010a216:	c1 e0 08             	shl    $0x8,%eax
8010a219:	89 c2                	mov    %eax,%edx
8010a21b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a21e:	01 c0                	add    %eax,%eax
8010a220:	8d 48 01             	lea    0x1(%eax),%ecx
8010a223:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a226:	01 c8                	add    %ecx,%eax
8010a228:	0f b6 00             	movzbl (%eax),%eax
8010a22b:	0f b6 c0             	movzbl %al,%eax
8010a22e:	01 d0                	add    %edx,%eax
8010a230:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a233:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a237:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a23b:	7e c7                	jle    8010a204 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a23d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a240:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a243:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a24a:	eb 33                	jmp    8010a27f <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a24c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a24f:	01 c0                	add    %eax,%eax
8010a251:	89 c2                	mov    %eax,%edx
8010a253:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a256:	01 d0                	add    %edx,%eax
8010a258:	0f b6 00             	movzbl (%eax),%eax
8010a25b:	0f b6 c0             	movzbl %al,%eax
8010a25e:	c1 e0 08             	shl    $0x8,%eax
8010a261:	89 c2                	mov    %eax,%edx
8010a263:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a266:	01 c0                	add    %eax,%eax
8010a268:	8d 48 01             	lea    0x1(%eax),%ecx
8010a26b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a26e:	01 c8                	add    %ecx,%eax
8010a270:	0f b6 00             	movzbl (%eax),%eax
8010a273:	0f b6 c0             	movzbl %al,%eax
8010a276:	01 d0                	add    %edx,%eax
8010a278:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a27b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a27f:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a283:	0f b7 c0             	movzwl %ax,%eax
8010a286:	83 ec 0c             	sub    $0xc,%esp
8010a289:	50                   	push   %eax
8010a28a:	e8 fb f5 ff ff       	call   8010988a <N2H_ushort>
8010a28f:	83 c4 10             	add    $0x10,%esp
8010a292:	66 d1 e8             	shr    %ax
8010a295:	0f b7 c0             	movzwl %ax,%eax
8010a298:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a29b:	7c af                	jl     8010a24c <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a29d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2a0:	c1 e8 10             	shr    $0x10,%eax
8010a2a3:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a2a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2a9:	f7 d0                	not    %eax
}
8010a2ab:	c9                   	leave  
8010a2ac:	c3                   	ret    

8010a2ad <tcp_fin>:

void tcp_fin(){
8010a2ad:	55                   	push   %ebp
8010a2ae:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a2b0:	c7 05 a8 a0 11 80 01 	movl   $0x1,0x8011a0a8
8010a2b7:	00 00 00 
}
8010a2ba:	90                   	nop
8010a2bb:	5d                   	pop    %ebp
8010a2bc:	c3                   	ret    

8010a2bd <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a2bd:	55                   	push   %ebp
8010a2be:	89 e5                	mov    %esp,%ebp
8010a2c0:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a2c3:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2c6:	83 ec 04             	sub    $0x4,%esp
8010a2c9:	6a 00                	push   $0x0
8010a2cb:	68 6b c3 10 80       	push   $0x8010c36b
8010a2d0:	50                   	push   %eax
8010a2d1:	e8 65 00 00 00       	call   8010a33b <http_strcpy>
8010a2d6:	83 c4 10             	add    $0x10,%esp
8010a2d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a2dc:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2df:	83 ec 04             	sub    $0x4,%esp
8010a2e2:	ff 75 f4             	push   -0xc(%ebp)
8010a2e5:	68 7e c3 10 80       	push   $0x8010c37e
8010a2ea:	50                   	push   %eax
8010a2eb:	e8 4b 00 00 00       	call   8010a33b <http_strcpy>
8010a2f0:	83 c4 10             	add    $0x10,%esp
8010a2f3:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a2f6:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2f9:	83 ec 04             	sub    $0x4,%esp
8010a2fc:	ff 75 f4             	push   -0xc(%ebp)
8010a2ff:	68 99 c3 10 80       	push   $0x8010c399
8010a304:	50                   	push   %eax
8010a305:	e8 31 00 00 00       	call   8010a33b <http_strcpy>
8010a30a:	83 c4 10             	add    $0x10,%esp
8010a30d:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a310:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a313:	83 e0 01             	and    $0x1,%eax
8010a316:	85 c0                	test   %eax,%eax
8010a318:	74 11                	je     8010a32b <http_proc+0x6e>
    char *payload = (char *)send;
8010a31a:	8b 45 10             	mov    0x10(%ebp),%eax
8010a31d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a320:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a323:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a326:	01 d0                	add    %edx,%eax
8010a328:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a32b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a32e:	8b 45 14             	mov    0x14(%ebp),%eax
8010a331:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a333:	e8 75 ff ff ff       	call   8010a2ad <tcp_fin>
}
8010a338:	90                   	nop
8010a339:	c9                   	leave  
8010a33a:	c3                   	ret    

8010a33b <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a33b:	55                   	push   %ebp
8010a33c:	89 e5                	mov    %esp,%ebp
8010a33e:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a341:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a348:	eb 20                	jmp    8010a36a <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a34a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a34d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a350:	01 d0                	add    %edx,%eax
8010a352:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a355:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a358:	01 ca                	add    %ecx,%edx
8010a35a:	89 d1                	mov    %edx,%ecx
8010a35c:	8b 55 08             	mov    0x8(%ebp),%edx
8010a35f:	01 ca                	add    %ecx,%edx
8010a361:	0f b6 00             	movzbl (%eax),%eax
8010a364:	88 02                	mov    %al,(%edx)
    i++;
8010a366:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a36a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a36d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a370:	01 d0                	add    %edx,%eax
8010a372:	0f b6 00             	movzbl (%eax),%eax
8010a375:	84 c0                	test   %al,%al
8010a377:	75 d1                	jne    8010a34a <http_strcpy+0xf>
  }
  return i;
8010a379:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a37c:	c9                   	leave  
8010a37d:	c3                   	ret    
