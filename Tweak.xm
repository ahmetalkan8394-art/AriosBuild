#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// --- ÖZELLİK DEĞİŞKENLERİ (Switch Durumları) ---
static bool keyVerified = false;
static bool isMenuVisible = false;

static bool bAimbot = false;
static bool bSpeedHack = false;
static bool bCarFly = false;
static bool bESP = false;
static bool bParaute = false;
static bool bBulletTrack = false;
static bool bCharFly = false;
static bool bSmallCross = false;

// UI Elemanları
UIView *mainMenu;
UIButton *menuButton;

// --- KEY SİSTEMİ (API KONTROLÜ) ---
void checkKey(NSString *userKey) {
    NSString *apiUrl = [NSString stringWithFormat:@"https://ar-hacks.rf.gd/admin/api.php?key=%@", userKey];
    NSURL *url = [NSURL URLWithString:apiUrl];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([response containsString:@"true"] || [response containsString:@"success"]) {
                keyVerified = true;
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AR HOME" message:@"Giriş Başarılı!" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Menüye Geç" style:UIAlertActionStyleDefault handler:nil]];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            } else {
                keyVerified = false;
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AR HOME" message:@"Key Süresi Bitti!" preferredStyle:UIAlertControllerStyleAlert];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        });
    });
}

// --- HİLE MOTORU (HOOKLAR) ---
// Arkadaşın offsetleri (0x...) güncel libSGame.so dosyasından bulup değiştirmelidir.

void (*old_PlayerUpdate)(void *instance);
void new_PlayerUpdate(void *instance) {
    if (instance != NULL) {
        // Hız Hilesi: Sadece buton AÇIKSA ve EĞİLİNCE çalışır
        if (bSpeedHack) {
            int stance = *(int *)((uintptr_t)instance + 0xOFFSET_STANCE); // Duruş offseti
            if (stance == 2) { // 2 = Eğilme
                *(float *)((uintptr_t)instance + 0xOFFSET_SPEED) = 45.0f; // Hız
            } else {
                *(float *)((uintptr_t)instance + 0xOFFSET_SPEED) = 1.0f; // Normal
            }
        }

        // Karakter Uçurma: Buton AÇIKSA zıplama değerini artırır
        if (bCharFly) {
            *(float *)((uintptr_t)instance + 0xOFFSET_JUMP) = 500.0f;
        }
    }
    old_PlayerUpdate(instance);
}

void (*old_VehicleUpdate)(void *instance);
void new_VehicleUpdate(void *instance) {
    if (instance != NULL && bCarFly) {
        bool isHonking = *(bool *)((uintptr_t)instance + 0xOFFSET_HORN); // Korna offseti
        if (isHonking) {
            *(float *)((uintptr_t)instance + 0xOFFSET_VEHICLE_Z) = 1000.0f; // Uzaya fırlatma
        }
    }
    old_VehicleUpdate(instance);
}

// --- PREMIUM MENÜ ARAYÜZÜ ---
@interface ARHomeMenu : UIViewController
@end

@implementation ARHomeMenu

- (void)setupMenu {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    // 1. Yuvarlak Menü Butonu
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(40, 150, 50, 50);
    menuButton.backgroundColor = [UIColor blueColor];
    menuButton.layer.cornerRadius = 25;
    menuButton.layer.borderWidth = 2;
    menuButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [menuButton setTitle:@"AR" forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:menuButton];

    // 2. Ana Menü Paneli (Premium Siyah-Gold Tasarım)
    mainMenu = [[UIVi
