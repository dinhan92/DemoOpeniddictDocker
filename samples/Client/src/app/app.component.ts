import { Component, OnInit, HostBinding, isDevMode } from '@angular/core';
import { Router } from '@angular/router';

import { OAuthService, OAuthEvent } from 'angular-oauth2-oidc';

import { UserService } from './shared';

@Component({
  selector: 'tw-root',
  templateUrl: './app.component.html'
})
export class AppComponent implements OnInit {
  title = 'ClientApp';

  @HostBinding('class')
  public style = 'shell';

  public get isAuthenticated(): boolean {
    return this.user.isAuthenticated;
  }

  public get username(): string {
    return this.user.userName;
  }

  public get claims(): Array<string> {
    return this.user.userClaims;
  }

  public constructor(
    private router: Router,
    private user: UserService,
    private oauthService: OAuthService
  ) {
  }

  public ngOnInit(): void {
    this.configure();
  }

  public loginClick(state: string): void {
    if (state === 'login') {
      this.login();
    } else {
      this.logout();
    }
  }

  public login(): void {
    this.oauthService.initLoginFlow();
  }

  public logout(): void {
    this.oauthService.logOut(false);
    this.user.reset();
    this.router.navigate(['/']);
  }

  private async configure() {
    const redirUri = isDevMode()
      ? 'http://localhost:4200'
      : window.location.origin;

    const devModeIssuer = 'http://localhost:5000/';

    this.oauthService.configure({
      clientId: 'spa_client',
      issuer: isDevMode()
        ? devModeIssuer
        : window.location.origin + '/',
      redirectUri: redirUri,
      responseType: 'code',
      scope: 'openid roles email server_scope api_scope',
      requireHttps: false
    });

    this.oauthService.events.subscribe(async (e: OAuthEvent) => {
      if (e.type === 'token_received' || e.type === 'token_refreshed') {
        this.user.loadProfile();
      }

      if (e.type === 'discovery_document_loaded' && this.oauthService.hasValidAccessToken()) {
        this.user.loadProfile();
      }
    });

    this.oauthService.loadDiscoveryDocumentAndLogin({
      onTokenReceived: () => {
        this.user.loadProfile();
      }
    });
  }
}
